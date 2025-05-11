Birds Hunting Mouse Simulator

Name: Riley Hogarty

Student Number: C20426892

Class Group: TU858

# Description of the project
A godot project simulating real life behaviours of animals. In this case, the concept was to emulate birds wandering across the sky looking for potential prey, and on the other hand was a mouse wandering about an open field 

# Instructions for use
Import the project to the godot game engine using the project.godot file. Once successfully imported, press F5 to run the main scene. Once the scene is loaded, you can change the values in the inspector and press f5 to rerun to simulate different situations.

# How it works
The main scene of the project is HuntingScene.tcsn which houses the other scenes. It also facilitates the creation of the world environment and world floor.Established here is also the primary camera used for visualisation throughout the simulation. Added here also is an instance of the Mouse scene and 3 instances of the bird scene named bird, bird2, bird3. The birds are instantiated from bird.tcsn which is a nested scene that contains the building of the model of the bird and its core logic. Similarly the Mouse.tcsn serves the same purpose. Of note in these are bird wings, mouse tail and beak which are all planned to receive animation. The logic is primarily hosted in bird.gd, which describes the logic that the bird must obey and also in mouse.gd, which describes the rules that the mouse must obey. 

# Video Demonstration
![Video Demonstartion](https://youtu.be/c4k3RD8rtWg)

# List of classes/assets in the project

| Class/asset | Source |
|-----------|-----------|
| HuntingScene.tscn | Self written |
| Bird.tcsn (Nested Scenes) | Self Written |
| Bird.gd | Modified from [reference](https://github.com/skooter500/miniature-rotary-phone) |
| Mouse.tcsn (Nested Scenes) | Self written |
| Mouse.gd | Modified from [reference](https://github.com/skooter500/miniature-rotary-phone) |


# References
* [Item 1](https://github.com/skooter500/miniature-rotary-phone)

# What I am most proud of in the assignment
The model design, despite not being an area that I would consider myself to be strong in, ended up being my proudest segment. Despite these models being possibly labelled such words as hideous, I thought they looked quirky and unserious, which was the vibe I was going for. Also my github compliance, as during the duration of this assignment, my laptop charger was broken and the fact that I could continue coding on another device allowed me to complete the project.

# What I learned
I learned how to model with CSG meshes, and gained better understandings of the complexities of boids and steering behaviours. I also gained a better understanding of the Godot editor interface.


Where I Can Improve:

| What | Why |
|-----------|-----------|
|Planning| Whilst I believe my plan at the start was adequate, I think I needed to manage my time better, especially due to how much time I chose to focus on the Final Year Project instead. |
|Timing | When undertaking another project like this in the future I would prefer to have less unexpected circumtanses, like family bereavement occur, as it can greatly affect the amount of time that can be devoted to a project|
|Experience | By using the experience I had with this Project, I believe I would be able to turn in a more efficient and effective effort in the future. |

