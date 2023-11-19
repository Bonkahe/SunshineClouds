#if TOOLS
using Godot;
using System;

[Tool]
public partial class SunshineCloudsInstaller : EditorPlugin
{
	public override void _EnterTree()
	{
        try
        {
            Resource HeightWeightGradient = ResourceLoader.Load<Resource>("res://addons/SunshineVolumetricClouds/HeightWeightGradient.tres");

            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_HeightWeightGradient", RenderingServer.GlobalShaderParameterType.Sampler2D, HeightWeightGradient);

            Resource BaseNoiseTexture = ResourceLoader.Load<Resource>("res://addons/SunshineVolumetricClouds/BaseNoiseTexture.tres");

            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_BaseNoiseTexture", RenderingServer.GlobalShaderParameterType.Sampler3D, BaseNoiseTexture);


            Resource DetailNoiseTexture = ResourceLoader.Load<Resource>("res://addons/SunshineVolumetricClouds/BaseNoiseDetailTexture.tres");

            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_DetailNoiseTexture", RenderingServer.GlobalShaderParameterType.Sampler3D, DetailNoiseTexture);

            Resource LargeScaleNoiseTexture = ResourceLoader.Load<Resource>("res://addons/SunshineVolumetricClouds/BaseNoiseLargeScaleTexture.tres");

            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_LargeScaleNoiseTexture", RenderingServer.GlobalShaderParameterType.Sampler3D, LargeScaleNoiseTexture);

            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_SunDirection", RenderingServer.GlobalShaderParameterType.Vec3, Vector3.Up);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_SunColor", RenderingServer.GlobalShaderParameterType.Color, new Color(1, 1, 1));
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_FogColor", RenderingServer.GlobalShaderParameterType.Color, new Color(1, 1, 1));
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_AmbientColor", RenderingServer.GlobalShaderParameterType.Color, new Color(0, 0, 0));

            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_UseFog", RenderingServer.GlobalShaderParameterType.Bool, true);

            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_WindDirection", RenderingServer.GlobalShaderParameterType.Vec2, Vector2.Zero);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_WindSpeed", RenderingServer.GlobalShaderParameterType.Float, 0.003f);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsGlobalScale", RenderingServer.GlobalShaderParameterType.Float, 10000.0f);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsDetailNoiseScale", RenderingServer.GlobalShaderParameterType.Float, 5.921f);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsDetailNoisePower", RenderingServer.GlobalShaderParameterType.Float, 1.048f);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsLargeScaleNoiseScale", RenderingServer.GlobalShaderParameterType.Float, 0.216f);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsLargeScaleNoisePower", RenderingServer.GlobalShaderParameterType.Float, 3.435f);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsBaseNoiseScale", RenderingServer.GlobalShaderParameterType.Float, 1.761f);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsCutoff", RenderingServer.GlobalShaderParameterType.Float, 0.213f);

            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsFloor", RenderingServer.GlobalShaderParameterType.Float, 80.0f);
            RenderingServer.GlobalShaderParameterAdd("SunshineClouds_CloudsCeiling", RenderingServer.GlobalShaderParameterType.Float, 2000.0f);
            //GD.PrintRich("[b]Sunshine Clouds[/b] global shader variables installed, [color=green]please restart to see update.[/color]");
        }
        catch (Exception ex)
        {
            GD.PrintRich("[color=red] [b]Sunshine Clouds did NOT install correctly, error as follows; [/b][/color]");
            GD.PrintErr(ex);
        }
	}

	public override void _ExitTree()
	{
        try
        {
            GD.PrintRich("[b]Sunshine Clouds[/b] removal beginning...");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_HeightWeightGradient");
            GD.PrintRich("[b]SunshineClouds_HeightWeightGradient:[/b] Removed.");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_BaseNoiseTexture");
            GD.PrintRich("[b]SunshineClouds_BaseNoiseTexture:[/b] Removed.");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_DetailNoiseTexture");
            GD.PrintRich("[b]SunshineClouds_DetailNoiseTexture:[/b] Removed.");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_LargeScaleNoiseTexture");
            GD.PrintRich("[b]SunshineClouds_LargeScaleNoiseTexture:[/b] Removed.");


            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_SunDirection");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_SunColor");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_FogColor");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_AmbientColor");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_UseFog");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_WindDirection");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_WindSpeed");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsGlobalScale");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsDetailNoiseScale");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsDetailNoisePower");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsLargeScaleNoiseScale");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsLargeScaleNoisePower");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsBaseNoiseScale");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsFloor");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsCeiling");
            RenderingServer.GlobalShaderParameterRemove("SunshineClouds_CloudsCutoff");
            GD.PrintRich("[b]Noise Settings:[/b] Removed.");
        }
        catch (Exception ex)
        {
            GD.PrintRich("[color=red] [b]Sunshine Clouds did NOT remove correctly, error as follows; [/b][/color]");
            GD.PrintErr(ex);
            GD.PrintRich("[color=red] [b]To clean up remove any remaining global shader variables beginning with 'SunshineClouds'.[/b][/color]");
        }
    }
}
#endif
