# MinimalVideoTexture
Minimal Video Texture (MVT) Native iOS Plugin for Unity is a compact and simple way to utilize direct CoreVideo texture rendering for local movies in Unity Pro for iOS.


## Notes

 * Supports OpenGL only ( no Metal )
 * Supports iOS only ( if not iOS it will attempt to fall back to MovieTextures )
 * Uses YUV decoding, so it requires a custom shader to merge the chroma and luma textures
 * Includes shader and Graphic subclass suitable for using in uGUI
 * Includes PlanetUnity entity for easy integration with PlanetUnity


 
## Installation

  1. Put MinimalVideoTexture.h and MinimalVideoTexture.m into Assets/Plugins/iOS
  2. Put MinimalVideoTexture.cs into Assets/Plugins
  3. Put MinimalVideoTextureGraphic.cs into Assets/Plugins ( if you want to play movies in uGUI )
  4. Put MinimalVideoTextureGUI.shader in Assets/Resources ( so it can be loaded dynamically from scripts )
  5. Put PUMinimalVideoTexture.cs in Assets ( if you want easy PlanetUnity integration )



## How To Use
*Short example instructions on how to use MVT in uGUI*

  1. Add the MinimalVideoTextureGraphic component to a uGUI GameObject
  2. Put the name of the video (including the extension) into Resourse Path
  3. Put the movie in the Assets/StreamingAssets 



## License

PlanetUnity is free software distributed under the terms of the MIT license, reproduced below. PlanetUnity may be used for any purpose, including commercial purposes, at absolutely no cost. No paperwork, no royalties, no GNU-like "copyleft" restrictions. Just download and enjoy.

Copyright (c) 2014 [Small Planet Digital, LLC](http://smallplanet.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## About Small Planet

Small Planet is a mobile agency in Brooklyn, NY that creates lovely experiences for smartphones and tablets. PlanetUnity has made our lives a lot easier and we hope it does the same for you. You can find us at www.smallplanet.com. 