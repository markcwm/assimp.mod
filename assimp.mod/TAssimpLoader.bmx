
' assimp mesh loader
Type TAssimpLoader

	Function LoadMesh:TMesh(stream:TStream, url:Object, parent:TEntity=Null, flags:Int = -1)
	
		aiScene.Log_Assimp = TGlobal.Log_Assimp
		
		Local filename:String = String(url)
		Local scene:aiScene = New aiScene
		Local root:TMesh
		?ptr64
		Local pointer:Long Ptr
		?Not ptr64
		Local pointer:Int Ptr
		?
		
		' removed, caused crash
		'aiSetImportPropertyInteger(aipropertystore?, AI_CONFIG_PP_SBP_REMOVE, aiPrimitiveType_LINE | aiPrimitiveType_POINT )
		
		Select flags
			Case -1 ' smooth shaded
				flags = aiProcess_Triangulate | ..
				aiProcess_GenSmoothNormals | ..
				aiProcess_SortByPType | ..
				aiProcess_PreTransformVertices | ..
				aiProcess_ConvertToLeftHanded | ..
				aiProcess_JoinIdenticalVertices
			Case -2 ' flat shaded
				flags = aiProcess_Triangulate | ..
				aiProcess_GenNormals | ..
				aiProcess_SortByPType | ..
				aiProcess_PreTransformVertices | ..
				aiProcess_ConvertToLeftHanded | ..
				aiProcess_CalcTangentSpace | ..
				aiProcess_FindDegenerates | ..
				aiProcess_FindInvalidData | ..
				aiProcess_GenUVCoords | ..
				aiProcess_TransformUVCoords
		EndSelect
		
		If stream = Null
			pointer = scene.ImportFile(filename, flags)
		Else
			pointer = scene.ImportFileFromStream(stream, filename, flags)
		EndIf
		
		If pointer <> Null
		
			' Make brushes
			
			Local id:Int, index:Int, brushes:TBrush[scene.NumMaterials]
			
			For Local mat:aiMaterial = EachIn scene.Materials
			
				If TGlobal.Log_Assimp Then DebugLog " "
				If TGlobal.Log_Assimp Then DebugLog " ----    Material Name " + mat.GetMaterialName()
				If TGlobal.Log_Assimp Then DebugLog " ----    mat.IsTwoSided() " + mat.IsTwoSided()
				If TGlobal.Log_Assimp Then DebugLog " ----    mat.GetShininess() " + mat.GetShininess()
				If TGlobal.Log_Assimp Then DebugLog " ----    mat.GetAlpha() " + mat.GetAlpha()
				
				'Rem
				Local names:String[] = mat.GetPropertyNames()
				
				For Local s:String = EachIn names
				
					If TGlobal.Log_Assimp Then DebugLog "Property: *" + s + "*"
					'DebugLog "matbase " + mat.Properties[?].GetFloatValue(s)
					
					Select s
						Case AI_MATKEY_TEXTURE_BASE
							If TGlobal.Log_Assimp Then DebugLog "matbase " +  mat.GetMaterialString(s)
					End Select
					
				Next
				'EndRem
				
				Local DiffuseColors:Float[] = mat.GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)	
				
				brushes[id] = CreateBrush(mat.GetDiffuseRed() * 255,mat.GetDiffuseGreen() * 255,mat.GetDiffuseBlue() * 255)
				
				' seems alpha comes in different places denpending on model format
				' seems wavefront obj alpha doesn't load
				'BrushAlpha brushes[id],mat.GetAlpha()' * mat.GetDiffuseAlpha() (might be 0 so not good)
				
				BrushShininess brushes[id],mat.GetShininess()
				
				If mat.IsTwoSided()
					'BrushFX brushes[id], 16
				EndIf
				
				Local texFilename:String = mat.GetMaterialTexture()
				
				If TGlobal.Log_Assimp Then DebugLog "TEXTURE filename: " + texFilename
				
				If Len(texFilename)
				
					' remove currentdir prefix, but leave relative subfolder path intact
					If  texFilename[..2] = ".\" Or texFilename[..2] = "./"
						texFilename = texFilename[2..]
					EndIf
					
					'assume the texture names are stored relative to the file
					texFilename  = ExtractDir(filename) + "/" + texFilename
					
					If Not FileType(texFilename)
						texFilename = ExtractDir(filename) + "/" + StripDir(texFilename)
					EndIf
					
					If TGlobal.Log_Assimp Then DebugLog texFilename
					
					'If FileType(texFilename)
						'DebugStop
					Local tex:TTexture=LoadTexture(texFilename, TGlobal.Texture_Flags)
					
					If tex Then BrushTexture brushes[id], tex	
					
					'EndIf
					
				EndIf
				
				id:+1
			Next
			
			If TGlobal.Log_Assimp Then DebugLog "scene.numMeshes: " + scene.numMeshes
			
			' Make mesh - was ProccessAiNodeAndChildren()
			
			Local mesh:TMesh, child_id:Int=0
			
			If scene.rootNode.numMeshes = 0 And scene.rootNode.NumChildren > 0 ' dummy root node
				mesh = NewMesh()
				mesh.SetString(mesh.class_name, "Mesh")
				mesh.EntityListAdd(TEntity.entity_list)
				
				mesh.AddParent(parent)
				mesh.SetString(mesh.name, scene.rootNode.name)
				root = mesh
			EndIf
			
			For Local am:aiMesh = EachIn scene.meshes
			
				mesh = NewMesh()
				mesh.SetString(mesh.class_name, "Mesh")
				mesh.EntityListAdd(TEntity.entity_list)
				
				If scene.rootNode.NumChildren = 0 ' root node has no children
					mesh.AddParent(parent)
					mesh.SetString(mesh.name, scene.rootNode.name)
					root = mesh
				ElseIf child_id < scene.rootNode.Children.length
					mesh.AddParent(root)
					mesh.SetString(mesh.name, scene.rootNode.Children[child_id].name)
					child_id:+1
				EndIf
				
				Local surf:TSurface = CreateSurface(mesh, brushes[am.MaterialIndex])
				
				' vertices, normals and texturecoords - was MakeAiMesh()
				
				For id = 0 To am.NumVertices - 1
					'DebugLog  am.VertexX(i) + ", " + am.VertexY(i) + ", " + am.VertexZ(i)
					
					index = AddVertex(surf, am.VertexX(id), am.VertexY(id), am.VertexZ(id))
					
					If am.HasNormals()
						VertexNormal(surf, index, am.VertexNX(id), am.VertexNY(id), am.VertexNZ(id))
					EndIf
					
					If am.HasTextureCoords(0)
						VertexTexCoords(surf, index, am.VertexU(id), am.VertexV(id), am.VertexW(id))
					EndIf
					
					If am.HasTextureCoords(1)
						VertexTexCoords(surf, index, am.VertexU(id, 1), am.VertexV(id, 1), am.VertexW(id, 1))
					EndIf
				Next
				
				For id = 0 To am.NumFaces - 1
					'DebugLog  am.TriangleVertex(id,0) + " , "  + am.TriangleVertex(id,1) + " , "  + am.TriangleVertex(id,2)
					
					' this check is only in because assimp seems to be returning out of range indexes
					' on rare occasions with aiProcess_PreTransformVertices on.
					Local validIndex:Int = True
					
					' added 0.36 - fix for MAV when garbage index values < zero
					If am.TriangleVertex(id,0) < 0 Then validIndex = False
					If am.TriangleVertex(id,1) < 0 Then validIndex = False
					If am.TriangleVertex(id,2) < 0 Then validIndex = False
					
					If am.TriangleVertex(id,0) >=am.NumVertices Then validIndex = False
					If am.TriangleVertex(id,1) >=am.NumVertices Then validIndex = False
					If am.TriangleVertex(id,2) >=am.NumVertices Then validIndex = False
					
					If validIndex
						AddTriangle(surf, am.TriangleVertex(id,0), am.TriangleVertex(id,1), am.TriangleVertex(id,2))
					Else
						If TGlobal.Log_Assimp Then DebugLog "TriangleVertex index was out of range for triangle num: " + id
						If TGlobal.Log_Assimp
							DebugLog "indexes: "+am.TriangleVertex(id,0)+", "+am.TriangleVertex(id,1)+", "+am.TriangleVertex(id,2)
						EndIf
					EndIf
				Next
				
			Next
			
			scene.ReleaseImport() ' only when pointer valid
			
		Else
		
			If TGlobal.Log_Assimp Then DebugLog "Nothing imported"
			If TGlobal.Log_Assimp Then DebugLog "Error: "+String.FromCString( aiGetErrorString() )
			
		EndIf
		
		Return root
		
	End Function
	
End Type
