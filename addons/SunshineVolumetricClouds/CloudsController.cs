using Godot;
using System;

[Tool]
public partial class CloudsController : Node
{
    [Export] public bool UpdateConstantly { get; set; } = false;
	[Export] public DirectionalLight3D SunLight { get; set; }
	[Export] public WorldEnvironment WorldEnvironment { get; set; }

    [ExportGroup("Textures")]
    [Export] public GradientTexture1D GradientControlTexture { get; set; }
    [Export] public NoiseTexture3D BaseNoiseTexture { get; set; }
    [Export] public NoiseTexture3D DetailNoiseTexture { get; set; }
    [Export] public NoiseTexture3D LargeScaleNoiseTexture { get; set; }

    [ExportGroup("Weather Controls")]

    [Export] public Vector2 WindDirection { get; set; } = new Vector2(1, 0);
    [Export] public float WindSpeed { get; set; } = 0.003f;

    [Export(PropertyHint.Range, "0,2")] public float CloudsCutoff { get; set; } = 0.213f;
    [Export] public float CloudsFloor { get; set; } = 80.0f;
    [Export] public float CloudsCeiling { get; set; } = 2000.0f;

    [Export] public float GlobalCloudScale { get; set; } = 10000;
    [Export] public float BaseNoiseScale { get; set; } = 1.761f;
    [Export] public float DetailNoiseScale { get; set; } = 5.921f;
    [Export] public float DetailNoisePower { get; set; } = 1.048f;
    [Export] public float LargeScaleNoiseScale { get; set; } = 0.216f;
    [Export] public float LargeScaleNoisePower { get; set; } = 3.435f;

    [ExportSubgroup("Enviroment and Light Driven Controls")]
    [Export] public Color SunColorDefault { get; set; } = new Color(1, 1, 1);
    [Export] public Color AmbientColorDefault { get; set; } = new Color(0, 0, 0);
    [Export] public bool UseFogDefault { get; set; } = true;
    [Export] public Color FogColorDefault { get; set; } = new Color(1, 1, 1);


    public override void _Process(double delta)
    {
        if (Engine.IsEditorHint() || UpdateConstantly) {
            UpdateGlobalVariableTextures();
            UpdateGlobalVariables();
        }
    }

    public void UpdateGlobalVariableTextures()
    {
        if (GradientControlTexture == null)
        {
            GradientControlTexture = ResourceLoader.Load<GradientTexture1D>("res://addons/SunshineVolumetricClouds/HeightWeightGradient.tres");
        }
        if (BaseNoiseTexture == null)
        {
            BaseNoiseTexture = ResourceLoader.Load<NoiseTexture3D>("res://addons/SunshineVolumetricClouds/BaseNoiseTexture.tres");
        }
        if (DetailNoiseTexture == null)
        {
            DetailNoiseTexture = ResourceLoader.Load<NoiseTexture3D>("res://addons/SunshineVolumetricClouds/BaseNoiseDetailTexture.tres");
        }
        if (LargeScaleNoiseTexture == null)
        {
            LargeScaleNoiseTexture = ResourceLoader.Load<NoiseTexture3D>("res://addons/SunshineVolumetricClouds/BaseNoiseLargeScaleTexture.tres");
        }
    }

    public void UpdateGlobalVariables()
    {
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsCutoff", CloudsCutoff);

        RenderingServer.GlobalShaderParameterSet("SunshineClouds_WindDirection", WindDirection);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_WindSpeed", WindSpeed);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsFloor", CloudsFloor);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsCeiling", CloudsCeiling);

        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsGlobalScale", GlobalCloudScale);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsBaseNoiseScale", BaseNoiseScale);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsDetailNoiseScale", DetailNoiseScale);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsDetailNoisePower", DetailNoisePower);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsLargeScaleNoiseScale", LargeScaleNoiseScale);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_CloudsLargeScaleNoisePower", LargeScaleNoisePower);

        if (SunLight != null)
        {
            RenderingServer.GlobalShaderParameterSet("SunshineClouds_SunDirection", SunLight.GlobalTransform.Basis.Z);
            
            SunColorDefault = SunLight.LightColor * SunLight.LightEnergy;
        }

        if (WorldEnvironment != null && WorldEnvironment.Environment != null)
        {
            UseFogDefault = WorldEnvironment.Environment.FogEnabled;
            FogColorDefault = WorldEnvironment.Environment.FogLightColor * WorldEnvironment.Environment.FogLightEnergy;

            if (WorldEnvironment.Environment.AmbientLightSource == Godot.Environment.AmbientSource.Color)
            {
                AmbientColorDefault = WorldEnvironment.Environment.AmbientLightColor * WorldEnvironment.Environment.AmbientLightEnergy;
            }
        }

        RenderingServer.GlobalShaderParameterSet("SunshineClouds_SunColor", SunColorDefault);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_UseFog", UseFogDefault);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_FogColor", FogColorDefault);
        RenderingServer.GlobalShaderParameterSet("SunshineClouds_AmbientColor", AmbientColorDefault);
    }
}
