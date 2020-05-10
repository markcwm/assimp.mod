Scheutz.Assimp
==============

#### Assimp (Open Asset Import) ####

Assimp 3.2 library wrapper for OpenB3DMax.

Assimp source is included with this module and [Boost](http://www.boost.org/users/history/) is required, specifically [BaH.Boost](https://github.com/maxmods/bah.mod). There is a Boost workaround option which can be enabled in assimplib.bmx (and then comment the boost imports in source.bmx) but this is not recommended as it lacks threads and is not threadsafe ie. can't be access by more than one thread at a time. To enable a specific importer or post processing step, comment out the define in assimplib.bmx, then uncomment the imports in source.bmx.

The wrapper imports the C++ source and load meshes from streams either incbin or zip, so for unzip functionality [Koriolis.Zipstream](https://github.com/maxmods/koriolis.mod) is required. The module works in 32 and 64-bit but animations are not yet implemented.

#### Installation ####

* Copy **scheutz.mod** to your `BlitzMax/mod` folder, module folder names must end in **.mod**
* If Windows, make sure you have a working version of MinGW. If Mac, make sure you have XCode installed. If Linux, have a look at this guide:
 [How To: Install BlitzMax NG on Win/Mac/Ubuntu 64-bit](https://www.syntaxbomb.com/index.php/topic,61.0.html)
* Open a Terminal, cd to `BlitzMax/bin` and for BRL Bmx type `bmk makemods -d scheutz.assimp`
* For NG in 64-bit use `bmk makemods -d -w -g x64 scheutz.assimp`, if on Mac/Linux use `./bmk`

#### License ####

Both the library and wrapper are licensed with the 3-clause BSD license.
