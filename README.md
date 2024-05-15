# Flicky Bee

A Game originally made for Mini Jam 128 : Health

Link to the Game Page
https://lettucepie.itch.io/flicky-bee

## Setup

- Download Godot Engine 4.2.2
- Download the Project
- Open the Project in Godot Engine by adding it to the Project List.
- Run the Project by hitting the Play Button located in the top right.


## Design Notes

Root folders are organized for f-droid build server compatability. The actual project is located within `game`. Within the project the folder structure the two most important folders are `Core` and `Play`. Within `Core is everything that pieces together a game into a `Play` scene. `Accessory` and `UI` are segregated for unknown reasons... I'm updating this readme a year later lol.

All the models share the same Material and Texture. I don't know where, but I recall hearing that the less unique shaders loaded the better, especially on mobile. So to get things to be different colors, I made a material and a colorsheet texture. I then assigned the UV coords of polygons to points on that texture in blender to color. So when making new Models, it's important to start off another blend file or to import the materials with the Append function.

There are flags put in to limit the view of a single accessory item called "Supporter". It's a trail effect that rains dollar bills and coins. If the game is exported with a functioning appstore plugin along with the `playstore` tag it will use the google appstore functions to gather a product id, and then display it in the editor screen. If you want to skip past all that and still get the Supporter trail to appear, change it's pricetag file at `/game/Accessory/Trails/PriceTags`.
