' assimp.bmx

Strict

Rem
bbdoc: Assimp for Openb3d
about: Assimp mesh loader and a few helper functions. 
To build Assimp use @{bmk makemods -a -w -g x64 openb3dmaxlibs.assimp}.
Requires BaH.Boost source and Koriolis.Zipstream module binaries, see source links below.
To get BaH.Boost with Subversion open command-line and be sure you "cd" to bah.mod before checkout.
End Rem
Module Openb3dmaxlibs.Assimp

ModuleInfo "Version: 0.42"
ModuleInfo "License: BSD-3-Clause"
ModuleInfo "Copyright: Wrapper - 2009-2018 Peter Scheutz"
ModuleInfo "Copyright: Library - 2006-2012 Assimp team"
ModuleInfo "Source: https://github.com/markcwm/openb3dmaxlibs.mod"
ModuleInfo "Source: svn checkout https://github.com/maxmods/bah.mod/trunk/boost.mod"
ModuleInfo "Source: https://github.com/maxmods/koriolis.mod"
ModuleInfo "Source: https://github.com/assimp/assimp"

Import Openb3dmax.Openb3dmax
Import Openb3dmaxlibs.Assimplib

Include "types.bmx"

Rem
bbdoc: FitMesh for meshes with children.
End Rem
Function FitAnimMesh( m:TEntity, x#, y#, z#, w#, h#, d#, uniform:Int=False )
	aiHelper.FitAnimMesh( m, x, y, z, w, h, d, uniform )
End Function

Rem
bbdoc: Creates a list of valid files to load.
EndRem
Function EnumFiles( list:TList, dir:String, skipExt:TList )
	aiHelper.EnumFiles( list, dir, skipExt )
End Function
