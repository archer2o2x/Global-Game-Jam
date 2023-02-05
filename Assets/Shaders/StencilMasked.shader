/*Shader "Unlit/StenciMasked"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,0)
        _MaskValue("MaskValue", int) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        LOD 200

        Stencil
        {
            Ref[_MaskValue]
            Comp equal
            Pass keep
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "UnityCG.cginc"

            CBUFFER_START(UnityPerMaterial)
                fixed4 _Color;
            CBUFFER_END


            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

      

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _Color;
            }
                
            ENDHLSL
        }
    }
}
*/



Shader "Unlit/StenciMasked"
{
    Properties
    {
        _MaskValue("MaskValue", int) = 0
        [NoScaleOffset] _MainTex("_MainTex", 2D) = "white" {}
        _Tiling("_Tiling", Vector) = (1, 1, 0, 0)
        _Color("_Color", Color) = (0, 0, 0, 0)
        _Offset("_Offset", Vector) = (0, 0, 0, 0)
        _Metallic("_Metallic", Float) = 0
        _Smoothness("_Smoothness", Float) = 0
        [NoScaleOffset]_NormalTex("_NormalTex", 2D) = "white" {}
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Stencil
        {
            Ref[_MaskValue]
            Comp equal
            Pass keep
        }
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Geometry"
            "DisableBatching" = "False"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz = input.sh;
            #endif
            output.interp7.xyzw = input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw = input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float2 _Tiling;
        float4 _Color;
        float _Metallic;
        float _Smoothness;
        float2 _Offset;
        float4 _NormalTex_TexelSize;
        CBUFFER_END


            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalTex);
            SAMPLER(sampler_NormalTex);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_be1c57220db84e7681df7a087f8f2d71_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                float4 _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be1c57220db84e7681df7a087f8f2d71_Out_0.tex, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.samplerstate, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_R_4 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.r;
                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_G_5 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.g;
                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_B_6 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.b;
                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_A_7 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.a;
                float4 _Property_89061ca830494771b73ac92e12e24353_Out_0 = _Color;
                float4 _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2;
                Unity_Multiply_float4_float4(_SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0, _Property_89061ca830494771b73ac92e12e24353_Out_0, _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2);
                UnityTexture2D _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0 = UnityBuildTexture2DStructNoScale(_NormalTex);
                float4 _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.tex, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.samplerstate, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0);
                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_R_4 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.r;
                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_G_5 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.g;
                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_B_6 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.b;
                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_A_7 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.a;
                float _Property_5a1d325afb704eb8b68c83b76272c9a7_Out_0 = _Metallic;
                float _Property_0f2d9a6bfbff40898f0529e3fd45805a_Out_0 = _Smoothness;
                surface.BaseColor = (_Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2.xyz);
                surface.NormalTS = (_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.xyz);
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = _Property_5a1d325afb704eb8b68c83b76272c9a7_Out_0;
                surface.Smoothness = _Property_0f2d9a6bfbff40898f0529e3fd45805a_Out_0;
                surface.Occlusion = 1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif


                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float2 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float3 interp6 : INTERP6;
                     float4 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    #if defined(LIGHTMAP_ON)
                    output.interp4.xy = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp5.xy = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz = input.sh;
                    #endif
                    output.interp7.xyzw = input.fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.interp8.xyzw = input.shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp4.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.interp8.xyzw;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float2 _Tiling;
                float4 _Color;
                float _Metallic;
                float _Smoothness;
                float2 _Offset;
                float4 _NormalTex_TexelSize;
                CBUFFER_END


                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_MainTex);
                    SAMPLER(sampler_MainTex);
                    TEXTURE2D(_NormalTex);
                    SAMPLER(sampler_NormalTex);

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }

                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A * B;
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float Metallic;
                        float Smoothness;
                        float Occlusion;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        UnityTexture2D _Property_be1c57220db84e7681df7a087f8f2d71_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                        float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                        float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                        float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                        float4 _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be1c57220db84e7681df7a087f8f2d71_Out_0.tex, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.samplerstate, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_R_4 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.r;
                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_G_5 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.g;
                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_B_6 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.b;
                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_A_7 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.a;
                        float4 _Property_89061ca830494771b73ac92e12e24353_Out_0 = _Color;
                        float4 _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2;
                        Unity_Multiply_float4_float4(_SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0, _Property_89061ca830494771b73ac92e12e24353_Out_0, _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2);
                        UnityTexture2D _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0 = UnityBuildTexture2DStructNoScale(_NormalTex);
                        float4 _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.tex, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.samplerstate, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                        _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0);
                        float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_R_4 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.r;
                        float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_G_5 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.g;
                        float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_B_6 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.b;
                        float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_A_7 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.a;
                        float _Property_5a1d325afb704eb8b68c83b76272c9a7_Out_0 = _Metallic;
                        float _Property_0f2d9a6bfbff40898f0529e3fd45805a_Out_0 = _Smoothness;
                        surface.BaseColor = (_Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2.xyz);
                        surface.NormalTS = (_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.xyz);
                        surface.Emission = float3(0, 0, 0);
                        surface.Metallic = _Property_5a1d325afb704eb8b68c83b76272c9a7_Out_0;
                        surface.Smoothness = _Property_0f2d9a6bfbff40898f0529e3fd45805a_Out_0;
                        surface.Occlusion = 1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif





                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                        #if UNITY_UV_STARTS_AT_TOP
                        #else
                        #endif


                        output.uv0 = input.texCoord0;
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull Back
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define VARYINGS_NEED_NORMAL_WS
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.normalWS = input.interp0.xyz;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _MainTex_TexelSize;
                        float2 _Tiling;
                        float4 _Color;
                        float _Metallic;
                        float _Smoothness;
                        float2 _Offset;
                        float4 _NormalTex_TexelSize;
                        CBUFFER_END


                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_MainTex);
                            SAMPLER(sampler_MainTex);
                            TEXTURE2D(_NormalTex);
                            SAMPLER(sampler_NormalTex);

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions
                            // GraphFunctions: <None>

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif








                                #if UNITY_UV_STARTS_AT_TOP
                                #else
                                #endif


                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthOnly"
                                Tags
                                {
                                    "LightMode" = "DepthOnly"
                                }

                                // Render State
                                Cull Back
                                ZTest LEqual
                                ZWrite On
                                ColorMask R

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma multi_compile_instancing
                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                #pragma vertex vert
                                #pragma fragment frag

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float4 _MainTex_TexelSize;
                                float2 _Tiling;
                                float4 _Color;
                                float _Metallic;
                                float _Smoothness;
                                float2 _Offset;
                                float4 _NormalTex_TexelSize;
                                CBUFFER_END


                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_MainTex);
                                    SAMPLER(sampler_MainTex);
                                    TEXTURE2D(_NormalTex);
                                    SAMPLER(sampler_NormalTex);

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions
                                    // GraphFunctions: <None>

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        description.Position = IN.ObjectSpacePosition;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif








                                        #if UNITY_UV_STARTS_AT_TOP
                                        #else
                                        #endif


                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "DepthNormals"
                                        Tags
                                        {
                                            "LightMode" = "DepthNormals"
                                        }

                                        // Render State
                                        Cull Back
                                        ZTest LEqual
                                        ZWrite On

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma multi_compile_instancing
                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // Keywords
                                        #pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv0 : TEXCOORD0;
                                             float4 uv1 : TEXCOORD1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 normalWS;
                                             float4 tangentWS;
                                             float4 texCoord0;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 TangentSpaceNormal;
                                             float4 uv0;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 interp0 : INTERP0;
                                             float4 interp1 : INTERP1;
                                             float4 interp2 : INTERP2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.normalWS;
                                            output.interp1.xyzw = input.tangentWS;
                                            output.interp2.xyzw = input.texCoord0;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.normalWS = input.interp0.xyz;
                                            output.tangentWS = input.interp1.xyzw;
                                            output.texCoord0 = input.interp2.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float4 _MainTex_TexelSize;
                                        float2 _Tiling;
                                        float4 _Color;
                                        float _Metallic;
                                        float _Smoothness;
                                        float2 _Offset;
                                        float4 _NormalTex_TexelSize;
                                        CBUFFER_END


                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_MainTex);
                                            SAMPLER(sampler_MainTex);
                                            TEXTURE2D(_NormalTex);
                                            SAMPLER(sampler_NormalTex);

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                description.Position = IN.ObjectSpacePosition;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 NormalTS;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                UnityTexture2D _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0 = UnityBuildTexture2DStructNoScale(_NormalTex);
                                                float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                                                float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                                                float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                                                float4 _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.tex, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.samplerstate, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                                                _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0);
                                                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_R_4 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.r;
                                                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_G_5 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.g;
                                                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_B_6 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.b;
                                                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_A_7 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.a;
                                                surface.NormalTS = (_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.xyz);
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif





                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                                                #if UNITY_UV_STARTS_AT_TOP
                                                #else
                                                #endif


                                                output.uv0 = input.texCoord0;
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "Meta"
                                                Tags
                                                {
                                                    "LightMode" = "Meta"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 4.5
                                                #pragma exclude_renderers gles gles3 glcore
                                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // Keywords
                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_TEXCOORD1
                                                #define VARYINGS_NEED_TEXCOORD2
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_META
                                                #define _FOG_FRAGMENT 1
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv0 : TEXCOORD0;
                                                     float4 uv1 : TEXCOORD1;
                                                     float4 uv2 : TEXCOORD2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float4 texCoord0;
                                                     float4 texCoord1;
                                                     float4 texCoord2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float4 uv0;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float4 interp0 : INTERP0;
                                                     float4 interp1 : INTERP1;
                                                     float4 interp2 : INTERP2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyzw = input.texCoord0;
                                                    output.interp1.xyzw = input.texCoord1;
                                                    output.interp2.xyzw = input.texCoord2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.texCoord0 = input.interp0.xyzw;
                                                    output.texCoord1 = input.interp1.xyzw;
                                                    output.texCoord2 = input.interp2.xyzw;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float4 _MainTex_TexelSize;
                                                float2 _Tiling;
                                                float4 _Color;
                                                float _Metallic;
                                                float _Smoothness;
                                                float2 _Offset;
                                                float4 _NormalTex_TexelSize;
                                                CBUFFER_END


                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_MainTex);
                                                    SAMPLER(sampler_MainTex);
                                                    TEXTURE2D(_NormalTex);
                                                    SAMPLER(sampler_NormalTex);

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }

                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        description.Position = IN.ObjectSpacePosition;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float3 BaseColor;
                                                        float3 Emission;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        UnityTexture2D _Property_be1c57220db84e7681df7a087f8f2d71_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                        float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                                                        float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                                                        float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                                                        float4 _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be1c57220db84e7681df7a087f8f2d71_Out_0.tex, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.samplerstate, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_R_4 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.r;
                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_G_5 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.g;
                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_B_6 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.b;
                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_A_7 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.a;
                                                        float4 _Property_89061ca830494771b73ac92e12e24353_Out_0 = _Color;
                                                        float4 _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2;
                                                        Unity_Multiply_float4_float4(_SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0, _Property_89061ca830494771b73ac92e12e24353_Out_0, _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2);
                                                        surface.BaseColor = (_Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2.xyz);
                                                        surface.Emission = float3(0, 0, 0);
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif








                                                        #if UNITY_UV_STARTS_AT_TOP
                                                        #else
                                                        #endif


                                                        output.uv0 = input.texCoord0;
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "SceneSelectionPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "SceneSelectionPass"
                                                        }

                                                        // Render State
                                                        Cull Off

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 4.5
                                                        #pragma exclude_renderers gles gles3 glcore
                                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENESELECTIONPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float4 _MainTex_TexelSize;
                                                        float2 _Tiling;
                                                        float4 _Color;
                                                        float _Metallic;
                                                        float _Smoothness;
                                                        float2 _Offset;
                                                        float4 _NormalTex_TexelSize;
                                                        CBUFFER_END


                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_MainTex);
                                                            SAMPLER(sampler_MainTex);
                                                            TEXTURE2D(_NormalTex);
                                                            SAMPLER(sampler_NormalTex);

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions
                                                            // GraphFunctions: <None>

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                description.Position = IN.ObjectSpacePosition;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif








                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                #else
                                                                #endif


                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                Name "ScenePickingPass"
                                                                Tags
                                                                {
                                                                    "LightMode" = "Picking"
                                                                }

                                                                // Render State
                                                                Cull Back

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 4.5
                                                                #pragma exclude_renderers gles gles3 glcore
                                                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                #define SCENEPICKINGPASS 1
                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float4 _MainTex_TexelSize;
                                                                float2 _Tiling;
                                                                float4 _Color;
                                                                float _Metallic;
                                                                float _Smoothness;
                                                                float2 _Offset;
                                                                float4 _NormalTex_TexelSize;
                                                                CBUFFER_END


                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_MainTex);
                                                                    SAMPLER(sampler_MainTex);
                                                                    TEXTURE2D(_NormalTex);
                                                                    SAMPLER(sampler_NormalTex);

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions
                                                                    // GraphFunctions: <None>

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        description.Position = IN.ObjectSpacePosition;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif








                                                                        #if UNITY_UV_STARTS_AT_TOP
                                                                        #else
                                                                        #endif


                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
                                                                    Pass
                                                                    {
                                                                        // Name: <None>
                                                                        Tags
                                                                        {
                                                                            "LightMode" = "Universal2D"
                                                                        }

                                                                        // Render State
                                                                        Cull Back
                                                                        Blend One Zero
                                                                        ZTest LEqual
                                                                        ZWrite On

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 4.5
                                                                        #pragma exclude_renderers gles gles3 glcore
                                                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // Keywords
                                                                        // PassKeywords: <None>
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_2D
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv0 : TEXCOORD0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float4 texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float4 uv0;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float4 interp0 : INTERP0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyzw = input.texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.texCoord0 = input.interp0.xyzw;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float4 _MainTex_TexelSize;
                                                                        float2 _Tiling;
                                                                        float4 _Color;
                                                                        float _Metallic;
                                                                        float _Smoothness;
                                                                        float2 _Offset;
                                                                        float4 _NormalTex_TexelSize;
                                                                        CBUFFER_END


                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_MainTex);
                                                                            SAMPLER(sampler_MainTex);
                                                                            TEXTURE2D(_NormalTex);
                                                                            SAMPLER(sampler_NormalTex);

                                                                            // Graph Includes
                                                                            // GraphIncludes: <None>

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }

                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                UnityTexture2D _Property_be1c57220db84e7681df7a087f8f2d71_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                                                                                float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                                                                                float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                                                                                float4 _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be1c57220db84e7681df7a087f8f2d71_Out_0.tex, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.samplerstate, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                                                                                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_R_4 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.r;
                                                                                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_G_5 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.g;
                                                                                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_B_6 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.b;
                                                                                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_A_7 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.a;
                                                                                float4 _Property_89061ca830494771b73ac92e12e24353_Out_0 = _Color;
                                                                                float4 _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2;
                                                                                Unity_Multiply_float4_float4(_SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0, _Property_89061ca830494771b73ac92e12e24353_Out_0, _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2);
                                                                                surface.BaseColor = (_Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2.xyz);
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif








                                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                                #else
                                                                                #endif


                                                                                output.uv0 = input.texCoord0;
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
    }
        SubShader
                                                                            {
                                                                                Tags
                                                                                {
                                                                                    "RenderPipeline" = "UniversalPipeline"
                                                                                    "RenderType" = "Opaque"
                                                                                    "UniversalMaterialType" = "Lit"
                                                                                    "Queue" = "Geometry"
                                                                                    "DisableBatching" = "False"
                                                                                    "ShaderGraphShader" = "true"
                                                                                    "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                                                                }
                                                                                Pass
                                                                                {
                                                                                    Name "Universal Forward"
                                                                                    Tags
                                                                                    {
                                                                                        "LightMode" = "UniversalForward"
                                                                                    }

                                                                                // Render State
                                                                                Cull Back
                                                                                Blend One Zero
                                                                                ZTest LEqual
                                                                                ZWrite On

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 2.0
                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                #pragma multi_compile_instancing
                                                                                #pragma multi_compile_fog
                                                                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                                #pragma target 3.5 DOTS_INSTANCING_ON
                                                                                #pragma instancing_options renderinglayer
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // Keywords
                                                                                #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                                                                #pragma multi_compile _ LIGHTMAP_ON
                                                                                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                                                                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                                #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                                                                #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                                                                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                                                                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                                                                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                                                                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                                #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                                                                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                                                                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                                                                #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                                                                #pragma multi_compile _ _FORWARD_PLUS
                                                                                // GraphKeywords: <None>

                                                                                // Defines

                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                #define VARYINGS_NEED_TANGENT_WS
                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                #define VARYINGS_NEED_SHADOW_COORD
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_FORWARD
                                                                                #define _FOG_FRAGMENT 1
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                // custom interpolator pre-include
                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                // custom interpolators pre packing
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                struct Attributes
                                                                                {
                                                                                     float3 positionOS : POSITION;
                                                                                     float3 normalOS : NORMAL;
                                                                                     float4 tangentOS : TANGENT;
                                                                                     float4 uv0 : TEXCOORD0;
                                                                                     float4 uv1 : TEXCOORD1;
                                                                                     float4 uv2 : TEXCOORD2;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 positionWS;
                                                                                     float3 normalWS;
                                                                                     float4 tangentWS;
                                                                                     float4 texCoord0;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                     float2 staticLightmapUV;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                     float2 dynamicLightmapUV;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                     float3 sh;
                                                                                    #endif
                                                                                     float4 fogFactorAndVertexLight;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                     float4 shadowCoord;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                     float3 TangentSpaceNormal;
                                                                                     float4 uv0;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                     float3 ObjectSpaceNormal;
                                                                                     float3 ObjectSpaceTangent;
                                                                                     float3 ObjectSpacePosition;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 interp0 : INTERP0;
                                                                                     float3 interp1 : INTERP1;
                                                                                     float4 interp2 : INTERP2;
                                                                                     float4 interp3 : INTERP3;
                                                                                     float2 interp4 : INTERP4;
                                                                                     float2 interp5 : INTERP5;
                                                                                     float3 interp6 : INTERP6;
                                                                                     float4 interp7 : INTERP7;
                                                                                     float4 interp8 : INTERP8;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyz = input.positionWS;
                                                                                    output.interp1.xyz = input.normalWS;
                                                                                    output.interp2.xyzw = input.tangentWS;
                                                                                    output.interp3.xyzw = input.texCoord0;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    output.interp4.xy = input.staticLightmapUV;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                    output.interp5.xy = input.dynamicLightmapUV;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                    output.interp6.xyz = input.sh;
                                                                                    #endif
                                                                                    output.interp7.xyzw = input.fogFactorAndVertexLight;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                    output.interp8.xyzw = input.shadowCoord;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.positionWS = input.interp0.xyz;
                                                                                    output.normalWS = input.interp1.xyz;
                                                                                    output.tangentWS = input.interp2.xyzw;
                                                                                    output.texCoord0 = input.interp3.xyzw;
                                                                                    #if defined(LIGHTMAP_ON)
                                                                                    output.staticLightmapUV = input.interp4.xy;
                                                                                    #endif
                                                                                    #if defined(DYNAMICLIGHTMAP_ON)
                                                                                    output.dynamicLightmapUV = input.interp5.xy;
                                                                                    #endif
                                                                                    #if !defined(LIGHTMAP_ON)
                                                                                    output.sh = input.interp6.xyz;
                                                                                    #endif
                                                                                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                                                                                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                                    output.shadowCoord = input.interp8.xyzw;
                                                                                    #endif
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }


                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float4 _MainTex_TexelSize;
                                                                                float2 _Tiling;
                                                                                float4 _Color;
                                                                                float _Metallic;
                                                                                float _Smoothness;
                                                                                float2 _Offset;
                                                                                float4 _NormalTex_TexelSize;
                                                                                CBUFFER_END


                                                                                    // Object and Global properties
                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                    TEXTURE2D(_MainTex);
                                                                                    SAMPLER(sampler_MainTex);
                                                                                    TEXTURE2D(_NormalTex);
                                                                                    SAMPLER(sampler_NormalTex);

                                                                                    // Graph Includes
                                                                                    // GraphIncludes: <None>

                                                                                    // -- Property used by ScenePickingPass
                                                                                    #ifdef SCENEPICKINGPASS
                                                                                    float4 _SelectionID;
                                                                                    #endif

                                                                                    // -- Properties used by SceneSelectionPass
                                                                                    #ifdef SCENESELECTIONPASS
                                                                                    int _ObjectId;
                                                                                    int _PassValue;
                                                                                    #endif

                                                                                    // Graph Functions

                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                    {
                                                                                        Out = UV * Tiling + Offset;
                                                                                    }

                                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    // Custom interpolators pre vertex
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Custom interpolators, pre surface
                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                    {
                                                                                    return output;
                                                                                    }
                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                    #endif

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float3 BaseColor;
                                                                                        float3 NormalTS;
                                                                                        float3 Emission;
                                                                                        float Metallic;
                                                                                        float Smoothness;
                                                                                        float Occlusion;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        UnityTexture2D _Property_be1c57220db84e7681df7a087f8f2d71_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                        float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                                                                                        float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                                                                                        float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                                                                                        float4 _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be1c57220db84e7681df7a087f8f2d71_Out_0.tex, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.samplerstate, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                                                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_R_4 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.r;
                                                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_G_5 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.g;
                                                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_B_6 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.b;
                                                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_A_7 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.a;
                                                                                        float4 _Property_89061ca830494771b73ac92e12e24353_Out_0 = _Color;
                                                                                        float4 _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2;
                                                                                        Unity_Multiply_float4_float4(_SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0, _Property_89061ca830494771b73ac92e12e24353_Out_0, _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2);
                                                                                        UnityTexture2D _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0 = UnityBuildTexture2DStructNoScale(_NormalTex);
                                                                                        float4 _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.tex, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.samplerstate, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                                                                                        _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0);
                                                                                        float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_R_4 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.r;
                                                                                        float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_G_5 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.g;
                                                                                        float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_B_6 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.b;
                                                                                        float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_A_7 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.a;
                                                                                        float _Property_5a1d325afb704eb8b68c83b76272c9a7_Out_0 = _Metallic;
                                                                                        float _Property_0f2d9a6bfbff40898f0529e3fd45805a_Out_0 = _Smoothness;
                                                                                        surface.BaseColor = (_Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2.xyz);
                                                                                        surface.NormalTS = (_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.xyz);
                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                        surface.Metallic = _Property_5a1d325afb704eb8b68c83b76272c9a7_Out_0;
                                                                                        surface.Smoothness = _Property_0f2d9a6bfbff40898f0529e3fd45805a_Out_0;
                                                                                        surface.Occlusion = 1;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                    #endif
                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                        return output;
                                                                                    }
                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                    #endif





                                                                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                                                                                        #if UNITY_UV_STARTS_AT_TOP
                                                                                        #else
                                                                                        #endif


                                                                                        output.uv0 = input.texCoord0;
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                            return output;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                                    // --------------------------------------------------
                                                                                    // Visual Effect Vertex Invocations
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                    #endif

                                                                                    ENDHLSL
                                                                                    }
                                                                                    Pass
                                                                                    {
                                                                                        Name "ShadowCaster"
                                                                                        Tags
                                                                                        {
                                                                                            "LightMode" = "ShadowCaster"
                                                                                        }

                                                                                        // Render State
                                                                                        Cull Back
                                                                                        ZTest LEqual
                                                                                        ZWrite On
                                                                                        ColorMask 0

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 2.0
                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                        #pragma multi_compile_instancing
                                                                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                                        #pragma target 3.5 DOTS_INSTANCING_ON
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // Keywords
                                                                                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines

                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                        // custom interpolator pre-include
                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        // custom interpolators pre packing
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                        struct Attributes
                                                                                        {
                                                                                             float3 positionOS : POSITION;
                                                                                             float3 normalOS : NORMAL;
                                                                                             float4 tangentOS : TANGENT;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 normalWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                             float3 ObjectSpaceNormal;
                                                                                             float3 ObjectSpaceTangent;
                                                                                             float3 ObjectSpacePosition;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 interp0 : INTERP0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.normalWS;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.normalWS = input.interp0.xyz;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }


                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float4 _MainTex_TexelSize;
                                                                                        float2 _Tiling;
                                                                                        float4 _Color;
                                                                                        float _Metallic;
                                                                                        float _Smoothness;
                                                                                        float2 _Offset;
                                                                                        float4 _NormalTex_TexelSize;
                                                                                        CBUFFER_END


                                                                                            // Object and Global properties
                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                            TEXTURE2D(_MainTex);
                                                                                            SAMPLER(sampler_MainTex);
                                                                                            TEXTURE2D(_NormalTex);
                                                                                            SAMPLER(sampler_NormalTex);

                                                                                            // Graph Includes
                                                                                            // GraphIncludes: <None>

                                                                                            // -- Property used by ScenePickingPass
                                                                                            #ifdef SCENEPICKINGPASS
                                                                                            float4 _SelectionID;
                                                                                            #endif

                                                                                            // -- Properties used by SceneSelectionPass
                                                                                            #ifdef SCENESELECTIONPASS
                                                                                            int _ObjectId;
                                                                                            int _PassValue;
                                                                                            #endif

                                                                                            // Graph Functions
                                                                                            // GraphFunctions: <None>

                                                                                            // Custom interpolators pre vertex
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Custom interpolators, pre surface
                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                            {
                                                                                            return output;
                                                                                            }
                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                            #endif

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                            #endif
                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                return output;
                                                                                            }
                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                            #endif








                                                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                                                #else
                                                                                                #endif


                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                    return output;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                                            // --------------------------------------------------
                                                                                            // Visual Effect Vertex Invocations
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                            #endif

                                                                                            ENDHLSL
                                                                                            }
                                                                                            Pass
                                                                                            {
                                                                                                Name "DepthOnly"
                                                                                                Tags
                                                                                                {
                                                                                                    "LightMode" = "DepthOnly"
                                                                                                }

                                                                                                // Render State
                                                                                                Cull Back
                                                                                                ZTest LEqual
                                                                                                ZWrite On
                                                                                                ColorMask R

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 2.0
                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                #pragma multi_compile_instancing
                                                                                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                                                #pragma target 3.5 DOTS_INSTANCING_ON
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // Keywords
                                                                                                // PassKeywords: <None>
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines

                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                // custom interpolator pre-include
                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                // custom interpolators pre packing
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                struct Attributes
                                                                                                {
                                                                                                     float3 positionOS : POSITION;
                                                                                                     float3 normalOS : NORMAL;
                                                                                                     float4 tangentOS : TANGENT;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                     float3 ObjectSpaceNormal;
                                                                                                     float3 ObjectSpaceTangent;
                                                                                                     float3 ObjectSpacePosition;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }


                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float4 _MainTex_TexelSize;
                                                                                                float2 _Tiling;
                                                                                                float4 _Color;
                                                                                                float _Metallic;
                                                                                                float _Smoothness;
                                                                                                float2 _Offset;
                                                                                                float4 _NormalTex_TexelSize;
                                                                                                CBUFFER_END


                                                                                                    // Object and Global properties
                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                    TEXTURE2D(_MainTex);
                                                                                                    SAMPLER(sampler_MainTex);
                                                                                                    TEXTURE2D(_NormalTex);
                                                                                                    SAMPLER(sampler_NormalTex);

                                                                                                    // Graph Includes
                                                                                                    // GraphIncludes: <None>

                                                                                                    // -- Property used by ScenePickingPass
                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                    float4 _SelectionID;
                                                                                                    #endif

                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                    int _ObjectId;
                                                                                                    int _PassValue;
                                                                                                    #endif

                                                                                                    // Graph Functions
                                                                                                    // GraphFunctions: <None>

                                                                                                    // Custom interpolators pre vertex
                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                    // Graph Vertex
                                                                                                    struct VertexDescription
                                                                                                    {
                                                                                                        float3 Position;
                                                                                                        float3 Normal;
                                                                                                        float3 Tangent;
                                                                                                    };

                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                    {
                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                        return description;
                                                                                                    }

                                                                                                    // Custom interpolators, pre surface
                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                    {
                                                                                                    return output;
                                                                                                    }
                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                    #endif

                                                                                                    // Graph Pixel
                                                                                                    struct SurfaceDescription
                                                                                                    {
                                                                                                    };

                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                    {
                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                        return surface;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Build Graph Inputs
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                    #endif
                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                    {
                                                                                                        VertexDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                        return output;
                                                                                                    }
                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                    #endif








                                                                                                        #if UNITY_UV_STARTS_AT_TOP
                                                                                                        #else
                                                                                                        #endif


                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                    #else
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                    #endif
                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                            return output;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Main

                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                                                    // --------------------------------------------------
                                                                                                    // Visual Effect Vertex Invocations
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                    #endif

                                                                                                    ENDHLSL
                                                                                                    }
                                                                                                    Pass
                                                                                                    {
                                                                                                        Name "DepthNormals"
                                                                                                        Tags
                                                                                                        {
                                                                                                            "LightMode" = "DepthNormals"
                                                                                                        }

                                                                                                        // Render State
                                                                                                        Cull Back
                                                                                                        ZTest LEqual
                                                                                                        ZWrite On

                                                                                                        // Debug
                                                                                                        // <None>

                                                                                                        // --------------------------------------------------
                                                                                                        // Pass

                                                                                                        HLSLPROGRAM

                                                                                                        // Pragmas
                                                                                                        #pragma target 2.0
                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                        #pragma multi_compile_instancing
                                                                                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                                                        #pragma target 3.5 DOTS_INSTANCING_ON
                                                                                                        #pragma vertex vert
                                                                                                        #pragma fragment frag

                                                                                                        // Keywords
                                                                                                        // PassKeywords: <None>
                                                                                                        // GraphKeywords: <None>

                                                                                                        // Defines

                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                        // custom interpolator pre-include
                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                        // Includes
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                        // --------------------------------------------------
                                                                                                        // Structs and Packing

                                                                                                        // custom interpolators pre packing
                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                        struct Attributes
                                                                                                        {
                                                                                                             float3 positionOS : POSITION;
                                                                                                             float3 normalOS : NORMAL;
                                                                                                             float4 tangentOS : TANGENT;
                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                             float4 uv1 : TEXCOORD1;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 normalWS;
                                                                                                             float4 tangentWS;
                                                                                                             float4 texCoord0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct SurfaceDescriptionInputs
                                                                                                        {
                                                                                                             float3 TangentSpaceNormal;
                                                                                                             float4 uv0;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                             float3 ObjectSpaceNormal;
                                                                                                             float3 ObjectSpaceTangent;
                                                                                                             float3 ObjectSpacePosition;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 interp0 : INTERP0;
                                                                                                             float4 interp1 : INTERP1;
                                                                                                             float4 interp2 : INTERP2;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };

                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                        {
                                                                                                            PackedVaryings output;
                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.interp0.xyz = input.normalWS;
                                                                                                            output.interp1.xyzw = input.tangentWS;
                                                                                                            output.interp2.xyzw = input.texCoord0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }

                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                        {
                                                                                                            Varyings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.normalWS = input.interp0.xyz;
                                                                                                            output.tangentWS = input.interp1.xyzw;
                                                                                                            output.texCoord0 = input.interp2.xyzw;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }


                                                                                                        // --------------------------------------------------
                                                                                                        // Graph

                                                                                                        // Graph Properties
                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                        float4 _MainTex_TexelSize;
                                                                                                        float2 _Tiling;
                                                                                                        float4 _Color;
                                                                                                        float _Metallic;
                                                                                                        float _Smoothness;
                                                                                                        float2 _Offset;
                                                                                                        float4 _NormalTex_TexelSize;
                                                                                                        CBUFFER_END


                                                                                                            // Object and Global properties
                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                            TEXTURE2D(_MainTex);
                                                                                                            SAMPLER(sampler_MainTex);
                                                                                                            TEXTURE2D(_NormalTex);
                                                                                                            SAMPLER(sampler_NormalTex);

                                                                                                            // Graph Includes
                                                                                                            // GraphIncludes: <None>

                                                                                                            // -- Property used by ScenePickingPass
                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                            float4 _SelectionID;
                                                                                                            #endif

                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                            int _ObjectId;
                                                                                                            int _PassValue;
                                                                                                            #endif

                                                                                                            // Graph Functions

                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                            {
                                                                                                                Out = UV * Tiling + Offset;
                                                                                                            }

                                                                                                            // Custom interpolators pre vertex
                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                            // Graph Vertex
                                                                                                            struct VertexDescription
                                                                                                            {
                                                                                                                float3 Position;
                                                                                                                float3 Normal;
                                                                                                                float3 Tangent;
                                                                                                            };

                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                            {
                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                return description;
                                                                                                            }

                                                                                                            // Custom interpolators, pre surface
                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                            {
                                                                                                            return output;
                                                                                                            }
                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                            #endif

                                                                                                            // Graph Pixel
                                                                                                            struct SurfaceDescription
                                                                                                            {
                                                                                                                float3 NormalTS;
                                                                                                            };

                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                            {
                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                UnityTexture2D _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0 = UnityBuildTexture2DStructNoScale(_NormalTex);
                                                                                                                float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                                                                                                                float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                                                                                                                float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                                                                                                                float4 _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0 = SAMPLE_TEXTURE2D(_Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.tex, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.samplerstate, _Property_da212546ff3b4f9da22ee3dfafb15f19_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                                                                                                                _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0);
                                                                                                                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_R_4 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.r;
                                                                                                                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_G_5 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.g;
                                                                                                                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_B_6 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.b;
                                                                                                                float _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_A_7 = _SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.a;
                                                                                                                surface.NormalTS = (_SampleTexture2D_0fe588ccb7144a369476bb95adff1701_RGBA_0.xyz);
                                                                                                                return surface;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Build Graph Inputs
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                            #endif
                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                            {
                                                                                                                VertexDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                return output;
                                                                                                            }
                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                            #endif





                                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                                                                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                                                                #else
                                                                                                                #endif


                                                                                                                output.uv0 = input.texCoord0;
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                            #else
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                            #endif
                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                    return output;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Main

                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                                                                            // --------------------------------------------------
                                                                                                            // Visual Effect Vertex Invocations
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                            #endif

                                                                                                            ENDHLSL
                                                                                                            }
                                                                                                            Pass
                                                                                                            {
                                                                                                                Name "Meta"
                                                                                                                Tags
                                                                                                                {
                                                                                                                    "LightMode" = "Meta"
                                                                                                                }

                                                                                                                // Render State
                                                                                                                Cull Off

                                                                                                                // Debug
                                                                                                                // <None>

                                                                                                                // --------------------------------------------------
                                                                                                                // Pass

                                                                                                                HLSLPROGRAM

                                                                                                                // Pragmas
                                                                                                                #pragma target 2.0
                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                                                                #pragma target 3.5 DOTS_INSTANCING_ON
                                                                                                                #pragma vertex vert
                                                                                                                #pragma fragment frag

                                                                                                                // Keywords
                                                                                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                                                                                // GraphKeywords: <None>

                                                                                                                // Defines

                                                                                                                #define _NORMALMAP 1
                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                                #define VARYINGS_NEED_TEXCOORD1
                                                                                                                #define VARYINGS_NEED_TEXCOORD2
                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                #define SHADERPASS SHADERPASS_META
                                                                                                                #define _FOG_FRAGMENT 1
                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                // custom interpolator pre-include
                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                // Includes
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                // --------------------------------------------------
                                                                                                                // Structs and Packing

                                                                                                                // custom interpolators pre packing
                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                struct Attributes
                                                                                                                {
                                                                                                                     float3 positionOS : POSITION;
                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                                     float4 uv1 : TEXCOORD1;
                                                                                                                     float4 uv2 : TEXCOORD2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct Varyings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float4 texCoord0;
                                                                                                                     float4 texCoord1;
                                                                                                                     float4 texCoord2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                {
                                                                                                                     float4 uv0;
                                                                                                                };
                                                                                                                struct VertexDescriptionInputs
                                                                                                                {
                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                };
                                                                                                                struct PackedVaryings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float4 interp0 : INTERP0;
                                                                                                                     float4 interp1 : INTERP1;
                                                                                                                     float4 interp2 : INTERP2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };

                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                {
                                                                                                                    PackedVaryings output;
                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.interp0.xyzw = input.texCoord0;
                                                                                                                    output.interp1.xyzw = input.texCoord1;
                                                                                                                    output.interp2.xyzw = input.texCoord2;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }

                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                {
                                                                                                                    Varyings output;
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.texCoord0 = input.interp0.xyzw;
                                                                                                                    output.texCoord1 = input.interp1.xyzw;
                                                                                                                    output.texCoord2 = input.interp2.xyzw;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }


                                                                                                                // --------------------------------------------------
                                                                                                                // Graph

                                                                                                                // Graph Properties
                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                float4 _MainTex_TexelSize;
                                                                                                                float2 _Tiling;
                                                                                                                float4 _Color;
                                                                                                                float _Metallic;
                                                                                                                float _Smoothness;
                                                                                                                float2 _Offset;
                                                                                                                float4 _NormalTex_TexelSize;
                                                                                                                CBUFFER_END


                                                                                                                    // Object and Global properties
                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                    TEXTURE2D(_MainTex);
                                                                                                                    SAMPLER(sampler_MainTex);
                                                                                                                    TEXTURE2D(_NormalTex);
                                                                                                                    SAMPLER(sampler_NormalTex);

                                                                                                                    // Graph Includes
                                                                                                                    // GraphIncludes: <None>

                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                    float4 _SelectionID;
                                                                                                                    #endif

                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                    int _ObjectId;
                                                                                                                    int _PassValue;
                                                                                                                    #endif

                                                                                                                    // Graph Functions

                                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = UV * Tiling + Offset;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = A * B;
                                                                                                                    }

                                                                                                                    // Custom interpolators pre vertex
                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                    // Graph Vertex
                                                                                                                    struct VertexDescription
                                                                                                                    {
                                                                                                                        float3 Position;
                                                                                                                        float3 Normal;
                                                                                                                        float3 Tangent;
                                                                                                                    };

                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                        return description;
                                                                                                                    }

                                                                                                                    // Custom interpolators, pre surface
                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                    {
                                                                                                                    return output;
                                                                                                                    }
                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                    #endif

                                                                                                                    // Graph Pixel
                                                                                                                    struct SurfaceDescription
                                                                                                                    {
                                                                                                                        float3 BaseColor;
                                                                                                                        float3 Emission;
                                                                                                                    };

                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                        UnityTexture2D _Property_be1c57220db84e7681df7a087f8f2d71_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                                        float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                                                                                                                        float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                                                                                                                        float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                                                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                                                                                                                        float4 _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be1c57220db84e7681df7a087f8f2d71_Out_0.tex, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.samplerstate, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                                                                                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_R_4 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.r;
                                                                                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_G_5 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.g;
                                                                                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_B_6 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.b;
                                                                                                                        float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_A_7 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.a;
                                                                                                                        float4 _Property_89061ca830494771b73ac92e12e24353_Out_0 = _Color;
                                                                                                                        float4 _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2;
                                                                                                                        Unity_Multiply_float4_float4(_SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0, _Property_89061ca830494771b73ac92e12e24353_Out_0, _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2);
                                                                                                                        surface.BaseColor = (_Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2.xyz);
                                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                                        return surface;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Build Graph Inputs
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                    #endif
                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                    {
                                                                                                                        VertexDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                                        return output;
                                                                                                                    }
                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                    {
                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                    #endif








                                                                                                                        #if UNITY_UV_STARTS_AT_TOP
                                                                                                                        #else
                                                                                                                        #endif


                                                                                                                        output.uv0 = input.texCoord0;
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                    #else
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                    #endif
                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                            return output;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Main

                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                    #endif

                                                                                                                    ENDHLSL
                                                                                                                    }
                                                                                                                    Pass
                                                                                                                    {
                                                                                                                        Name "SceneSelectionPass"
                                                                                                                        Tags
                                                                                                                        {
                                                                                                                            "LightMode" = "SceneSelectionPass"
                                                                                                                        }

                                                                                                                        // Render State
                                                                                                                        Cull Off

                                                                                                                        // Debug
                                                                                                                        // <None>

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Pass

                                                                                                                        HLSLPROGRAM

                                                                                                                        // Pragmas
                                                                                                                        #pragma target 2.0
                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                        #pragma multi_compile_instancing
                                                                                                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                                                                        #pragma target 3.5 DOTS_INSTANCING_ON
                                                                                                                        #pragma vertex vert
                                                                                                                        #pragma fragment frag

                                                                                                                        // Keywords
                                                                                                                        // PassKeywords: <None>
                                                                                                                        // GraphKeywords: <None>

                                                                                                                        // Defines

                                                                                                                        #define _NORMALMAP 1
                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                        #define SCENESELECTIONPASS 1
                                                                                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                        // custom interpolator pre-include
                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                        // Includes
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Structs and Packing

                                                                                                                        // custom interpolators pre packing
                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                        struct Attributes
                                                                                                                        {
                                                                                                                             float3 positionOS : POSITION;
                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct Varyings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                        {
                                                                                                                        };
                                                                                                                        struct VertexDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                        };
                                                                                                                        struct PackedVaryings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };

                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                        {
                                                                                                                            PackedVaryings output;
                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }

                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                        {
                                                                                                                            Varyings output;
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }


                                                                                                                        // --------------------------------------------------
                                                                                                                        // Graph

                                                                                                                        // Graph Properties
                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                        float4 _MainTex_TexelSize;
                                                                                                                        float2 _Tiling;
                                                                                                                        float4 _Color;
                                                                                                                        float _Metallic;
                                                                                                                        float _Smoothness;
                                                                                                                        float2 _Offset;
                                                                                                                        float4 _NormalTex_TexelSize;
                                                                                                                        CBUFFER_END


                                                                                                                            // Object and Global properties
                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                            TEXTURE2D(_MainTex);
                                                                                                                            SAMPLER(sampler_MainTex);
                                                                                                                            TEXTURE2D(_NormalTex);
                                                                                                                            SAMPLER(sampler_NormalTex);

                                                                                                                            // Graph Includes
                                                                                                                            // GraphIncludes: <None>

                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                            float4 _SelectionID;
                                                                                                                            #endif

                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                            int _ObjectId;
                                                                                                                            int _PassValue;
                                                                                                                            #endif

                                                                                                                            // Graph Functions
                                                                                                                            // GraphFunctions: <None>

                                                                                                                            // Custom interpolators pre vertex
                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                            // Graph Vertex
                                                                                                                            struct VertexDescription
                                                                                                                            {
                                                                                                                                float3 Position;
                                                                                                                                float3 Normal;
                                                                                                                                float3 Tangent;
                                                                                                                            };

                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                return description;
                                                                                                                            }

                                                                                                                            // Custom interpolators, pre surface
                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                            {
                                                                                                                            return output;
                                                                                                                            }
                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                            #endif

                                                                                                                            // Graph Pixel
                                                                                                                            struct SurfaceDescription
                                                                                                                            {
                                                                                                                            };

                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                return surface;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Build Graph Inputs
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                            #endif
                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                            {
                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                                return output;
                                                                                                                            }
                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                            {
                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                            #endif








                                                                                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                                                                                #else
                                                                                                                                #endif


                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                            #else
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                            #endif
                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                    return output;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Main

                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                            #endif

                                                                                                                            ENDHLSL
                                                                                                                            }
                                                                                                                            Pass
                                                                                                                            {
                                                                                                                                Name "ScenePickingPass"
                                                                                                                                Tags
                                                                                                                                {
                                                                                                                                    "LightMode" = "Picking"
                                                                                                                                }

                                                                                                                                // Render State
                                                                                                                                Cull Back

                                                                                                                                // Debug
                                                                                                                                // <None>

                                                                                                                                // --------------------------------------------------
                                                                                                                                // Pass

                                                                                                                                HLSLPROGRAM

                                                                                                                                // Pragmas
                                                                                                                                #pragma target 2.0
                                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                                #pragma multi_compile_instancing
                                                                                                                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                                                                                #pragma target 3.5 DOTS_INSTANCING_ON
                                                                                                                                #pragma vertex vert
                                                                                                                                #pragma fragment frag

                                                                                                                                // Keywords
                                                                                                                                // PassKeywords: <None>
                                                                                                                                // GraphKeywords: <None>

                                                                                                                                // Defines

                                                                                                                                #define _NORMALMAP 1
                                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                                #define SCENEPICKINGPASS 1
                                                                                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                                // custom interpolator pre-include
                                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                                // Includes
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                                // --------------------------------------------------
                                                                                                                                // Structs and Packing

                                                                                                                                // custom interpolators pre packing
                                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                                struct Attributes
                                                                                                                                {
                                                                                                                                     float3 positionOS : POSITION;
                                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };
                                                                                                                                struct Varyings
                                                                                                                                {
                                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };
                                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                                {
                                                                                                                                };
                                                                                                                                struct VertexDescriptionInputs
                                                                                                                                {
                                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                                };
                                                                                                                                struct PackedVaryings
                                                                                                                                {
                                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                    #endif
                                                                                                                                };

                                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                                {
                                                                                                                                    PackedVaryings output;
                                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                                    #endif
                                                                                                                                    return output;
                                                                                                                                }

                                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                                {
                                                                                                                                    Varyings output;
                                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                    #endif
                                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                    #endif
                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                                    #endif
                                                                                                                                    return output;
                                                                                                                                }


                                                                                                                                // --------------------------------------------------
                                                                                                                                // Graph

                                                                                                                                // Graph Properties
                                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                                float4 _MainTex_TexelSize;
                                                                                                                                float2 _Tiling;
                                                                                                                                float4 _Color;
                                                                                                                                float _Metallic;
                                                                                                                                float _Smoothness;
                                                                                                                                float2 _Offset;
                                                                                                                                float4 _NormalTex_TexelSize;
                                                                                                                                CBUFFER_END


                                                                                                                                    // Object and Global properties
                                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                                    TEXTURE2D(_MainTex);
                                                                                                                                    SAMPLER(sampler_MainTex);
                                                                                                                                    TEXTURE2D(_NormalTex);
                                                                                                                                    SAMPLER(sampler_NormalTex);

                                                                                                                                    // Graph Includes
                                                                                                                                    // GraphIncludes: <None>

                                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                                    float4 _SelectionID;
                                                                                                                                    #endif

                                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                                    int _ObjectId;
                                                                                                                                    int _PassValue;
                                                                                                                                    #endif

                                                                                                                                    // Graph Functions
                                                                                                                                    // GraphFunctions: <None>

                                                                                                                                    // Custom interpolators pre vertex
                                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                                    // Graph Vertex
                                                                                                                                    struct VertexDescription
                                                                                                                                    {
                                                                                                                                        float3 Position;
                                                                                                                                        float3 Normal;
                                                                                                                                        float3 Tangent;
                                                                                                                                    };

                                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                                    {
                                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                                        description.Position = IN.ObjectSpacePosition;
                                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                        return description;
                                                                                                                                    }

                                                                                                                                    // Custom interpolators, pre surface
                                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                                    {
                                                                                                                                    return output;
                                                                                                                                    }
                                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                                    #endif

                                                                                                                                    // Graph Pixel
                                                                                                                                    struct SurfaceDescription
                                                                                                                                    {
                                                                                                                                    };

                                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                                    {
                                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                        return surface;
                                                                                                                                    }

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Build Graph Inputs
                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                                    #endif
                                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                                    {
                                                                                                                                        VertexDescriptionInputs output;
                                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                                                                                        return output;
                                                                                                                                    }
                                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                                    {
                                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                                    #endif








                                                                                                                                        #if UNITY_UV_STARTS_AT_TOP
                                                                                                                                        #else
                                                                                                                                        #endif


                                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                                    #else
                                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                                    #endif
                                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                            return output;
                                                                                                                                    }

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Main

                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                                    // --------------------------------------------------
                                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                                    #endif

                                                                                                                                    ENDHLSL
                                                                                                                                    }
                                                                                                                                    Pass
                                                                                                                                    {
                                                                                                                                        // Name: <None>
                                                                                                                                        Tags
                                                                                                                                        {
                                                                                                                                            "LightMode" = "Universal2D"
                                                                                                                                        }

                                                                                                                                        // Render State
                                                                                                                                        Cull Back
                                                                                                                                        Blend One Zero
                                                                                                                                        ZTest LEqual
                                                                                                                                        ZWrite On

                                                                                                                                        // Debug
                                                                                                                                        // <None>

                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Pass

                                                                                                                                        HLSLPROGRAM

                                                                                                                                        // Pragmas
                                                                                                                                        #pragma target 2.0
                                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                                        #pragma multi_compile_instancing
                                                                                                                                        #pragma multi_compile _ DOTS_INSTANCING_ON
                                                                                                                                        #pragma target 3.5 DOTS_INSTANCING_ON
                                                                                                                                        #pragma vertex vert
                                                                                                                                        #pragma fragment frag

                                                                                                                                        // Keywords
                                                                                                                                        // PassKeywords: <None>
                                                                                                                                        // GraphKeywords: <None>

                                                                                                                                        // Defines

                                                                                                                                        #define _NORMALMAP 1
                                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                                        #define SHADERPASS SHADERPASS_2D
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                                        // custom interpolator pre-include
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                                        // Includes
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Structs and Packing

                                                                                                                                        // custom interpolators pre packing
                                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                                        struct Attributes
                                                                                                                                        {
                                                                                                                                             float3 positionOS : POSITION;
                                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };
                                                                                                                                        struct Varyings
                                                                                                                                        {
                                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                                             float4 texCoord0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };
                                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                                        {
                                                                                                                                             float4 uv0;
                                                                                                                                        };
                                                                                                                                        struct VertexDescriptionInputs
                                                                                                                                        {
                                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                                        };
                                                                                                                                        struct PackedVaryings
                                                                                                                                        {
                                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                                             float4 interp0 : INTERP0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                                            #endif
                                                                                                                                        };

                                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                                        {
                                                                                                                                            PackedVaryings output;
                                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                                            output.interp0.xyzw = input.texCoord0;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                                            #endif
                                                                                                                                            return output;
                                                                                                                                        }

                                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                                        {
                                                                                                                                            Varyings output;
                                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                                            output.texCoord0 = input.interp0.xyzw;
                                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                                            #endif
                                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                                            #endif
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                                            #endif
                                                                                                                                            return output;
                                                                                                                                        }


                                                                                                                                        // --------------------------------------------------
                                                                                                                                        // Graph

                                                                                                                                        // Graph Properties
                                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                                        float4 _MainTex_TexelSize;
                                                                                                                                        float2 _Tiling;
                                                                                                                                        float4 _Color;
                                                                                                                                        float _Metallic;
                                                                                                                                        float _Smoothness;
                                                                                                                                        float2 _Offset;
                                                                                                                                        float4 _NormalTex_TexelSize;
                                                                                                                                        CBUFFER_END


                                                                                                                                            // Object and Global properties
                                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                                            TEXTURE2D(_MainTex);
                                                                                                                                            SAMPLER(sampler_MainTex);
                                                                                                                                            TEXTURE2D(_NormalTex);
                                                                                                                                            SAMPLER(sampler_NormalTex);

                                                                                                                                            // Graph Includes
                                                                                                                                            // GraphIncludes: <None>

                                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                                            float4 _SelectionID;
                                                                                                                                            #endif

                                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                                            int _ObjectId;
                                                                                                                                            int _PassValue;
                                                                                                                                            #endif

                                                                                                                                            // Graph Functions

                                                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                                                            {
                                                                                                                                                Out = UV * Tiling + Offset;
                                                                                                                                            }

                                                                                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                                                                                            {
                                                                                                                                                Out = A * B;
                                                                                                                                            }

                                                                                                                                            // Custom interpolators pre vertex
                                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                                            // Graph Vertex
                                                                                                                                            struct VertexDescription
                                                                                                                                            {
                                                                                                                                                float3 Position;
                                                                                                                                                float3 Normal;
                                                                                                                                                float3 Tangent;
                                                                                                                                            };

                                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                                            {
                                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                                return description;
                                                                                                                                            }

                                                                                                                                            // Custom interpolators, pre surface
                                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                                            {
                                                                                                                                            return output;
                                                                                                                                            }
                                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                                            #endif

                                                                                                                                            // Graph Pixel
                                                                                                                                            struct SurfaceDescription
                                                                                                                                            {
                                                                                                                                                float3 BaseColor;
                                                                                                                                            };

                                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                                            {
                                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                                UnityTexture2D _Property_be1c57220db84e7681df7a087f8f2d71_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
                                                                                                                                                float2 _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0 = _Tiling;
                                                                                                                                                float2 _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0 = _Offset;
                                                                                                                                                float2 _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3;
                                                                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_da36b9045c304fe7aa72e4585fec7b70_Out_0, _Property_4a784e7b91c846ef9a4bce8bc0dfface_Out_0, _TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3);
                                                                                                                                                float4 _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be1c57220db84e7681df7a087f8f2d71_Out_0.tex, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.samplerstate, _Property_be1c57220db84e7681df7a087f8f2d71_Out_0.GetTransformedUV(_TilingAndOffset_655f83d3ed3c4bdc85b54b810224a925_Out_3));
                                                                                                                                                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_R_4 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.r;
                                                                                                                                                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_G_5 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.g;
                                                                                                                                                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_B_6 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.b;
                                                                                                                                                float _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_A_7 = _SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0.a;
                                                                                                                                                float4 _Property_89061ca830494771b73ac92e12e24353_Out_0 = _Color;
                                                                                                                                                float4 _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2;
                                                                                                                                                Unity_Multiply_float4_float4(_SampleTexture2D_f15308f0f2cc44deb71e9024abb4413a_RGBA_0, _Property_89061ca830494771b73ac92e12e24353_Out_0, _Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2);
                                                                                                                                                surface.BaseColor = (_Multiply_bc3856f81c0d4e1d93a269b162d805bd_Out_2.xyz);
                                                                                                                                                return surface;
                                                                                                                                            }

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Build Graph Inputs
                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                                            #endif
                                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                                            {
                                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                                                                                return output;
                                                                                                                                            }
                                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                                            {
                                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                                            #endif








                                                                                                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                                                                                                #else
                                                                                                                                                #endif


                                                                                                                                                output.uv0 = input.texCoord0;
                                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                                            #else
                                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                                            #endif
                                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                                    return output;
                                                                                                                                            }

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Main

                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                                                                                            // --------------------------------------------------
                                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                                            #endif

                                                                                                                                            ENDHLSL
                                                                                                                                            }
                                                                            }
                                                                                CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                                                                                CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}