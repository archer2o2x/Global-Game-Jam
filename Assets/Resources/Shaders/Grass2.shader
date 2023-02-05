Shader "Custom/Grass/Grass2"
{
    Properties
    {
        [HDR]_MainColor("Color",Color) = (0.5,0.5,0.5,0.5)
        _MainTex ("Texture", 2D) = "white" {}
        _Noise("Noise",2D)="black"

        _WindControl("WindControl(x:XSpeed y:YSpeed z:ZSpeed w:windMagnitude)",Vector)=(1,0,1,0.5)
        _WaveControl("WaveControl(x:XSpeed y:YSpeed z:ZSpeed w:worldSize)",Vector)=(1,0,1,1)


    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            half4 _MainColor;
            sampler2D _MainTex;
            sampler2D _Noise;
            float4 _MainTex_ST;
            half4 _WindControl;
            half4 _WaveControl;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float2 samplePos = worldPos.xz / _WaveControl.w;
                samplePos += _Time.x * _WaveControl.xz;
                fixed waveSample = tex2Dlod(_Noise, float4(samplePos,0,0)).r;
                worldPos.x +=sin(waveSample * _WindControl.x) * _WaveControl.x * _WindControl.w * v.uv.y;
                worldPos.z +=sin(waveSample * _WindControl.z) * _WaveControl.z * _WindControl.z * v.uv.y;
                o.pos = mul(UNITY_MATRIX_VP,worldPos);

                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;
                return col;
            }
            ENDCG
        }
    }
}
