/* Copyright (c) 2012 Small Planet Digital, LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files 
 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, 
 * publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MinimalVideoTexture.h"
#import "UnityAppController.h"

#import <Foundation/NSProcessInfo.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CoreAnimation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES2/gl.h>


#pragma mark --- Managed -> Natice Bridge ---

static NSMutableArray * activeMVTTextures = NULL;
static int globalMVTID = 1;

MinimalVideoTexture * GetMVTFromMVTID(int mvtID) {
    if(activeMVTTextures == NULL){
        activeMVTTextures = [[NSMutableArray array] retain];
    }
    
    for(MinimalVideoTexture * movie in activeMVTTextures)
    {
        if(movie.mvtID == mvtID)
            return movie;
    }
    
    return NULL;
}


int NativeMVTCreate(const char * moviePath) {
    if(activeMVTTextures == NULL){
        activeMVTTextures = [[NSMutableArray array] retain];
    }
    
    MinimalVideoTexture * mvt = [[MinimalVideoTexture alloc] init];
    [mvt createMovieTextureWithMoviePath:[NSString stringWithUTF8String:moviePath]];
    [mvt playMovie];
    [activeMVTTextures addObject:mvt];
    
    return mvt.mvtID;
}

int NativeMVTDestroy(int mvtID) {
    return 0;
}

int NativeMVTSetLoops(int mvtID, bool loops) {
    MinimalVideoTexture * mvt = GetMVTFromMVTID(mvtID);
    return mvt.looping = loops;
}

int NativeMVTPlay(int mvtID) {
    MinimalVideoTexture * mvt = GetMVTFromMVTID(mvtID);
    [mvt playMovie];
    return 0;
}

int NativeMVTStop(int mvtID) {
    MinimalVideoTexture * mvt = GetMVTFromMVTID(mvtID);
    [mvt stopMovie];
    return 0;
}

int NativeMVTGetChromaTextureName(int mvtID) {
    MinimalVideoTexture * mvt = GetMVTFromMVTID(mvtID);
    return [mvt chromaTexture];
}

int NativeMVTGetLumaTextureName(int mvtID) {
    MinimalVideoTexture * mvt = GetMVTFromMVTID(mvtID);
    return [mvt lumaTexture];
}

void NativeMVTUpdateTextures(int mvtID) {
    MinimalVideoTexture * mvt = GetMVTFromMVTID(mvtID);
    [mvt updateMovieTexture];
}



#pragma mark --- Rendering Plug-in API ---


void UnitySetGraphicsDevice(void* device, int deviceType, int eventType)
{
    
}

void UnityRenderEvent(int marker)
{
    NativeMVTUpdateTextures(marker);
}

@interface MyAppController : UnityAppController
{
}
- (void)shouldAttachRenderDelegate;
@end

@implementation MyAppController

- (void)shouldAttachRenderDelegate;
{
    UnityRegisterRenderingPlugin(&UnitySetGraphicsDevice, &UnityRenderEvent);
}
@end


IMPL_APP_CONTROLLER_SUBCLASS(MyAppController)





#pragma mark --- Minimal Video Texture Class ---

@implementation MinimalVideoTexture

@synthesize mvtID, looping, startDate;

- (id) init
{
    self = [super init];
    
    if(self)
    {
        _asyncAfterInitialLoad = YES;
        mvtID = globalMVTID++;
        _chromaTexture = NULL;
        _lumaTexture = NULL;
        startDate = NULL;
        volume = 1.0f;

        numberOfFramesToSkip = [[NSUserDefaults standardUserDefaults] integerForKey:@"COCOTRON_MOVIE_IOS_FRAMES_TO_SKIP"];
        if(numberOfFramesToSkip == 0) {
            numberOfFramesToSkip = 500;
        }
    }
    return self;
}

- (void) dealloc
{
    [self cleanupTextures];
    
    if (_videoTextureCache != NULL) {
        CFRelease(_videoTextureCache);
    }
    
    [audio_player release];
    audio_player = NULL;
    
    [asset_reader release];
    asset_reader = NULL;
    
    [date release];
    date = NULL;
    
    if(restartDate) {
        [restartDate release];
        restartDate = NULL;
    }
    
    [startDate release];
    startDate = NULL;
    
    [moviePath release];
    moviePath = NULL;
    
    [super dealloc];
}

#pragma mark -

- (float) currentMovieTime
{
    return currentFrameTime;
}

- (void) playMovie
{
    isPlaying = YES;
    [audio_player play];
    [audio_player setVolume:volume];
}

- (void) stopMovie
{
    isPlaying = NO;
    [audio_player pause];
}

- (void) setVolume:(float)f {
    volume = f;
    [audio_player setVolume:volume];
}

- (void) restartMovie
{
    if (!self.asyncAfterInitialLoad) {
        [audio_player release];
        audio_player = NULL;
        
        [asset_reader release];
        asset_reader = NULL;
        
        [self cleanupTextures];
        CFRelease(_videoTextureCache);
        _videoTextureCache = NULL;
    }
    
    [self createMovieTextureWithMoviePath:moviePath];
}

- (int) createMovieTextureWithMoviePath:(NSString *) urlPath
{
    [moviePath autorelease];
    moviePath = [urlPath retain];
    
    NSURL * url = [NSURL fileURLWithPath:urlPath];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    loadingDidFinish = NO;
    isPlaying = NO;
    
    [self cleanupTextures];
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
    }
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                                (CFDictionaryRef)[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0] forKey:(id<NSCopying>)kCVOpenGLESTextureCacheMaximumTextureAgeKey],
                                                (CVEAGLContext)[EAGLContext currentContext], NULL, &_videoTextureCache);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return 0;
    }
    
    urlAssetHasBeenLoaded = NULL;
    
    AVURLAsset * urlAsset = [[AVURLAsset alloc] initWithURL:url options: options];
    NSArray *keys = [NSArray arrayWithObject:@"playable"];
    [urlAsset loadValuesAsynchronouslyForKeys:keys
                            completionHandler:^{
                                urlAssetHasBeenLoaded = [urlAsset retain];
                                loadingDidFinish = YES;
                            }];
    [urlAsset autorelease];
    
    return mvtID;
}

- (void) prepareToPlayAsset:(AVURLAsset *)urlAsset {
    if (self.asyncAfterInitialLoad) {
        [audio_player release];
        audio_player = NULL;
        
        [asset_reader release];
        asset_reader = NULL;
        
        [self cleanupTextures];
    }
    
    AVAssetReaderTrackOutput * asset_reader_output;
    
    NSArray * videoTracks = [urlAsset tracksWithMediaType:AVMediaTypeVideo];
    NSArray * audioTracks = [urlAsset tracksWithMediaType:AVMediaTypeAudio];
    
    AVAssetTrack* videoTrack = ([videoTracks count] ? [videoTracks objectAtIndex:0] : NULL);
    AVAssetTrack* audioTrack = ([audioTracks count] ? [audioTracks objectAtIndex:0] : NULL);
    
    // Make a composition with the video track.
    AVMutableComposition* videoComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack* videoCompositionTrack = [videoComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:[videoTrack timeRange] ofTrack:videoTrack atTime:CMTimeMake(0, 1) error:nil];
    
    duration = CMTimeGetSeconds([videoTrack timeRange].duration);
    
    // Create Asset Reader and Output for the video track.
    // kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    NSDictionary* settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    asset_reader = [[AVAssetReader assetReaderWithAsset:videoComposition error:nil] retain];
    asset_reader_output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoCompositionTrack outputSettings:settings];
    [asset_reader addOutput:asset_reader_output];
    [asset_reader startReading];
    
    if (audioTrack) {
        // Make a composition with the audio track.
        AVMutableComposition* audioComposition = [AVMutableComposition composition];
        AVMutableCompositionTrack* audioCompositionTrack = [audioComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:[audioTrack timeRange] ofTrack:audioTrack atTime:CMTimeMake(0, 1) error:nil];
        
        // Create a player for the audio.
        AVPlayerItem* audioPlayerItem = [AVPlayerItem playerItemWithAsset:audioComposition];
        [audio_player release];
        audio_player = [[AVPlayer playerWithPlayerItem:audioPlayerItem] retain];
        
        if(isPlaying) {
            [audio_player play];
            [audio_player setVolume:volume];
        }
    } else if (audio_player) {
        [audio_player release];
        audio_player = nil;
    }
    
    width = videoTrack.naturalSize.width;
    height = videoTrack.naturalSize.height;
    
    [date release];
    
    if(restartDate) {
        date = [restartDate retain];
        [restartDate release];
        restartDate = NULL;
    } else {
        date = [[NSDate date] retain];
    }
    currentFrameTime = 0;
}

- (void) cleanupTextures
{
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void) updateMovieTexture
{
    // 0.1f - Ariel's eyes were half closed (not showing last)
    // 0.01f - Too small to avoid freeze on party scene
    float durationAdjustment = 0.05f;
    
    // Perform delayed loading of the movie on the main thread
    if(urlAssetHasBeenLoaded){
        [self prepareToPlayAsset:urlAssetHasBeenLoaded];
        [urlAssetHasBeenLoaded release];
        urlAssetHasBeenLoaded = NULL;
    }
    
    CVReturn err;
    if(isPlaying == NO)
    {
        [date release];
        date = [[NSDate dateWithTimeIntervalSinceNow:0] retain];
    }
    
    if(startDate) {
        [date release];
        date = [startDate retain];
    }
    
    if(asset_reader.status == AVAssetReaderStatusReading && currentFrameTime < (duration - durationAdjustment))
    {
        numberOfRestartAttempts = 0;
        
        shouldCallPublishOnEnd = YES;
        
        // Make sure we eat as many frames as we need to avoid showing all missed frames
        CMSampleBufferRef sampleBufferRef = NULL;
        for(int i = 0; i < numberOfFramesToSkip; i++) {
            

            // wait until the time is > currentFrameTime so we don't play the movie back too fast...
            if(fabs([date timeIntervalSinceNow]) < currentFrameTime)
                break;
            
            AVAssetReaderTrackOutput * asset_reader_output = [asset_reader.outputs lastObject];
            
            if(sampleBufferRef != NULL){
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            }
            sampleBufferRef = [asset_reader_output copyNextSampleBuffer];
            if(sampleBufferRef == NULL){
                break;
            }else{
                CMTime time = CMSampleBufferGetPresentationTimeStamp (sampleBufferRef);
                currentFrameTime = ((float)time.value / (float)time.timescale) + 0.1f;
            }
        }
        
        if(sampleBufferRef)
        {
            [self cleanupTextures];
            
            CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBufferRef);
            CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
            
            // CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture
            // optimally from CVImageBufferRef.
            
            // Y-plane
            glActiveTexture(GL_TEXTURE0);
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               _videoTextureCache,
                                                               pixelBuffer,
                                                               NULL,
                                                               GL_TEXTURE_2D,
                                                               GL_RED_EXT,
                                                               width,
                                                               height,
                                                               GL_RED_EXT,
                                                               GL_UNSIGNED_BYTE,
                                                               0,
                                                               &_lumaTexture);
            if (err)
            {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
            
            glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            // UV-plane
            glActiveTexture(GL_TEXTURE1);
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               _videoTextureCache,
                                                               pixelBuffer,
                                                               NULL,
                                                               GL_TEXTURE_2D,
                                                               GL_RG_EXT,
                                                               width/2,
                                                               height/2,
                                                               GL_RG_EXT,
                                                               GL_UNSIGNED_BYTE,
                                                               1,
                                                               &_chromaTexture);
            if (err)
            {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
            
            glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
            
            // Unbind
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), NULL);
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), NULL);
            
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        } else{
            return;
        }
    }
    else if(asset_reader.status == AVAssetReaderStatusCompleted || currentFrameTime >= (duration - durationAdjustment))
    {
        numberOfRestartAttempts = 0;
        
        if (_asyncAfterInitialLoad && _lumaTexture && _chromaTexture) {
            if (!loadingDidFinish) {
                return;
            }
        }
        if(looping)
        {
            [self restartMovie];
            [self playMovie];
        }
        else
        {
            if(shouldCallPublishOnEnd)
            {
                [[self retain] autorelease];
                shouldCallPublishOnEnd = NO;
            }
        }
    }
    else if(asset_reader.status == AVAssetReaderStatusFailed)
    {
        //this can happen when we close the app and open it again while watching a movie
        if(numberOfRestartAttempts < 5){
            numberOfRestartAttempts++;
            
            if(restartDate)
                [restartDate release];
            
            //restartDate = [date retain];
            restartDate = [[NSDate dateWithTimeIntervalSinceNow:-currentFrameTime] retain];
            
            [self restartMovie];
            [self playMovie];
        }
    }
}

- (GLuint) confirmMovieLoaded
{
    if(_lumaTexture == NULL) {
        int failSafe = 500;
        while(loadingDidFinish == NO && failSafe > 0) {
            usleep(5000);
            failSafe--;
        }
        
        [self updateMovieTexture];
    }
    
    if(_lumaTexture == NULL) {
        return 0;
    }
    
    return 1;
}

- (GLuint) lumaTexture {
    [self confirmMovieLoaded];
    return CVOpenGLESTextureGetName(_lumaTexture);
}

- (GLuint) chromaTexture {
    [self confirmMovieLoaded];
    return CVOpenGLESTextureGetName(_chromaTexture);
}

- (void) setStartDate:(NSDate *)newDate
{
    if(startDate) {
        [startDate release];
    }
    
    startDate = newDate;
    [startDate retain];
}

- (NSDate*) startDate
{
    return startDate;
}

@end
