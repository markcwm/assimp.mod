' types.bmx

' mesh bounds values, used in FitAnimMesh()
Type TAssimpMinMax3D

	Field maxx#, maxy#, maxz#
	Field minx#, miny#, minz#
	
End Type

Rem
 Non-essential functions which apply to all children of an entity:
 CountTrianglesAll:Int( mesh:TMesh )
 RotateEntityAxisAll ent:TEntity, axis:Int
 UpdateNormalsAll ent:TEntity
 FlipMeshAll ent:TEntity
 ScaleMeshAxisAll ent:TEntity, axis:Int
EndRem
Type TAssimpEntity

	Global mm:TAssimpMinMax3D=New TAssimpMinMax3D
	
	Function CountTrianglesAll:Int(ent:TEntity)
	
		If ent = Null Then Return 0
		Local all%
		
		For Local id% = 1 To CountSurfaces(TMesh(ent))
			Local surf:TSurface = GetSurface(TMesh(ent), id)
			Local nt% = CountTriangles(surf)
			all:+ nt
		Next
		
		Return all
		
	End Function
	
	' renamed from FlipRot (applied to all children of an entity)
	Function RotateEntityAxisAll(ent:TEntity, axis:Int)
	
		If ent = Null Then Return
		Local cc:Int = CountChildren(ent)
		
		If cc
			For Local id:Int = 1 To cc
				RotateEntityAxisAll(GetChild(ent, id), axis)
			Next
		EndIf
		
		Local rotX:Float = EntityPitch(ent)
		Local rotY:Float = EntityYaw(ent)
		Local rotZ:Float = EntityRoll(ent)
		
		Select axis
			Case 1
				rotX = -rotX
			Case 2
				rotY = -rotY
			Case 3
				rotZ = -rotZ
		End Select
		
		RotateEntity ent, rotX, rotY, rotZ
		
	End Function
	
	' dirty x model fixer - renamed from UpdateEntityNormals (applied to all children of an entity)
	Function UpdateNormalsAll(ent:TEntity)
	
		If ent = Null Then Return
		Local childcount:Int = CountChildren(ent)
		
		If childcount
			For Local id:Int = 1 To childcount
				UpdateNormalsAll(GetChild(ent, id))
			Next
		EndIf
		
		If EntityClass(ent) = "Mesh"
			UpdateNormals TMesh(ent)
		EndIf
		
	End Function
	
	' renamed from FlipEntity (applied to all children of an entity)
	Function FlipMeshAll(ent:TEntity)
	
		If ent = Null Then Return
		Local childcount:Int = CountChildren(ent)
		
		If childcount
			For Local id:Int = 1 To childcount
				FlipMeshAll(GetChild(ent, id))
			Next
		EndIf
		
		If EntityClass(ent) = "Mesh"
			FlipMesh TMesh(ent)
		EndIf
		
	End Function
	
	' dirty x model fixer - renamed from ScaleFlipEntity (applied to all children of an entity)
	Function ScaleMeshAxisAll(ent:TEntity, axis:Int)
	
		If ent = Null Then Return
		Local childcount:Int = CountChildren(ent)
		
		If childcount
			For Local id:Int = 1 To childcount
				ScaleMeshAxisAll(GetChild(ent, id), axis)
			Next
		EndIf
		
		Local scaleX:Float = 1
		Local scaleY:Float = 1
		Local scaleZ:Float = 1
		
		Select axis
			Case 1
				scaleX = -scaleX
			Case 2
				scaleY = -scaleY		
			Case 3
				scaleZ = -scaleZ
		End Select
		
		If EntityClass(ent) = "Mesh"
			ScaleMesh TMesh(ent), scaleX, scaleY, scaleZ
		EndIf
		
	End Function
	
	' uses doFitAnimMesh() and getAnimMeshMinMax()
	Function FitAnimMesh(m:TEntity, x#, y#, z#, w#, h#, d#, uniform:Int=False)
	
		Local scalefactor#
		Local xoff#, yoff#, zoff#
		Local gFactor# = 100000.0
		
		mm.maxx = -100000
		mm.maxy = -100000
		mm.maxz = -100000
		
		mm.minx = 100000
		mm.miny = 100000
		mm.minz = 100000
		
		getAnimMeshMinMax(m, mm)
		
		'DebugLog "getAnimMeshMinMax "+String(mm.minx).ToInt()+", "+String(mm.miny).ToInt()+", "+..
		' String(mm.minz).ToInt()+", "+String(mm.maxx).ToInt()+", "+String(mm.Maxy).ToInt()+", "+String(mm.maxz).ToInt()	
		
		Local xspan# = (mm.maxx - mm.minx)
		Local yspan# = (mm.maxy - mm.miny)
		Local zspan# = (mm.maxz - mm.minz)
		
		Local xscale# = w / xspan
		Local yscale# = h / yspan
		Local zscale# = d / zspan
		
		'DebugLog "Scales: " + xscale + ", " +  yscale + ", " + zscale 
		
		If uniform
			If xscale < yscale
				yscale = xscale
			Else
				xscale = yscale
			EndIf
			
			If zscale < xscale
				xscale = zscale
				yscale = zscale			
			Else
				zscale = xscale
			EndIf
		EndIf	
		
		'DebugLog "Scales: " + String(xscale).ToInt() + ", " + String(yscale).ToInt() + ", " + String(zscale).ToInt()
		
		xoff# = -mm.minx * xscale - (xspan / 2.0) * xscale + x + w / 2.0
		yoff# = -mm.miny * yscale - (yspan / 2.0) * yscale + y + h / 2.0
		zoff# = -mm.minz * zscale - (zspan / 2.0) * zscale + z + d / 2.0
		
		doFitAnimMesh(m, xoff, yoff, zoff, xscale, yscale, zscale)
'		Delete mm
		
	End Function
	
	' internal functions for FitAnimMesh
	
	' used in FitAnimMesh()
	Function doFitAnimMesh(m:TEntity, xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
	
		Local c:Int
		Local childcount:Int = CountChildren(m)
		
		If childcount
			For c = 1 To childcount
				'myFitEntity(m, xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
				doFitAnimMesh(GetChild(m, c), xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
			Next
		EndIf
		
		myFitEntity(m, xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
		
	End Function
	
Rem
	Function doFitAnimMeshOLD(m:TEntity, xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
	
		Local c:Int
		Local childcount:Int = CountChildren(m)
		
		If childcount
			For c = 1 To childcount
				myFitEntity(m, xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
				doFitAnimMesh(GetChild(m, c), xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
			Next
		Else
			myFitEntity(m, xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
		EndIf
		
	End Function
EndRem
	
	' used in doFitAnimMesh()
	Function myFitEntity(e:TEntity, xoff#, yoff#, zoff#, xscale#, yscale#, zscale#)
	
		Local x#, y#, z#
		Local x2#, y2#, z2#
		Local txoff#, tyoff#, tzoff#
		
		TFormPoint(0, 0, 0, e, Null)
		
		x2 = TFormedX()
		y2 = TFormedY()
		z2 = TFormedZ()
		
		TFormPoint(x2 + xoff, y2 + yoff, z2 + zoff, Null, e)
		
		txoff = TFormedX() 
		tyoff = TFormedY()
		tzoff = TFormedZ()
		
		Local m:TMesh = TMesh(e)
		
		If m 'only if it's a mesh
		
			For Local sc:Int = 1 To CountSurfaces(m)
				Local s:TSurface = GetSurface(m, sc)
				
				For Local vc:Int = 0 To CountVertices(s) - 1
					x = VertexX(s, vc)
					y = VertexY(s, vc)
					z = VertexZ(s, vc)
					
					VertexCoords s, vc, x * xscale + txoff,y * yscale + tyoff,z * zscale + tzoff
				Next
				
			Next
			
		EndIf
		
		PositionEntity(e, EntityX(e) * xscale, EntityY(e) * yscale, EntityZ(e) * zscale)
		
	End Function
	
	' used in FitAnimMesh()
	Function getAnimMeshMinMax#(m:TEntity, mm:TAssimpMinMax3D)
	
		Local c:Int
		Local wfac#, hfac#, dfac#
		'Local tfactor
		Local cc:Int = CountChildren(m)
		
		If EntityClass(m) = "Mesh"
			'If m.class = "Mesh" 
			mm = getEntityMinMax(TMesh(m), mm)
			'Else
			'	DebugLog "Class -- " + m.class
			'Endif
		EndIf
		
		If cc
			For c = 1 To cc
				getAnimMeshMinMax(GetChild(m, c), mm)
			Next
		EndIf
		
	End Function
	
	' used in getAnimMeshMinMax()
	Function getEntityMinMax:TAssimpMinMax3D(m:TMesh, mm:TAssimpMinMax3D)
	
		Local x#, y#, z#
		Local sc:Int
		Local vc:Int
		Local s:TSurface	
		
		For sc = 1 To CountSurfaces(m)
			s = GetSurface(m, sc)	
			
			For vc = 0 To CountVertices(s) - 1
				TFormPoint(VertexX(s, vc), VertexY(s, vc), VertexZ(s, vc), m, Null)
				
				x = TFormedX()
				y = TFormedY()
				z = TFormedZ()
				
				If x < mm.minx Then mm.minx = x
				If y < mm.miny Then mm.miny = y
				If z < mm.minz Then mm.minz = z				
				
				If x > mm.maxx Then mm.maxx = x
				If y > mm.maxy Then mm.maxy = y
				If z > mm.maxz Then mm.maxz = z
			Next
			
		Next
		
		Return mm
		
	End Function
	
End Type

Type TAssimpHelper

	' Creates a list of valid files to load
	Function EnumFiles(list:TList, dir:String, skipExt:TList)
	
		Local folder:Byte Ptr = ReadDir(dir)
		Local file:String
		
		If TGlobal.Log_Assimp Then DebugLog "dir: " + dir
		
		Repeat
			file = NextFile(folder)
			
			If (file <> ".") And (file <> "..") And (file)
			
				Local fullPath:String = RealPath(dir + "/" + file)
				
				If FileType(fullPath) = FILETYPE_DIR
				
					If TGlobal.Log_Assimp Then DebugLog "file: " + file
					
					'If(dir[0]) <> "."
						EnumFiles(list, fullPath, skipExt)
					'EndIf
				Else
					If TGlobal.Log_Assimp Then DebugLog "fullPath: " + fullPath
					
					If aiIsExtensionSupported("." + Lower(ExtractExt(fullPath)))
					
						If Not skipExt.Contains(Lower(ExtractExt(fullPath))) ' Filter out formats
							list.AddLast(fullPath)
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
		Until file = Null
		CloseDir folder
		
	End Function
	
End Type
