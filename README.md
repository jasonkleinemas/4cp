# 4cp
Cli tools to compile rpg* cl* pf lf dspf

Copy these files to your user bin directory. /home/USERID/bin/

Run 4cp with out any options to get help.

  Run this from were the _obj_desc.csv is loacted. Should be base dir of your app.
  
 -h   Display help info
 
 Option c or u                                                       Required
 -c   Compile object
 -u   Data to transfer.

 -d   show debug screen                                              Optinal
 -f   Local file name. First part of file name will be object name.  Required
 -l   Library to put object.                                         Required
 -s   Source file name. Default QSRC                                 Optinal
 -x   Debug messages.                                                Optinal
 
 
The files _obj_desc.csv is for adding the description text to you obj.

The format for each line is:

filename.ext,Text
# will comment out the line.

This file will need to be where you run the command from.

Output from the commands will be created in /home/USERID/.4cp/

Start with lastCmdStd.txt. This will have the compliey listing.

