Shader "Custom/ShaderBlinnPhong"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
         _Shine("Shine", Range(1, 512)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        
        Pass
        {
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
                float3 normalWS : TEXCOORD0;
                 float3 positionWS : TEXCOORD1;
            };
            CBUFFER_START(UnityPerMaterial)
           float4 _Color;
            float _Shine;
          CBUFFER_END
            
            Varyings Vert(const Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }
   float4 BlinnPhong(const Varyings varyings)
          {
                Light light = GetMainLight();
             float3 ambient = light.color * 0.1f;
                float3 diffuse = saturate(dot(varyings.normalWS, light.direction)) * light.color;
              float3 viewDir = GetWorldSpaceNormalizeViewDir(varyings.positionWS);
             float3 halfVec = normalize(light.direction + GetWorldSpaceNormalizeViewDir(varyings.positionWS));
              float3 spec = pow(saturate(dot(varyings.normalWS,halfVec)),_Shine) * light.color;
              return float4((ambient + diffuse + spec) * _Color,1);
              
              

              
          }
            float4 Frag(const Varyings input) : SV_TARGET
            {
                //return half4(_Shine);
                return BlinnPhong(input);
            }
       
            
            ENDHLSL

        }

Pass
{
    Name "Normals"
    Tags { "LightMode" = "DepthNormalsOnly" }
    
    Cull Back
    ZTest LEqual
    ZWrite On
    
    HLSLPROGRAM
    
    #pragma vertex DepthNormalsVert
    #pragma fragment DepthNormalsFrag

    #include "Shaders/Common/DepthNormalsOnly.hlsl"
    
    ENDHLSL
}

Pass
{
    Name "Depth"
    Tags { "LightMode" = "DepthOnly" }
    
    Cull Back
    ZTest LEqual
    ZWrite On
    ColorMask R
    
    HLSLPROGRAM
    
    #pragma vertex DepthVert
    #pragma fragment DepthFrag

    
     #include "Shaders/Common/DepthOnly.hlsl"

     ENDHLSL

}
    }
}