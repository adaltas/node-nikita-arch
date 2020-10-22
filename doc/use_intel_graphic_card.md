# Use Intel graphic card instead of Nvidia card:

Nvidia graphic card is used by default. If you want to use the Intel card, you must edit the file xorg.conf located in /etc/X11/.
Set intel in Screen and nvidia in Inactive:
   ```
   Section "ServerLayout"
        Identifier     "layout"
        Screen      0  "intel"
        Inactive	     "nvidia"
   ```
