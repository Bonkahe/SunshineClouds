<img src="https://github.com/Bonkahe/SunshineClouds/blob/main/GithubStuff/ProcCloudsGithubLogo.png">

# SunshineClouds
This project is current Experimental.

A procedural cloud system for Godot 4.2 designed from the ground up to be as extendable, and barebones as possible while still looking as good as possible.

## Features
* Fully volumetric clouds, extendable and performant up too 30km away from camera.
* Extremely extendable, requires nothing to run beyond a single MeshInstance3D containing quad, can add other features later on.
* Very barebones and simple script to set the material variables to the world (updates sun rotation, environment settings, fog etc.)

## Installation
1. Download Repo (zip works just fine)
2. Pull ["SunShineClouds"](https://github.com/Bonkahe/SunshineClouds/tree/main/SunShineClouds) folder into your project in a out of the way location.

### Installation Cont. Option A:
1. Add ["CloudsExampleScene.tscn"](https://github.com/Bonkahe/SunshineClouds/blob/main/SunShineClouds/CloudsExampleScene.tscn) to your scene, works out of the gate but contains a directional light and environment.

### Installation Cont. Option B:
1. Add MeshInstance3D to your scene.
2. Set new MeshInstance3D mesh to a quad mesh.
3. Set new MeshInstance3D material to one of the quality settings in the SunShineClouds (Default, Low, High)
4. Right click your scene node and add a new child Node of type "CloudsController"
5. Set CloudsController Sun Light to your scene Directional Light
6. Set CloudsController Sky Material to your selected material (the one you put into the MeshInstance3D)
7. Optionally: Add your environment resource to the OptionalWorldEnvironment variable in the CloudsController.

## Contribution
A couple important things to make note of here, this project is meant to as much as possible be a very bare bones system, I want it to be extended in peoples projects, to make it as multi-purpose as possible.
To Keep in this style, any pull request with things like day night systems, or implemntation of more specific features, while very cool, will be declined. I want the system to be as light weight as possible and able to be
implemented in as many projects as easily as possible.
That being said if you do anything in these regards by all means make a new repo and send me a message, I will make an addons section in this readme with a link to your project.

### Current outstanding issues
* Pixel errors occur when settings set on too high of a quality
* AMD gpu consistent issues, currently do not have an AMD gpu to test on
* Banding issue on nearby terrain/objects
* More gradual opacity near the player is needed it allow it to function as if it is fog when close to player
* Performance improvements and general stability


## License
This plugin has been released under the [MIT License](https://github.com/Bonkahe/SunshineClouds/blob/main/LICENSE).
