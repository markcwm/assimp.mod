
Type TMeshLoaderAssimp Extends TMeshLoader
	
	Method CanLoadMesh:Int( extension:String )
	
		Return aiIsExtensionSupported(extension.ToLower())
		
	End Method
	
	Method LoadMesh:TMesh( file:TStream,url:Object,parent:TEntity=Null,flags:Int=-1 )
	
		If Not (TGlobal3D.Mesh_Loader=0 Or (TGlobal3D.Mesh_Loader & 4)) Then Return Null
		
		Local anim_mesh:TMesh=TAssimpLoader.LoadAnimAssimp(Null, url, parent, TGlobal3D.Mesh_Flags)
		
		If anim_mesh=Null Then Return Null
		anim_mesh.HideEntity()
		Local mesh:TMesh=anim_mesh.CollapseAnimMesh()
		anim_mesh.FreeEntity()
		
		mesh.SetString(mesh.class_name,"Mesh")
		mesh.AddParent(parent)
		mesh.EntityListAdd(TEntity.entity_list)
		
		' update matrix
		If mesh.parent<>Null
			mesh.mat.Overwrite(mesh.parent.mat)
			mesh.UpdateMat()
		Else
			mesh.UpdateMat(True)
		EndIf
		
		Return mesh
		
	End Method
	
	Method LoadAnimMesh:TMesh( file:TStream,url:Object,parent:TEntity=Null,flags:Int=-1 )
	
		If Not (TGlobal3D.Mesh_Loader=0 Or (TGlobal3D.Mesh_Loader & 4)) Then Return Null
		
		Return TAssimpLoader.LoadAnimAssimp(Null, url, parent, TGlobal3D.Mesh_Flags)
		
	End Method
	
End Type

Type TMeshLoaderAssimpStream Extends TMeshLoader
	
	Method CanLoadMesh:Int( extension:String )
	
		Return aiIsExtensionSupported(extension.ToLower())
		
	End Method
	
	Method LoadMesh:TMesh( file:TStream,url:Object,parent:TEntity=Null,flags:Int=-1 )
	
		If Not (TGlobal3D.Mesh_Loader=0 Or (TGlobal3D.Mesh_Loader & 8)) Then Return Null
		
		Local anim_mesh:TMesh=TAssimpLoader.LoadAnimAssimp(file, url, parent, TGlobal3D.Mesh_Flags)
		
		If anim_mesh=Null Then Return Null
		anim_mesh.HideEntity()
		Local mesh:TMesh=anim_mesh.CollapseAnimMesh()
		anim_mesh.FreeEntity()
		
		mesh.SetString(mesh.class_name,"Mesh")
		mesh.AddParent(parent)
		mesh.EntityListAdd(TEntity.entity_list)
		
		' update matrix
		If mesh.parent<>Null
			mesh.mat.Overwrite(mesh.parent.mat)
			mesh.UpdateMat()
		Else
			mesh.UpdateMat(True)
		EndIf
		
		Return mesh
		
	End Method
	
	Method LoadAnimMesh:TMesh( file:TStream,url:Object,parent:TEntity=Null,flags:Int=-1 )
	
		If Not (TGlobal3D.Mesh_Loader=0 Or (TGlobal3D.Mesh_Loader & 8)) Then Return Null
		
		Return TAssimpLoader.LoadAnimAssimp(file, url, parent, TGlobal3D.Mesh_Flags)
		
	End Method
	
End Type

New TMeshLoaderAssimp
New TMeshLoaderAssimpStream
