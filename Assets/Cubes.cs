using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Cubes : MonoBehaviour
{
  [SerializeField][Range(0.001f,5)] private float Amplitude;
  [SerializeField][Range(0f,360)] private float Angle;
  [SerializeField][Range(0f,360)] private float Frequency;
  [SerializeField] ComputeShader CubeShader;
  [SerializeField] Mesh CubeMesh;
  [SerializeField] Material CubeMaterial;

  private const int CubeAmount = 700 * 700;
  private const int Size = 700;
  private static readonly int Amp = Shader.PropertyToID(("Amplitude"));
  private static readonly int SizeIndex = Shader.PropertyToID(("Size"));
  private static readonly int Freq = Shader.PropertyToID(("Frequency"));
  private static readonly int CurrentTime = Shader.PropertyToID(("Time"));
  private static readonly int Dir = Shader.PropertyToID(("Direction"));
  private static readonly int Pos = Shader.PropertyToID(("Positions"));
  
  private Vector4[] CubePosition = new Vector4[CubeAmount];

  private Matrix4x4[] CubeMatrices = new Matrix4x4[CubeAmount];
  private static int MainKernel;


  private ComputeBuffer CubeBuffer;

  private AsyncGPUReadbackRequest GPURequest;
  private void PopulateCubes(Vector4[] positions)
  {
    for (uint i = 0; i < Size; i++)
    {
      for (uint j = 0; j < Size; j++)
      {
        positions[i * Size + j] = new Vector4(i / (float)Size,0, j / (float)Size,  0);
      }
    }

  }

  void Start()
  {
    
    MainKernel = CubeShader.FindKernel("Simulate");
    
    
    PopulateCubes(CubePosition);
    CubeBuffer = new ComputeBuffer(CubeAmount, 4* sizeof(float));
    CubeBuffer.SetData((CubePosition));
    CubeShader.SetBuffer(MainKernel, Pos, CubeBuffer);
    
    DispatchCubes();
    
    GPURequest = AsyncGPUReadback.Request((CubeBuffer));

  
  }

  private void DispatchCubes()
  {
    Vector2 dir = new Vector2(Mathf.Cos(Mathf.Deg2Rad * Angle), Mathf.Sin((Mathf.Deg2Rad * Angle)));
   
    CubeShader.SetFloat(Amp,Amplitude);
    CubeShader.SetFloat(Freq,Frequency);
    CubeShader.SetFloat(CurrentTime,Time.time);
    CubeShader.SetInt(SizeIndex, Size);
    CubeShader.SetVector(Dir,dir);
    
CubeShader.Dispatch(MainKernel, Size / 8, Size / 8, 1);
  }
  
  void Update()
  {
    if (GPURequest.done)
    {
      CubePosition = GPURequest.GetData<Vector4>().ToArray();
     
      for (uint j = 0; j < CubeAmount; j++)
      {
       
        CubeMatrices[j] = Matrix4x4.TRS((Vector3)CubePosition[j] + transform.position, Quaternion.identity,
          Vector3.one * (1 / (float)Size));
      }
      GPURequest = AsyncGPUReadback.Request((CubeBuffer));
    }
    
    DispatchCubes();
    Graphics.DrawMeshInstanced(CubeMesh, 0,CubeMaterial, CubeMatrices);
  }


  private void OnDisable()
  {
    CubeBuffer.Release();
  }
  private void OnDestroy()
  {
    CubeBuffer.Release();
  }
}
