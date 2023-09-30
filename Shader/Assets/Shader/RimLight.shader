Shader "Unlit/GH_RimLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_Color ("Color", Color)  = (1,1,1,1)
        [HDR]_RimColor("RimColor", Color) = (1,1,1,1)
        _RimPower("Power", Range(0,10)) = 3
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
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                //
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            //
            //float4 _Color;
            float4 _RimColor;
            float _RimPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                //
                o.viewDir = normalize(UnityWorldSpaceViewDir(v.vertex));
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                half rim = 1 - saturate(dot(i.normal, i.viewDir)); //0-1
                rim = pow(rim, _RimPower);
                return col += rim * _RimColor;
            }
            ENDCG
        }
    }
}
