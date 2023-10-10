Shader "Custom/ShaderBlinnPhong"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
         _Shine("Shine", float) = 1
        
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : NORMAL;
            };
            CBUFFER_START(UnityPerMaterial)
           float4 _Color;
            float4 _Shine;
          CBUFFER_END
            
            Varyings Vert(const Attributes input)
            {
                Varyings output;
                
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalWS = TransformObjectToWorld(input.normalOS);
                
                
                return output;
            }
   float4 BlinnPhong(Varyings varyings)
          {
                Light light = GetMainLight();
             half3 ambient = light.color * 0.1f;
                half3 diffuse = saturate(dot(varyings.normalWS, light.direction)) * light.color;
              //half3 viewDir = GetWorldSpaceNormalizeViewDir(varyings.positionWS);
             float3 halfVec = normalize(light.direction + GetWorldSpaceNormalizeViewDir(varyings.positionWS));
              float3 spec = pow(saturate(dot(varyings.normalWS,halfVec)),_Shine) * light.color;
              return float4((ambient + diffuse + spec) * _Color,1);
              
              

              
          }
            half4 Frag(const Varyings input) : SV_TARGET
            {
                //return half4(_Shine);
                return BlinnPhong(input);
            }
       
            
            ENDHLSL

        }
    }
}