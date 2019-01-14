# NoteBrowser 
This program has been renamed NoteBrowser from Fretboard_Aide. Fixing all occurances of the old name is a todo:  

NoteBrowser: 
This is a program written in FreeBASIC that is designed to visualize notes on a guitar fretboard.  
It is in the very early stage of development.  
As of Jan. 13, 2018 the program: 
- Displays a main menu with one active button called main. Buttons may be pressed by mouse or by hotkey. 
- Selecting main button reveals dropdown menu with two active options plus exit:
  - NoteBrowser - this option allows the user to select any single note and show all occurrances of this note on the fretboard.
  - ScaleBrowser - this option allows the user to show the location of notes in 4 common scales in any key:  
      - major, minor, major harmonic, minor harmonic, major melodic, minor melodic 
  - In both NoteBrowser and ScaleBrowser the notes are presented at the top as a set of 12 buttons. These can be pressed via mouse or by hotkeys. 
    - The hot keys for the natural notes are a, b, c, d, e, f, g. The hotkeys for the sharp notes are <shift> + a, b, c, d, e, f, g  

	There are going to be lots of issues at present but these I already know of: 
- Exit button doesn't work in any but the main menu (Press escape to back out of anywhere in the program)
- Scale buttons don't react to mouse clicks 
- Pattern buttons don't react to mouse clicks 

Muscians note: I am learning music theory and am very much a beginner. One issue that I already know of is the very unfamiliar Major Melodic mode. I discovered that there is some debate as to this being a legitimate scale mode. From what I have read it is valid, and therefore it stays as presented.  

The program is separated into several include files. Each has its own namespace. This is an expirement in coding style that I am so far happy with. 
There are some global variables but just about all of them are pointers to self managed memory types. 
Some code is left over from previous incarnations of this program and it may seem like more than one coding method involved. I will get around to cleaning that up. 

Here is the file list:
	aMain.bas - This is the entry point of the program. It is a namespace called Main_ and almost all bi file are included here in this namespace. At the end of this file is the global namespace in which the program executes these commands: 
		- __graphics()    - This macro creates a graphic window using screenres. It can be found in the file Sundry.bi 
		- Main_.init()    - This initializes the guitar image and other program starting variables 
		- Main_.MainMenu_.show()  - This runs the main menu loop 
Sundry.bi - This is a large collection of utilities that I use in a number of different programs. TODO: This file could use some cleaning up
Range.bi  - This file is included by Sundry.bi and it is a range handling class. It began as a small type but then morphed into what it is now, and it needed its own file. 
Mouse.bi  - This file is included by Sundry.bi and it is mouse handling made easy for me. 
crt/string.bi - This file is included byt Sundry.bi. This file is necessary for the split function created by Marpon that is in Sundry.bi 
NOTE: the split function by Marpon and the hidword/lodword macros by Mr. Swiss are the only code that I did not create. 
Palette.bi  - This file defines colors that I limit the program to use. 
Button.bi - This file defines a button class used in the menu bar accross the top and the status bar accross the bottom. 
Data.bi - This file contains data for a feature that was in a previous incarnation but is not yet in development for the current program. (Ignore this) 
Notes.bi  - This file contains classes that help to interact with musical notes and notation. 
Guitar.bas/.bi  - These two files contain the definition of the TGuitar class that is used to display the guitar and find notes along its fret board. 
StatusBar.bi  - This file contains the StatusBar_ namespace that is used to interact with the status bar at the bottom. 
MenuBar.bi  - This file contains the MenuBar_ namespace that is used to interact with the menu bar accross the top.
NoteBar.bi  - This file contains the NoteBar_ namespace that is used to show the note buttons along the top.
PatternBar.bi - This file contains the PatternBar_ namespace that shows buttons in the status bar. This is in development and does nothing yet important. 
NoteBrowser.bi - This file contains the NoteBrowser_ namespace. This is the one of the two methods of using this program as mentioned earlier in this readme. 
ScaleBrowser.bi   - This file contains the ScaleBrowser_ namespace. This is the second of the two methods of using this program as mentioned earlier in this readme. 
ModeMenu.bi   - This is ModeMenu_ namespace. It handles the dropdown of the main menu. 
MainMenu.bi   - This is the MainMenu_ namespace. It displays the three menu items Main, File, Help. (currently only Main is active) 
Graphics.bi - This file is a hold-over from a previous incarnation. It does a few graphics display routines. It will likely get merged out of existance. 
aMain.exe   - If you want to run the program without compiling it, this is a windows 7 executable. Watch the commit note to see if it is up to date.
Fretboard_aide.fbp  - This is a freebasic project file for the IDE FBEdit. 

