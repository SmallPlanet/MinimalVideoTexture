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


#ifndef __MINIMAL_VIDEO_TEXTURE_INIT_
#define __MINIMAL_VIDEO_TEXTURE_INIT_

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CVOpenGLESTextureCache.h>

// Attribute to make function be exported from a plugin
#if UNITY_METRO
#define EXPORT_API __declspec(dllexport) __stdcall
#elif UNITY_WIN
#define EXPORT_API __declspec(dllexport)
#else
#define EXPORT_API
#endif

@interface MinimalVideoTexture : NSObject
{

    unsigned int mvtID;
    
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    
    CVOpenGLESTextureCacheRef _videoTextureCache;
    
    AVAssetReader * asset_reader;
    AVPlayer* audio_player;
    
    float duration;
    
    float width;
    float height;
    NSDate * date;
    NSDate * restartDate;
    NSString * moviePath;
    
    BOOL isPlaying;
    BOOL loadingDidFinish;
    BOOL shouldCallPublishOnEnd;
    BOOL looping;
    
    float currentFrameTime;
    
    NSDate* startDate;
    AVURLAsset * urlAssetHasBeenLoaded;
    
    
    int numberOfFramesToSkip;
    
    int numberOfRestartAttempts;
    float volume;
}

@property (nonatomic, readonly) unsigned int mvtID;
@property (nonatomic, assign) BOOL looping;
@property (nonatomic, assign) BOOL asyncAfterInitialLoad;
@property (nonatomic, assign) NSDate* startDate;

- (int) createMovieTextureWithMoviePath:(NSString *) urlPath;
- (void) updateMovieTexture;

- (void) playMovie;
- (void) stopMovie;
- (void) restartMovie;

- (void) setVolume:(float)f;

- (GLuint) lumaTexture;
- (GLuint) chromaTexture;

- (float) currentMovieTime;

@end

#endif
