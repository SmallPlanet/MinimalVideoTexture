# Minimal Video Texture
Minimal Video Texture (MVT) Native iOS Plugin for Unity is a compact and simple way to utilize direct CoreVideo texture rendering for local movies in Unity Pro for iOS.


## Notes

 * MVT is relatively new and untested; you have been warned
 * Supports OpenGL only ( no Metal )
 * Supports iOS only ( if not iOS it will attempt to fall back to MovieTextures )
 * Supports multiple concurrent movies
 * Uses YUV decoding for maximum performance, so it requires a custom shader to merge the chroma and luma textures
 * Includes a custom shader and Graphic subclass suitable for using in uGUI
 * Includes a PUMinialVideoTexture class for easy integration with PlanetUnity
 * Does not support scrubbing/seeking
 * Does support looping and audio playback


 
## Installation

  1. Put MinimalVideoTexture.h and MinimalVideoTexture.m into Assets/Plugins/iOS
  2. Put MinimalVideoTexture.cs into Assets/Plugins
  3. Put MinimalVideoTextureGraphic.cs into Assets/Plugins ( if you want to play movies in uGUI )
  4. Put MinimalVideoTextureGUI.shader in Assets/Resources ( so it can be loaded dynamically from scripts )
  5. Put PUMinimalVideoTexture.cs in Assets ( if you want easy PlanetUnity integration )



## How To Use
*How to use MVT with uGUI*

  1. Add the MinimalVideoTextureGraphic component to a uGUI GameObject
  2. Put the name of the video (including the extension) into Resourse Path
  3. Put the movie in the Assets/StreamingAssets 
  
*How to use MVT with scripting*

	// Create a new MVT movie
	#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
	string path = Application.streamingAssetsPath + "/" + resourcePath;
	mvtID = MinimalVideoTexture.Create (path);
	return null;
	#endif
	
	// During an Update, give the plugin time to process new frames, then update to latest textures.
	// You are responsible for creating a Texture2D using Texture2D.CreateExternalTexture and
	// calling UpdateExternalTexture after GL.IssuePluginEvent(mvtID);
	// In addition, if you are using the supplied shader, you need to set the chroma and luma textures
	// on the material properly
	public void Update() {

		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		// Allow the plugin time to process the movie on a render thead
		GL.IssuePluginEvent(mvtID);

		int chromaTxt = MinimalVideoTexture.GetChromaTextureName(mvtID);
		int lumaTxt = MinimalVideoTexture.GetLumaTextureName(mvtID);

		if (chromaTxt > 0) {
			Material localMaterial = canvasRenderer.GetMaterial ();

			if (chromaTexture2D == null) {
				chromaTexture2D = Texture2D.CreateExternalTexture (16, 16, TextureFormat.RGB24, false, false, (System.IntPtr)chromaTxt);
				localMaterial.SetTexture ("_ChromaTex", chromaTexture2D);
			} else {
				chromaTexture2D.UpdateExternalTexture ((System.IntPtr)chromaTxt);
			}

			if (lumaTexture2D == null) {
				lumaTexture2D = Texture2D.CreateExternalTexture (16, 16, TextureFormat.Alpha8, false, false, (System.IntPtr)lumaTxt);
				localMaterial.SetTexture ("_LumaTex", lumaTexture2D);
			} else {
				lumaTexture2D.UpdateExternalTexture ((System.IntPtr)lumaTxt);
			}
		}
		#endif
	}
	
	// When you're all done with it, make sure to destroy it or it will stay around
	protected override void OnDestroy() {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		MinimalVideoTexture.Destroy (mvtID);
		#endif
	}
	
	


## License

PlanetUnity is free software distributed under the terms of the MIT license, reproduced below. PlanetUnity may be used for any purpose, including commercial purposes, at absolutely no cost. No paperwork, no royalties, no GNU-like "copyleft" restrictions. Just download and enjoy.

Copyright (c) 2014 [Small Planet Digital, LLC](http://smallplanet.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## About Small Planet

Small Planet is a mobile agency in Brooklyn, NY that creates lovely experiences for smartphones and tablets. PlanetUnity has made our lives a lot easier and we hope it does the same for you. You can find us at www.smallplanet.com. 