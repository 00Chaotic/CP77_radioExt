# RadioExt
A mod for CP2077 that allows for the addition of custom car radio stations, by using an external audio player hidden behind the regular game UI and inputs.

#### How to use:
- [CET](https://github.com/yamashi/CyberEngineTweaks) Version 1.18.1+ is required
- Download and install the mod from [LINK HERE]

#### How it works and what it does:
- This mod uses an external audio player, in the form of an `.asi` 
- The audio player gets hooked up to the game's radio interface using a CET based mod
- This way the custom stations look, sound and behave just like the ones already in the game

## How to create new radio stations:
1. Navigate to the mod's folder, located in `Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\radioExt\radios`
2. Create a new folder in there, with a unique name, e.g. `radioExt\radios\myRadio`
3. Copy the `metadata.json` file, which is located in the mods main folder `Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\radioExt\metdata.json`, into your newly created radio station folder
4. Change the values inside this file to your liking:
	- `displayName` is what gets displayed as the stations name
	- `fm` is a number, if the `displayName` has a FM number it should be the same, which is used to place the station at the right place in the stations list
	- `icon` is the icon for the station. It can be any `UIIcon.` record. To find a list of all records, open the CET console's `TweakDB Editor` tab, and enter `UIIcon.` in the search bar
	- `volume` is the overall volume multiplier for the station
5. Place any song you want inside the stations folder e.g. `radioExt\radios\myRadio`
	-  Only `.mp3` and `.wav` is supported
	- Try to keep the file size small (<10mb per file)
	- File names are not allowed to contain special characters such as emojis
	- Keep in mind that the songs file names are being used as song names ingame, so keep them clean
	- At least 3 songs per station are required, no upper limit
6. Now you should have a folder structure that looks something like this:
	```
	├── radioExt
		└── radios
			└── myRadio
				└── metadata.json
				└──	customSong1.mp3
				└──	customSong2.mp3
				└── customSong3.mp3
	```
7. Launch the game

#### Credits
- The [miniaudio](https://github.com/mackron/miniaudio) library by mackron
- [WSS](https://github.com/WSSDude420) for letting me use some of his C++ code
	