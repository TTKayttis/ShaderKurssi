using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Serialization;

public class GameOfLife : MonoBehaviour
{
  private const int Size = 512;
  private static readonly int SizeIndex = Shader.PropertyToID(("Size"));
  
     [SerializeField] ComputeShader LifeShader;
    private AsyncGPUReadbackRequest GPURequest;
    [SerializeField] private Material TargetMaterial;
    [SerializeField] private Color CellColor;
   

    private RenderTexture _texture1;
     private RenderTexture _texture2;

   
    
    private static int Kernel1;
    private static int Kernel2;
    private static int Init;

    private bool useBuffer1;

    [SerializeField] private float UpdateInterval = 1;
    private float updateTime;
  
    public enum Seed {FullTexture, RPentomino,Acorn,Gun}

    [SerializeField] private Seed selectedSeed;
    
  void Start()
    {
      
      Kernel1 = LifeShader.FindKernel("Update1");
      Kernel2 = LifeShader.FindKernel("Update2");
      
      
     
        Init = LifeShader.FindKernel(GetSeedName(selectedSeed));
      
      
      _texture1 = new RenderTexture(Size, Size, 0, DefaultFormat.LDR) {filterMode = FilterMode.Point, enableRandomWrite = true};
      _texture1.filterMode = FilterMode.Point;
      _texture1.Create();
      
      _texture2 = new RenderTexture(Size, Size, 0, DefaultFormat.LDR) {filterMode = FilterMode.Point, enableRandomWrite = true};
      _texture2.filterMode = FilterMode.Point;
      _texture2.Create();
      
      LifeShader.SetVector("CellColour",CellColor );
      LifeShader.SetInt("Size",Size );
      
        LifeShader.SetTexture(Kernel1, "State1", _texture1);
        LifeShader.SetTexture(Kernel1, "State2", _texture2);
        
        LifeShader.SetTexture(Kernel2, "State1", _texture1);
        LifeShader.SetTexture(Kernel2, "State2", _texture2);
        
        LifeShader.SetTexture(Init, "State1", _texture1);
        LifeShader.SetTexture(Init, "State2", _texture2);
      
        
       LifeShader.Dispatch(Init,Size / 8,Size / 8,1);
    
     
      TargetMaterial.SetTexture("_BaseMap", _texture1);
      
      updateTime = UpdateInterval;



    }

  private string GetSeedName(Seed seed) => seed switch
  {
    Seed.FullTexture => "InitFullTexture",
    Seed.Acorn => "InitAcorn",
    Seed.Gun => "InitGun",
    Seed.RPentomino => "InitRPentomino"
  };

    
    void Update()
    {
      updateTime -= Time.unscaledDeltaTime;
      if (updateTime <= 0)
      {
        updateTime = UpdateInterval;
        if (useBuffer1)
        {
        LifeShader.Dispatch(Kernel1,Size/8,Size/8,1);
        TargetMaterial.SetTexture("_BaseMap", _texture1);
       
          useBuffer1 = false;
        }
        else
        {
        LifeShader.Dispatch(Kernel2,Size/8,Size/8,1);
         TargetMaterial.SetTexture("_BaseMap", _texture2);
         useBuffer1 = true;
        }
      
        
      }
      
     
    }
  
  
    private void OnDisable()
    {
     
      _texture1.Release();
      _texture2.Release();
    }
    private void OnDestroy()
    {
     
      _texture1.Release();
      _texture2.Release();
    }
}
