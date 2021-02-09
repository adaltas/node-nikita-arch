# Architecture



# Overview

**`node-nikita-arch`** leverages our automation and deployment solution written in Nodejs, [Nikita](https://nikita.js.org/), to provide tools for automated installation of Arch Linux on a local or remote machine. Of note we provide here two main Nodejs modules, `bootstrap` and `system`, that encapsulate a set of Nikita actions to ***(i)*** setup disk partitions and mount them accordingly, ***(ii)*** install and configure mandatory system requirements and drivers and ***(iii)*** run services and install more specific softwares (e.g., Atom, Sublime Text, Java, ) based on user configuration.



# Code map

Herein we will describe the important modules and piece of code that articulate our repository. We will focus notably on how each interact with others to provide a comprehensive deployment and installation of Arch Linux.

#### `lib/`

The `lib` directory includes 3 directories `actions`, `bootstrap` and `system` that we describe hereafter and 3 scripts written in Coffeescript.

##### `config.coffee`

This script will write a `user.yaml` configuration file that contains default settings for `bootstrap` and `system`. Additionally user input is expected in order to define whether installation is going to be performed locally or remotely using `ssh`. If remote installation is chosen users will be prompted to enter: ***(i)*** SSH target IP address, ***(ii)*** SSH target password and ***(iii)*** SSH target port. 

Finally user input will be asked to define ***(i)*** Disk encryption password, ***(ii)*** Arch Linux user name and ***(iii)*** Arch Linux user password. 

Ultimately the `user.yaml` file will be recursively merged with other configuration objects defined in the `config/` directory to provide all settings, context and actions necessary to bootstrap and install Arch Linux OS and softwares.

##### `run.coffee`

This script is used to register some Nikita actions defined in `lib/actions` for later use. Most importantly it will merge all user configuration file and objects, instantiate a Nikita object in order to call and run all expected Nikita actions. Configuration inputs generated in this script will serve to contextualize our Nikita actions according to the user configuration.

##### `index.coffee`

This is the entry point of our modules. It runs asynchronously `config.coffee` then `run.coffee`. The process is encapsulated inside an exception handling block.

##### `actions`

##### `bootstrap`

This directory contains 3 distinct scripts `1.welcome.coffee`, `2.disk.coffee` and `3.system.coffee` that are going to be run in order as defined in the `conf/bootstrap.coffee`. 

The `2.disk.coffee` script leverages a set Nikita actions that will partition, format and encrypt the disks according to user configuration. The `3.system.coffee` script defines a set of mandatory and predefined Nikita actions that will mount the disks and install required drivers and packages to get a basic and well-functioning Arch Linux distribution.

##### `system`

Similarly this directory contains 3 distinct scripts `1.system.coffee`, `2.dev.coffee` and `3.office.coffee` that are going to be run in order as defined in the `conf/system.coffee` script.

The `1.system.coffee` 



#### `conf/`





