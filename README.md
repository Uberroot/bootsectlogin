# bootsectlogin
POC of a phishing attack where USB access is possible

* Build the supporting image generation tools, makeimg.cpp and stripleading.cpp
* Run buildproject.bat (a linux flavor is trivial to make)
* dd or unetbootin image to a target USB drive
* Boot from the drive on the target computer
* A prompt should appear for a username and password which will be written to the second sector on the drive
* Following prompt entry, the next bootable drive will be found and booted (USB can be removed at this time)
