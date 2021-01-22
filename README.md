# Archiving your collection
As I haven't found a good source on archiving your personal collection of Atari software on floppy disk, I documented my own progress, so others might benefit from it.

I started looking for methods to copy my floppies to a PC so that when my 1050(s) break down, I still have some of my source code, letters, games, etc. As I only have recent hardware in the form of Apple, PC (intel) 'antiques' - albeit almost 20 years younger than my atari's - laptops from Y2k or a little bit more recent and several 'embedded' stuff in the form of Arduino and Raspberry Pi's, I started off this journey by looking into the various methods that are available to hook up one of the aforementioned devices to my Atari and 1050 setup so I could start archiving.

# SIO2[Something Recent]

A very promising device is the SIO2PC/10502PC Dual USB device sold by Atari8Warez. Except that I had an encounter with murphy and got the latest version that contains a bug that renders it useless for my archiving purposes (this is being fixed at the moment). Lotharek sells a similar device, but I have not purchased that (yet). The second option I looked into was the SIO2Arduino setup, but it was too simplistic for archiving purposes (also, hooking up buttons and a display I didn't have in my parts bin made it too cumbersome for me). The last option I tried was the SIO2Pi interface: 4 wires, a diode and a level converter was all it took - All you have to remember is that every image of the SIO connector shows its backside (where the cable is hooked up). Once I got around that a new problem arose...

# Copy Tools

Having been out of Atari business for at least 2 decades I couldn't recall which sector copiers I used to copy disks for swapping purposes, So I downloaded a bunch of Utility disks and started testing. The list below consists of tools I tested and my personal experience with them.

|Tool  |Type  |Pro's  |Con's  |
|------|------|-------|-------|
|Super Duper  |Sector Copier  |Retry Damaged Sectors  |Highly interactive, Multi Stage Copy (48K RAM), Copies only in Single Density Mode  |
|Super Duper Enhanced Density  |Sector Copier  |Retry Damaged Sectors  |Highly interactive, Multi Stage Copy (48K RAM), Manual Density Selection  |
|(Un)Happy Sector Copier by Spike  |Sector Copier  |Auto Density Detection  |Aborts on Damaged Sector  |
|Backup Master 130 XE  |Sector Copier  |Auto Density Detection (?)  |Abort/Skip Damaged Sector  |
|\*Copymate XE 3.7  |Sector Copier  |Retry Damaged Sectors(Max 7x)  |Skips After Max Retries  |
\*Denotes my tool of choice.

Armed with a tool of choice, a Raspberry Pi with a level converter hooked up to the GPIO port on one side, and a SIO plug hooked up to the Atari 800XL on the other, I made some manual dumps of my most precious floppies before life got in the way.

Fast forward a bit more than two years and here I am again in the process of archiving my collection. In the past two years I got a bit more current with the state of the Atari 8 bit scene, but didn't make any progress with archiving my floppy collection, that is, until now.

# Copying/Archiving

## Hardware
The current archiving setup consists of an Atari 65XE (PAL), two 1050 drives (Happy enhanced), the 384/576XE Memory Expansion card, a Lotharek SIO2PC adapter connected to a 1010 and a first generation Raspberry Pi.

## Alt Hardware
An alternative setup which I use more frequently consists of:
  * PAL 600XL w/ the Antonia 4MB memory expansion
  * The latest [MyBIOS](http://www.mr-atari.com/myidehome.htm) OS
  * A 1st generation Banana Pi running [DietPi](https://DietPi.com) w/ [poor man's SIO](https://oshpark.com/shared_projects/cvBmkVl4) adapter.
  * Lotharek's [SIO Splitter](https://lotharek.pl/productdetail.php?id=158)
  * 2 x Atari 1050 disk drives w/ Happy mod

# Software

The Pi boots a minimal environment which also contains the ARM version of [sio2bsd](https://github.com/TheMontezuma/SIO2BSD). On it I mount my NAS via NFS so all the disk images are immediately available on my home network. I login as a regular user and start the diskarchive.sh script in the directory I want to store the images in.

## diskarchive Script

After starting the script, you are given a couple of options:
```

 *** DISK ARCHIVER ***
READY
Disk Name ('q' to Quit, 's' for Settings, 't' to load Tooldisk)?
```
**Q** followed by **ENTER** quits the script.

### Settings
**S** (+ **ENTER**) takes you to the settings. There are some hardcoded defaults in the script, which you can be override via a config file. Once you set all the options, the script gives an overview of your selection and prompts you to write them to the config file.
```
Update Settings...
Initial disk name: 
Use previous values (Disk name/Description) [y/n] [Current: y]: y
Image directory [Current: ./]: ./
Tooldisk (No extension) [Current: Tooldisk]: Tooldisk
Serial device [Current: /dev/ttyS2]: /dev/ttyS2
sio2bsd parameters [Current: -s /dev/ttyS2 -q pal]: -s /dev/ttyS2 -q pal

New settings:
# Settings
DISK=""                         ;# Initial disk name
PREVDISK="${DISK}"
USEPREV="y"                     ;# Use previous values (Disk name/Description)
DISKDIR="./"                    ;# Directory to store images, log and nfo files
TOOLDISK="Tooldisk"             ;# Tooldisk name (no extension, assuming .atr)
SERIAL="/dev/ttyS2"             ;# SIO2* Serial device name
SIOPARM="-s /dev/ttyS2 -q pal"  ;# sio2bsd parameters


Write to ./diskarchive.cfg [Y/n]?
```
You don't have to save the settings, in case you want to use the revised settings for a single archiving session.

### Tooldisk
To ease loading of copy tools, pressing **T** + **ENTER** loads a special disk image (set in the config variable TOOLDISK). In my case it is an atr with my preferred version of Copymate XE.
```
 *** DISK ARCHIVER ***
READY
Disk Name ('q' to Quit, 's' for Settings, 't' to load Tooldisk)? t

Mounting tooldisk.
Boot the Atari and load your preferred disk copy tool. Press any key when your copier is loaded succesfully...
```

### Disk image creation
When you enter a disk name, followed by **ENTER**, the script prompts for a one line description. Here you can enter a meaningfull description of the disk contents like the name of the game. Completing the description with **ENTER** starts the disk creation and waits for the copier to complete:
```
 *** DISK ARCHIVER ***
READY
Disk Name ('q' to Quit, 's' for Settings, 't' to load Tooldisk)? disknr80b
One line description for the disk: The Hulk

If using the wrong disk type, press 's' for SD or 'd' for DD or 'e' for ED...
 !-!-! If you want to tag the current disk as containing Bad Sectors !-!-!
 !-! Press the 'b' key to add that information to the disknr80b.nfo file !-!
Press any other key when copy is completed succesfully...
```
The script creates an *130k **ED*** disk image by default and prompts you to choose to either select a different image size (**S** for SD (90k), **E** for ED (130k), **D** for DD (180k)), tag the copy as having bad sectors (appends the text BAD SECTORS to the contents of the .nfo file) or to press any other key to write the log file and repeat the proces.

The next prompt for a disk name after completing the copy sets the disk name and its description to the one previously used. If you want to reenter the info each round, set the USEPREV value to **n**.

# Copymate XE 3.7 - Key Reference

For easy reference in the future, here's a list of keys and their function within the Copymate program:

|Key  |Function  |
|-----|----------|
|[START]	|Begin Read/Write  |
|[OPTION]	|Repeat Write  |
|[SELECT]	|Ends Source Reads  |
|[HELP]	|Help screen  |
|TAB	|Start 80track Copy  |
|RETURN	|Start DS/DD Copy  |
|S,D,F,V	|Toggle Options  |
|ARROW	|Change Screen Colors  |
|CTRL-ESC	|Reboot  |
|ESC	|To DOS  |
