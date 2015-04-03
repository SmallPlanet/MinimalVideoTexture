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


using System.Xml;
using System.Collections;

public class PUMinimalVideoTexture : PUGameObject {

	private string resourcePath = null;
	private bool loops = false;

	public override void gaxb_final(XmlReader reader, object _parent, Hashtable args) {
		base.gaxb_final(reader, _parent, args);

		string attrib;

		if (reader != null) {
			attrib = reader.GetAttribute ("resourcePath");
			if (attrib != null) {
				resourcePath = attrib;
			}

			attrib = reader.GetAttribute ("loops");
			if (attrib != null) {
				loops = bool.Parse (attrib);
			}
		}
	}
	
	public override void gaxb_complete()
	{
		base.gaxb_complete ();

		MinimalVideoTextureGraphic mvt = gameObject.AddComponent<MinimalVideoTextureGraphic>();
		mvt.loops = loops;
		mvt.resourcePath = resourcePath;
	}

	// This is required for application-level subclasses
	public override void gaxb_init ()
	{
		base.gaxb_init ();
		gaxb_addToParent();
	}

}
