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



using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.IO;
using System;


public class MinimalVideoTextureGraphic : Graphic {

	#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
	public string shaderPath = "MinimalVideoTexture/MinimalVideoTextureGUI";
	#else
	public string shaderPath = null;
	#endif
	public string resourcePath;
	public bool loops;

	public Action MovieDidFinishBlock;

	#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
	private int mvtID = 0;
	private Texture2D chromaTexture2D = null;
	private Texture2D lumaTexture2D = null;
	#else
	private MovieTexture movieTexture;
	private bool waitingForMovieToEnd;
	#endif

	public override Material defaultMaterial {
		get {
			if (shaderPath != null) {
				return new Material (Shader.Find (shaderPath));
			}
			return base.defaultMaterial;
		}
	}

	public override Texture mainTexture {
		get {
			if (resourcePath != null && resourcePath.Length > 0) {

				#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
				string path = Application.streamingAssetsPath + "/" + resourcePath;
				mvtID = MinimalVideoTexture.Create (path);
				MinimalVideoTexture.SetLoops(mvtID, loops);
				return null;
				#else

				string url = "file://"+Application.streamingAssetsPath+"/"+Path.GetFileNameWithoutExtension(resourcePath)+".ogv";
				WWW movieStream = new WWW (url);
				if (movieStream != null) {
					movieTexture = movieStream.movie;
					movieTexture.loop = loops;
				}else{
					Debug.Log("Unable to load MovieTexture: "+Path.GetFileNameWithoutExtension(resourcePath));
				}
				return movieTexture;
				#endif
			}
			return null;
		}
	}

	protected override void OnDestroy() {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		MinimalVideoTexture.Destroy (mvtID);
		mvtID = 0;
		#else
		if(movieTexture != null){
			movieTexture.Stop();
		}
		#endif
	}
	 

	public void Update() {




		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		GL.IssuePluginEvent(mvtID);

		if(MinimalVideoTexture.IsFinished(mvtID) == false) {
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
		} else {
			if(MovieDidFinishBlock != null){
				MovieDidFinishBlock();
			}
		}
		#else
		if(movieTexture != null){

			if(movieTexture.isPlaying == false && waitingForMovieToEnd == true){
				if(MovieDidFinishBlock != null) {
					MovieDidFinishBlock();
				}
				waitingForMovieToEnd = false;
			}

			if(movieTexture.isReadyToPlay == true && movieTexture.isPlaying == false){
				movieTexture.Play();
				waitingForMovieToEnd = true;
			}
		}
		#endif
	}
		
	public bool IsRaycastLocationValid(Vector2 screenPoint, Camera eventCamera) {
		return true;
	}

	protected override void OnFillVBO (List<UIVertex> vbo)
	{
		Vector2 corner1 = Vector2.zero;
		Vector2 corner2 = Vector2.zero;

		corner1.x = 0f;
		corner1.y = 0f;
		corner2.x = 1f;
		corner2.y = 1f;

		corner1.x -= rectTransform.pivot.x;
		corner1.y -= rectTransform.pivot.y;
		corner2.x -= rectTransform.pivot.x;
		corner2.y -= rectTransform.pivot.y;

		corner1.x *= rectTransform.rect.width;
		corner1.y *= rectTransform.rect.height;
		corner2.x *= rectTransform.rect.width;
		corner2.y *= rectTransform.rect.height;

		vbo.Clear();

		UIVertex vert = UIVertex.simpleVert;

		vert.position = new Vector2(corner1.x, corner1.y);
		vert.color = color;
		vert.uv0 = new Vector2 (0, 0);
		vbo.Add(vert);

		vert.position = new Vector2(corner1.x, corner2.y);
		vert.color = color;
		vert.uv0 = new Vector2 (0, 1);
		vbo.Add(vert);

		vert.position = new Vector2(corner2.x, corner2.y);
		vert.color = color;
		vert.uv0 = new Vector2 (1, 1);
		vbo.Add(vert);

		vert.position = new Vector2(corner2.x, corner1.y);
		vert.color = color;
		vert.uv0 = new Vector2 (1, 0);
		vbo.Add(vert);
	}

}
