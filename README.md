# README #


### What is this repository for? ###
This repository contains few experiments made for the retail surface prototype. This sketch is a visual controller to play an animation in a selected sequence, and the sequence can also be reconfigured with the interface provided in this software, which can further be extended to an extenal hardware.
Version 0.0.2

### How do I get set up? ###
Just install the following libraries and run this sketch in Processing 3.x

### Libraries ###
* controlP5 v2.2.6
* video v1.0.1
* SyphonProcessing v2.0
Install libraries using Sketch > Import Library... > Add Library... option in Processing IDE. 
More:  https://github.com/processing/processing/wiki/How-to-Install-a-Contributed-Library#install-with-the-add-library-tool

### Features ###
* Switch between modes: Stencil, Mask and Video using radio buttons (on the top left)
* Play/Pause video if you are in Video mode (next to radio buttons)
* Mark Clips with the Clip toggle (on the top right)
* Add new clips or update selected clip with a button (next to clip toggle)
* Choose few clips to be in loop with the checkbox & press next arrow to play the next clip in the sequence
* Save all the clip information as a CSV(Automatically loaded when played again)
* Ideal max video file duration: 1000s

### To Do ###
* Connect/Disconnect from Syphon (To be added)

### How do I use it? ###
* Add your own stencil, mask and video file
* Update variables: stencilFileName, maskFileName and maskVideoFileName appropriately
* Run the sketch to see the video playing
* Click on clips to jump to a particular marked duration

### Who do I talk to? ###
* Repo owner : TIMEBLUR
* Team contact: Mike Cj (mike@timeblur.io)

### LICENSE ###
* Licenses are included with the source code.
