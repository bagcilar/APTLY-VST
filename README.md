# aptly-bash

# About
* This is a bash script developed for Linux and Windows platforms for batch processing of VST effect plugins
* Developed for EECS 4080 - Computer Science Project at York University, under supervision of [Dr. Vassilios Tzerpos](http://bil.eecs.yorku.ca/)
# Getting Started
## MrsWatson
* Detailed information on MrsWatson can be found [here](http://teragonaudio.com/MrsWatson.html)
## Linux
* run setup.sh as root to install MrsWatson and support for i386 architecture, which is necessary for processing 32-bit plugins
* run the following command to ensure MrsWatson 0.9.8 is installed properly:
``
mrswatson --version
``

## Windows
* ensure chocolately package manager is installed. Instructions can be found [here](https://chocolatey.org/install) 
* afterwards, run the following command to install MrsWatson on powershell: 
``
choco install mrswatson
``
* 32-bit plugins can be processed without additional configuration

# Usage
* Usage is identical in Linux and Windows platforms
* In Windows, run your terminal as administrator
* Help menu can be displayed using the ``-h`` option
* The full help menu with examples can be displayed using ``-h full``
* Run with ``-v`` or ``--verbose`` in order to display the MrsWatson output for each file

## Creating preset files using Audacity
* For detailed information, follow [this link](https://wiki.audacityteam.org/wiki/VST_Plug-ins)
### Adding VST plugins to Audacity:
#### Windows
* Audacity can only process 32-bit plugins in Windows, regardless of system architecture
* Place your plugins inside the plugins folder of Audacity installation directory
#### Linux
* 32-bit linux systems can only process 32-bit plugins, 64-bit linux systems can only process 64-bit plugins
* Install Audacity 2.3.3 using ``apt-get install audacity``
* Place your plugins inside ``/usr/lib/vst`` or ``usr/local/lib/vst``
#### Exporting preset files:
* Enable plugins through Effect -> Add / Remove Plug-ins... menu
* Apply the plugin to a sound file using the Effect menu to bring up the plugin GUI
* Use the options -> export to export the parameters as a preset .fxp file