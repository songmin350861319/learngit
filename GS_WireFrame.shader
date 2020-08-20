
Shader "Unlit/GS_Wireframe"

{

	Properties

	{



		_WireColor("WireColor", Color) = (1, 0, 0, 1)

		_FillColor("FillColor", Color) = (1, 1, 1, 1)

		_WireWidth("WireWidth", Range(0, 0.005)) = 1





	}

		SubShader

	{

		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

		LOD 100



		Pass

		{

			Blend SrcAlpha OneMinusSrcAlpha

			Cull Off

			CGPROGRAM



			#pragma vertex vert

			#pragma geometry geom

			#pragma fragment frag



			#include "UnityCG.cginc"



			struct appdata

			{

				float4 vertex: POSITION;

				float2 uv: TEXCOORD0;

			};



			struct v2g

			{

				float3 uv: TEXCOORD0;

				float4 vertex: SV_POSITION;

			};



			struct g2f

			{

				float3 uv: TEXCOORD0;

				float4 vertex: SV_POSITION;

				float3 dist: TEXCOORD1;

			};



			sampler2D _MainTex;

			float4 _MainTex_ST;



			float4 _FillColor, _WireColor;

			float _WireWidth, _Clip, _Lerp, _WireLerpWidth;



			v2g vert(appdata v)

			{

				v2g o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

				//o.uv.z = _Clip + v.vertex.y;

				o.uv.z = v.vertex.y;

				return o;

			}



			[maxvertexcount(3)]

			void geom(triangle v2g IN[3], inout TriangleStream < g2f > triStream)

			{

				float2 p0 = IN[0].vertex.xy / IN[0].vertex.w;

				float2 p1 = IN[1].vertex.xy / IN[1].vertex.w;

				float2 p2 = IN[2].vertex.xy / IN[2].vertex.w;



				float2 v0 = p2 - p1;

				float2 v1 = p2 - p0;

				float2 v2 = p1 - p0;

				//triangles area

				float area = abs(v1.x * v2.y - v1.y * v2.x);



				// //到三条边的最短距离

				g2f OUT;

				OUT.vertex = IN[0].vertex;

				OUT.uv = IN[0].uv;

				OUT.dist = float3(area / length(v0), 0, 0);

				triStream.Append(OUT);



				OUT.vertex = IN[1].vertex;

				OUT.uv = IN[1].uv;

				OUT.dist = float3(0, area / length(v1), 0);

				triStream.Append(OUT);



				OUT.vertex = IN[2].vertex;

				OUT.uv = IN[2].uv;

				OUT.dist = float3(0, 0, area / length(v2));

				triStream.Append(OUT);

			}



			fixed4 frag(g2f i) : SV_Target

			{



				fixed4 col_Wire;

				float d = min(i.dist.x, min(i.dist.y, i.dist.z));

				col_Wire = d < _WireWidth ? _WireColor : _FillColor;





				return col_Wire;

			}

			ENDCG



		}

	}

}
