Shader "Unlit/StencilMask"
{
    Properties
    {
        _Color("Color", Color) = (0,0,0,0)
        _MaskValue("MaskValue", int) = 0
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry-1" }
        ColorMask 0
        ZWrite off

        Stencil
        {
            Ref [_MaskValue]
            Comp always
            Pass replace
        }

        Pass
        {
            Cull Back
            ZTest Less
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
