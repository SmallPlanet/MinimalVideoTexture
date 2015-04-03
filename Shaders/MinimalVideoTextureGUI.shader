Shader "MinimalVideoTexture/MinimalVideoTextureGUI"
{
	Properties
	{
		[PerRendererData] _LumaTex ("Luma Texture", 2D) = "white" {}
		[PerRendererData] _ChromaTex ("Chroma Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
			};
			
			fixed4 _Color;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.texcoord = float2(IN.texcoord.x, 1 - IN.texcoord.y);
				OUT.color = IN.color * _Color;
				return OUT;
			}

			sampler2D _ChromaTex;
			sampler2D _LumaTex;

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed3 yuv;
				fixed3 rgb;

				yuv.x = tex2D(_LumaTex, IN.texcoord).r;
				yuv.yz = tex2D(_ChromaTex, IN.texcoord).rg - fixed2(0.5, 0.5);

				// Using BT.709 which is the standard for HDTV
				rgb = mul(float3x3(     1,       	0,      		1.57481,
           								1,			-0.18732, 		-0.46813,
           								1, 			1.8556,      	0), yuv);

				return fixed4(rgb, 1) * IN.color;
			}
		ENDCG
		}
	}
}
