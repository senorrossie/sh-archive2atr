# Archiving your collection
As I haven't found a good source on archiving your personal collection of Atari software, I documented my own progress, so others might benefit from it.

# SIO2[Something Recent]

I started looking for methods to copy my floppies to a PC so that when my 1050(s) broke down, I still had some of my source code, letters, games, etc. As I only had recent hardware in the form of Apple, PC (intel) 'antiques' - albeit almost 20 years younger than my atari's - laptops from Y2k or a little bit more recent and several 'embedded' stuff in the form of Arduino and Raspberry Pi's I started off the journey by looking into the various methods that are available to hook up one of the aforementioned devices to my Atari and 1050 setup so I could start archiving.

A very promising device is the SIO2PC/10502PC Dual USB device sold by Atari8Warez. Except that I had an encounter with murphy and got the latest version that contains a bug that renders it useless for my archiving purposes (this is being fixed at the moment). The second option I looked into was the SIO2Arduino setup, but it was too simplistic for archiving purposes (also, hooking up buttons and a display I didn't have made it too cumbersome for me). The last option I tried was the SIO2Pi interface: 4 wires, a diode and a level converter was all it took - All you have to remember is that every image of the SIO connector shows its backside (where the cable is hooked up). Once I got around that a new problem arose...

# Copy Tools

Having been out of Atari business for at least 2 decades I couldn't recall which sector copiers I used to copy disks for swapping purposes, So I downloaded a bunch of Utility disks and started testing. The list below consists of tools I tested and my personal experience.

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

# Copying (continued)

The current archiving setup consists of an Atari 65XE (PAL), two 1050 drives (Happy), the 384/576XE Memory Expansion card, a Lotharek SIO2PC adapter connected to a 1010 and a first generation Raspberry Pi.

The raspberry pi boots a minimal debian environment which also contains the ARM version of sio2bsd.

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
