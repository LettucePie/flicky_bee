# Flicky Bee

A Game originally made for Mini Jam 128 : Health

Link to the Game Page
https://lettucepie.itch.io/flicky-bee

## Setup

- Download Godot Engine 4.0.2+
- Download the Project
- Open the Project in Godot Engine by adding it to the Project List.
- Run the Project by hitting the Play Button located in the top right.

I wish it imported into other workstations cleanly, but in my experience it will trip up on several things. Models may or may not have any Materials or Colors assigned to them. Also the Debugger will tell you that several things have been disconnected from their uuids, and have fallen back to using the file-path. Music and Audio files don't retain their import settings either, so Music that's supposed to loop will simply just quit on first playback.

To fix most of these issues, you have to open the target scene featuring a load issue. So if for example the Bricks are gray and colorless, you can search through the file system for the brick obstacles, and open their scene. Most of the time this will fix things. If it doesn't you may need to go to the original model.glb, assign it's Material, then re-import it.

## Design Notes

The target design for the file structure is Core, Play, UI, etc. Within Core should be scenes and assets that provide elements or purpose to the overall Gameplay. Play should contain scenes where Core elements are assembled for use. The player will be interacting exclusively with scenes in Play, and the elements those scenes contain. The UI folder should host everything involving user interface, things that don't provide any form of gameplay but rather information. Accessory is currently located on Root. It contains every cosmetic accessory for the player. I'm unsure if it should be in Core, so it's resting in Root for now.

The Target platform is Mobile (android and ios). Trying to load as few materials as possible, so almost every model uses the same material and texture, located in the Mono_Material folder. Models have their UVs assigned to colors on a Color Sheet in blender. The Workflow for this is to open a Model in blender like Bee.blend, then SAVE AS new item. Delete the Bee and make the new item. Assign the BaseMaterial that should be floating around in the .blend file. Assign the UV's to the ColorSheet which should also be floating around. Save and Export as .glb. When Exporting go to the Geometry drop-down section, and set Texture as disabled or non-export, but keep material. In Godot the model should appear, open it's import settings by double-clicking the .glb. Go to the Material Tab, and click on BaseMaterial, then on the right check the Use External. Navigate to the Mono_Material folder and assign. Then Re-Import at the bottom.
