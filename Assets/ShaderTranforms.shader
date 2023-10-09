Shader "Custom/ShaderTransform"
{
    Properties
    {
          [KeywordEnum(Local, World, View)]
        _CordKeyword("Cord", float) = 0
        _Color("Color", Color) = (1,1,1,1)
        
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry"
        }



        Pass
        {
            Name "customPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma shader_feature_local_vertex _CORDKEYWORD_LOCAL _CORDKEYWORD_WORLD  _CORDKEYWORD_VIEW

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };
            CBUFFER_START(UnityPerMaterial)
   
            float4 _Color;
          CBUFFER_END
            
            Varyings Vert(const Attributes input)
            {
                Varyings output;



              output.positionHCS = TransformWorldToHClip( input.positionOS);

                   
             
              
               #if _CORDKEYWORD_LOCAL
               output.positionHCS = TransformObjectToHClip(input.positionOS + float3(0,1,0));
                 #elif _CORDKEYWORD_WORLD      
              output.positionHCS =   TransformWorldToHClip( TransformObjectToWorld(input.positionOS) + float4(0,1,0,0)  );
                #elif _CORDKEYWORD_VIEW
                   const float3 world = TransformObjectToWorld(input.positionOS);
                    const  float3 view = TransformWorldToView(world)+ float3(0,1,0);
              output.positionHCS =  TransformWViewToHClip(view);
              #endif
                  
          
       
               
                output.positionWS = TransformObjectToHClip(input.positionOS);
                return output;
            }

            half4 Frag(const Varyings input) : SV_TARGET
            {
                  #if _CORDKEYWORD_LOCAL
                      return half4(float4(0,1,0,1));
                #endif
                
                return half4(_Color);
                
            }
            ENDHLSL

        }
    }
}