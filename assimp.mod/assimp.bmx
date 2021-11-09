' assimp.bmx

Strict

Rem
bbdoc: Assimp for Openb3d
about: Assimp mesh loader and a few helper functions. 
To build Assimp use @{bmk makemods -a -w -g x64 assimp.assimp}.
Requires BaH.Boost source and Koriolis.Zipstream module binaries, see source links below.
To get BaH.Boost with Subversion open command-line and be sure you "cd" to bah.mod before checkout.
End Rem
Module Assimp.Assimp

ModuleInfo "Version: 0.43"
ModuleInfo "License: BSD-3-Clause"
ModuleInfo "Copyright: Wrapper - 2009-2021 Peter Scheutz"
ModuleInfo "Copyright: Library - 2006-2012 Assimp team"
ModuleInfo "Source: https://github.com/markcwm/assimp.mod"
ModuleInfo "Source: svn checkout https://github.com/maxmods/bah.mod/trunk/boost.mod"
ModuleInfo "Source: https://github.com/maxmods/koriolis.mod"
ModuleInfo "Source: https://github.com/assimp/assimp"

Import Openb3d.Openb3d
Import Assimp.Assimplib

Include "aitypes.bmx"
Include "TAssimpLoader.bmx"
Include "TAssimpEntity.bmx"
Include "TMeshLoaderAssimp.bmx"

Rem
bbdoc: FitMesh for meshes with children.
End Rem
Function FitAnimMesh( m:TEntity, x#, y#, z#, w#, h#, d#, uniform:Int=False )
	TAssimpEntity.FitAnimMesh( m, x, y, z, w, h, d, uniform )
End Function

Rem
bbdoc: Creates a list of valid files to load.
EndRem
Function EnumFiles( list:TList, dir:String, skipExt:TList )
	TAssimpHelper.EnumFiles( list, dir, skipExt )
End Function
