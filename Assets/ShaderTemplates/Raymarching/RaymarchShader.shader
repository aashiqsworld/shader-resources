// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Aashiq/ShellShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Float) = 0.5
        _Center ("Center", Vector) = (0.0, 0.0, 0.0)
        _ObjectPos ("Object Position", Vector) = (0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define STEPS 64
            #define STEP_SIZE 0.01
            #define MIN_DISTANCE 0.05

            
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 wPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Radius;
            float3 _Center;
            float3 _ObjectPos;
            

            float sphereDistance (float3 p)
            {
                return distance(p, _Center) - _Radius;
            }

            fixed4 raymarch (float3 position, float3 direction)
            {
                for (int i = 0; i < STEPS; i++)
                {
                    float distance = sphereDistance(position);
                    if (distance < MIN_DISTANCE)
                        return i / (float) STEPS;
             
                    position += distance * direction;
                }
                return 1;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPosition = i.wPos;
                float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
                return raymarch(worldPosition, viewDirection);

                /*
                if(raymarchHit(worldPosition, viewDirection))
                    return fixed4(1, 0, 0, 1); // red if hit sphere
                else
                    return fixed4(1, 1, 1, 1); // white otherwise
                    */
            }
            ENDCG
        }
    }
}
