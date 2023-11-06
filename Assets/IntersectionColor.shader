Shader "Custom/IntersectionColor"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
    
          
        
        Pass
        {
            Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
           
            
              
            HLSLPROGRAM

            #pragma vertex  Vert
#pragma fragment Frag
            
           
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
               CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _IntersectionColor;
                

            CBUFFER_END
             struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                 float3 positionWS : TEXCOORD0;
            };

            struct Attributes
            {
                float4 positionOS : POSITION;

            };
             Varyings Vert(const Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                return output;
            }

           float4 Frag(Varyings input) : SV_TARGET{

            float2 screenspaceUV = GetNormalizedScreenSpaceUV((input.positionHCS));
               float4 depthTex =LinearEyeDepth(SampleSceneDepth(screenspaceUV), _ZBufferParams);
               float4 depth = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);
               return lerp(_Color,_IntersectionColor ,pow(1 - saturate(depthTex - depth), 15));
           }
   
 
            ENDHLSL
        }
    }
}

