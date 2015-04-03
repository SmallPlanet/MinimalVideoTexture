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

public static class MinimalVideoTexture {

	#region Native Plugin Bindings

	[DllImport ("__Internal")]
	private static extern int NativeMVTCreate(string moviePath);

	[DllImport ("__Internal")]
	private static extern int NativeMVTDestroy(int mvtID);

	[DllImport ("__Internal")]
	private static extern int NativeMVTSetLoops(int mvtID, bool loops);

	[DllImport ("__Internal")]
	private static extern int NativeMVTPlay(int mvtID);

	[DllImport ("__Internal")]
	private static extern int NativeMVTStop(int mvtID);

	[DllImport ("__Internal")]
	private static extern int NativeMVTGetChromaTextureName (int mvtID);

	[DllImport ("__Internal")]
	private static extern int NativeMVTGetLumaTextureName (int mvtID);

	[DllImport ("__Internal")]
	private static extern void NativeMVTUpdateTextures (int mvtID);

	#endregion

	#region Native Method Wrappers

	public static int Create(string moviePath) {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		return NativeMVTCreate(moviePath);
		#else
		return 0;
		#endif
	}

	public static int Destroy(int mvtID) {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		return NativeMVTDestroy(mvtID);
		#else
		return 0;
		#endif
	}

	public static int Play(int mvtID) {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		return NativeMVTPlay(mvtID);
		#else
		return 0;
		#endif
	}

	public static int Stop(int mvtID) {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		return NativeMVTStop(mvtID);
		#else
		return 0;
		#endif
	}

	public static int SetLoops(int mvtID, bool loops) {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		return NativeMVTSetLoops(mvtID, loops);
		#else
		return 0;
		#endif
	}

	public static int GetChromaTextureName(int mvtID) {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		return NativeMVTGetChromaTextureName(mvtID);
		#else
		return 0;
		#endif
	}

	public static int GetLumaTextureName(int mvtID) {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		return NativeMVTGetLumaTextureName(mvtID);
		#else
		return 0;
		#endif
	}

	public static void UpdateTextures(int mvtID) {
		#if (UNITY_IOS == true) && (UNITY_EDITOR == false)
		NativeMVTUpdateTextures(mvtID);
		#endif
	}

	#endregion

}