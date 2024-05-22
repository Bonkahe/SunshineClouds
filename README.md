<img src="https://github.com/Bonkahe/SunshineClouds/blob/main/GithubStuff/ProcCloudsGithubLogo.png">

# SunshineClouds

## Updates:
version 1.3:
Added support for Godot 4.3, this is a breaking change, meaning that the cloud system as of this version will not support earlier versions of Godot, I apologize for this, but it is due to the reverse Z update for Godot, and unfortunately that was a little bit of a breaking update.

Project breakdown and usage explanation:
[https://www.youtube.com/watch?v=8GCqIHHNDrg](https://www.youtube.com/watch?v=8GCqIHHNDrg)

This project is currently work in progress, but should be usable in game.
Currently working on getting it on the Asset Library.

A procedural cloud system for Godot 4.3 designed from the ground up to be as extendable, and barebones as possible while still looking as good as possible.

## Features
* Fully volumetric clouds, extendable and performant up too 30km away from camera.
* Extremely extendable, requires nothing to run beyond a single MeshInstance3D containing quad, can add other features later on.
* Alternate more high quality lighting model which is more performance demanding.
* Very barebones and simple script to set the material variables to the world (updates sun rotation, environment settings, fog etc.)

## Installation

1. Option A: Download Repo (zip works just fine)
2. Option B: Download either online or via the in-editor asset library at this location: [https://godotengine.org/asset-library/asset/2372](https://godotengine.org/asset-library/asset/2372)
3. Activate Plugin (Project->Project Settings->Plugins->SunshineClouds)

#### Installation Cont. Option A:
1. Add ["CloudsPrefab.tscn"](https://github.com/Bonkahe/SunshineClouds/blob/main/addons/SunshineVolumetricClouds/CloudsPrefab.tscn) to your scene, works out of the gate, but will need to be plugged into your directional light and enviroment, also the quad will not automatically follow your camera, so if you get too far out of the origin point the clouds may disapear.

#### Installation Cont. Option B:
1. Add MeshInstance3D to your scene.
2. Child the new MeshInstance3D to your camera, to ensure it does not get culled.
3. Set new MeshInstance3D mesh to a quad mesh.
4. Set new MeshInstance3D material to one of the quality settings in the SunShineClouds (Default, Low, High)
5. Right click your scene node and add a new child Node of type "CloudsController"
6. Set CloudsController SunLight to your scene Directional Light
7. Add your environment to the WorldEnvironment variable in the CloudsController.

## Contribution
A couple important things to make note of here, this project is meant to as much as possible be a very bare bones system, I want it to be extended in peoples projects, to make it as multi-purpose as possible.
To Keep in this style, any pull request with things like day night systems, or implemntation of more specific features, while very cool, will be declined. I want the system to be as light weight as possible and able to be
implemented in as many projects as easily as possible.
That being said if you do anything in these regards by all means make a new repo and send me a message, I will make an addons section in this readme with a link to your project.

### Current outstanding issues
* Need reliable way to implement global shader variables when the plugin is installed.


## License
This plugin has been released under the [MIT License](https://github.com/Bonkahe/SunshineClouds/blob/main/LICENSE).
