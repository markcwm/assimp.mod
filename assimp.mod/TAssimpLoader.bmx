
Rem
bbdoc: Assimp mesh loader
EndRem
Type TAssimpLoader

	Rem
	bbdoc: Load Assimp mesh
	EndRem
	Function LoadAnimAssimp:TMesh( stream:TStream,url:Object,parent:TEntity=Null,flags:Int=-1 )
	
		' see: assimp.sourceforge.net/lib_html/postprocess_8h.html
		Local readflags:Int = aiProcess_FlipUVs | aiProcess_Triangulate | aiProcess_GenUVCoords | aiProcess_SortByPType | aiProcess_MakeLeftHanded | aiProcess_FindInvalidData | aiProcess_FindDegenerates | aiProcess_SplitByBoneCount | aiProcess_LimitBoneWeights | aiProcess_SplitLargeMeshes | aiProcess_FlipWindingOrder | aiProcess_CalcTangentSpace | aiProcess_TransformUVCoords | aiProcess_PreTransformVertices | aiProcess_RemoveRedundantMaterials
		'aiProcess_JoinIdenticalVertices | ..
		'aiProcess_OptimizeMeshes | ..
		
		Select flags ' crash if both flags used together
			Case -1
				readflags = readflags | aiProcess_GenSmoothNormals ' -1 smooth shaded
			Case -2
				readflags = readflags | aiProcess_GenNormals ' -2 flat shaded
		EndSelect
		
		Local props:Byte Ptr = aiCreatePropertyStore()
		
		aiSetImportPropertyInteger(props, AI_CONFIG_PP_SBP_REMOVE, aiPrimitiveType_POINT | aiPrimitiveType_LINE) ' SortByPType
		aiSetImportPropertyInteger(props, AI_CONFIG_PP_FD_REMOVE, True) ' FindDegenerates
		aiSetImportPropertyInteger(props, AI_CONFIG_PP_SBBC_MAX_BONES, 60) ' SplitbyBoneCount
		aiSetImportPropertyInteger(props, AI_CONFIG_PP_LBW_MAX_WEIGHTS, 4) ' LimitBoneWeights
		aiSetImportPropertyInteger(props, AI_CONFIG_PP_SLM_VERTEX_LIMIT, 1000000) ' SplitLargeMeshes
		aiSetImportPropertyInteger(props, AI_CONFIG_PP_SLM_TRIANGLE_LIMIT, 1000000) ' SplitLargeMeshes
		
		Local scene:TaiSceneEx = New TaiSceneEx
		Local pScene:Byte Ptr
		
		If stream = Null
			pScene = scene.LoadScene(url, readflags, props)
		Else
			pScene = scene.LoadSceneFromStream(stream, url, readflags, props)
		EndIf
		
		aiReleasePropertyStore(props)
		
		If (flags < 0) And (Abs(flags) & 4) Then readflags = readflags | $8000000 ' -4 load scene as single mesh
		
		Local root:TMesh
		
		If pScene <> Null
			root = LoadAnimMeshFromScene(scene, url, parent, readflags)
			
			scene.ReleaseImport() ' only when pointer valid
		Else
			If TGlobal3D.Log_Assimp Then DebugLog " Nothing imported: "+String(url)
			If TGlobal3D.Log_Assimp Then DebugLog " Error: "+String.FromCString( aiGetErrorString() )
		EndIf
		
		Return root
		
	End Function
	
	' internal function
	Function LoadAnimMeshFromScene:TMesh( scene:TaiSceneEx,url:Object,parent:TEntity,flags:Int )
	
		' Make brushes
		
		Local id:Int, index:Int, brushes:TBrush[scene.mNumMaterials]
		
		For Local mat:TaiMaterialEx = EachIn scene.mMaterials
		
			Rem
			If TGlobal3D.Log_Assimp Then DebugLog " mat Name: "+mat.GetMaterialName() ' ?mat.name
			If TGlobal3D.Log_Assimp Then DebugLog " mat IsTwoSided: "+mat.IsTwoSided() ' $mat.twosided
			If TGlobal3D.Log_Assimp Then DebugLog " mat GetShininess: "+mat.GetShininess() ' $mat.shininess
			If TGlobal3D.Log_Assimp Then DebugLog " mat GetAlpha: "+mat.GetAlpha() ' $mat.opacity
			EndRem
			
			Local names:String[] = mat.GetPropertyNames()
			
			For Local s:String = EachIn names
				Local ps:String = " Property: "+s+" = "
				
				Select s
					Case AI_MATKEY_NAME ' $mat.name
						If TGlobal3D.Log_Assimp Then DebugLog ps+mat.GetMaterialString(s)
						
					Case AI_MATKEY_SHADING_MODEL, AI_MATKEY_TWOSIDED
						Local ivalue:Int[] = mat.GetMaterialIntegerArray(s)
						If TGlobal3D.Log_Assimp And ivalue.length Then DebugLog ps+ivalue[0]
						
					Case AI_MATKEY_OPACITY, AI_MATKEY_SHININESS, AI_MATKEY_REFRACTI
						Local fvalue:Float[] = mat.GetMaterialFloatArray(s)
						If TGlobal3D.Log_Assimp And fvalue.length Then DebugLog ps+fvalue[0]
						
					Case AI_MATKEY_COLOR_AMBIENT, AI_MATKEY_COLOR_DIFFUSE, AI_MATKEY_COLOR_SPECULAR, AI_MATKEY_COLOR_EMISSIVE
						Local fvalue:Float[] = mat.GetMaterialFloatArray(s)
						If TGlobal3D.Log_Assimp And fvalue.length > 2 Then DebugLog ps+fvalue[0]+", "+fvalue[1]+", "+fvalue[2]
						
					Case AI_MATKEY_TEXTURE_BASE ' $tex.file
						If TGlobal3D.Log_Assimp Then DebugLog ps+mat.GetMaterialTexture(aiTextureType_DIFFUSE)
						
				End Select
			Next
			
			Local DiffuseColors:Float[] = mat.GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)	
			
			brushes[id] = CreateBrush(mat.GetDiffuseRed() * 255, mat.GetDiffuseGreen() * 255, mat.GetDiffuseBlue() * 255)
			
			' seems alpha comes in different places depending on model format, seems wavefront OBJ alpha doesn't load
			'BrushAlpha brushes[id],mat.GetAlpha()' * mat.GetDiffuseAlpha() (might be 0 so not good)
			
			BrushShininess(brushes[id], mat.GetShininess())
			
			Local tex_flags:Int = 1+8
			
			If mat.IsTwoSided()
				BrushFX(brushes[id], brushes[id].fx[0] | 32) ' transparency for brush alpha tex
				tex_flags = tex_flags + 2048
			EndIf
			
			Local texFilename:String = mat.GetMaterialTexture(aiTextureType_DIFFUSE)
			
			If TGlobal3D.Log_Assimp Then DebugLog " TEXTURE filename: "+texFilename
			
			If Len(texFilename) > 0
			
				' remove currentdir prefix, but leave relative subfolder path intact
				If  texFilename[..2] = ".\" Or texFilename[..2] = "./"
					texFilename = texFilename[2..]
				EndIf
				
				'assume the texture names are stored relative to the file
				texFilename  = ExtractDir(String(url)) + "/" + texFilename
				
				If Not FileType(texFilename)
					texFilename = ExtractDir(String(url)) + "/" + StripDir(texFilename)
				EndIf
				
				If TGlobal3D.Log_Assimp Then DebugLog " new filename: "+texFilename
				
				Local tex:TTexture = LoadTexture(texFilename, tex_flags)
				
				If tex
					If (tex_flags & 2048) Then TextureBlend(tex, 2)
					BrushTexture(brushes[id], tex, 0, 0) ' no texture layers support in Assimp
				EndIf
				
			EndIf
			
			id:+1
		Next
		
		If TGlobal3D.Log_Assimp Then DebugLog " scene.mNumMeshes: "+scene.mNumMeshes
		
		' Make mesh - was ProccessAiNodeAndChildren()
		
		Local mesh:TMesh, root:TMesh, child_id:Int=0
		
		If (scene.mRootNode.mNumMeshes = 0 And scene.mRootNode.mNumChildren > 0) Or (flags & $8000000) ' dummy root node
			mesh = NewMesh()
			mesh.SetString(mesh.class_name, "Mesh")
			mesh.EntityListAdd(TEntity.entity_list)
			
			mesh.AddParent(parent)
			mesh.SetString(mesh.name, scene.mRootNode.mName.GetCString())
			root = mesh
			
			If TGlobal3D.Log_Assimp Then DebugLog " Mesh name: "+scene.mRootNode.mName.GetCString()
		EndIf
		
		For Local am:TaiMeshEx = EachIn scene.mMeshes
		
			If Not (flags & $8000000) ' not as single mesh, multiple if exists
				mesh = NewMesh()
				mesh.SetString(mesh.class_name, "Mesh")
				mesh.EntityListAdd(TEntity.entity_list)
				
				If scene.mRootNode.mNumChildren = 0 ' root node has no children
					mesh.AddParent(parent)
					mesh.SetString(mesh.name, scene.mRootNode.mName.GetCString())
					root = mesh
					
					If TGlobal3D.Log_Assimp Then DebugLog " Mesh name: "+scene.mRootNode.mName.GetCString()
				ElseIf child_id < scene.mRootNode.mChildren.length ' root node has children
					mesh.AddParent(root)
					mesh.SetString(mesh.name, scene.mRootNode.mChildren[child_id].mName.GetCString())
					
					If TGlobal3D.Log_Assimp Then DebugLog " Mesh child name: "+scene.mRootNode.mChildren[child_id].mName.GetCString()
					child_id:+1
				EndIf
			EndIf
			
			Local surf:TSurface = CreateSurface(mesh, brushes[am.mMaterialIndex])
			
			' vertices, normals and texturecoords - was MakeAiMesh()
			For id = 0 To am.mNumVertices - 1
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
				
				If am.HasVertexColors(0)
					VertexColor(surf, index, am.VertexRed(id), am.VertexGreen(id), am.VertexBlue(id), am.VertexAlpha(id))
				EndIf
				
				'If am.HasTangentsAndBitangents()
				'	VertexTangent(surf, index, am.VertexTX(id), am.VertexTY(id), am.VertexTZ(id))
				'	VertexBitangent(surf, index, am.VertexBX(id), am.VertexBY(id), am.VertexBZ(id))
				'EndIf
			Next
			
			If TGlobal3D.Log_Assimp
				DebugLog " Vertex(0): "+am.VertexX(0)+", "+am.VertexY(0)+", "+am.VertexZ(0)
				If am.HasNormals() Then DebugLog " VertexNormal(0): "+am.VertexNX(0)+", "+am.VertexNY(0)+", "+am.VertexNZ(0)
				If am.HasTextureCoords(0) Then DebugLog " VertexTexCoords(0,0): "+am.VertexU(0)+", "+am.VertexV(0)+", "+am.VertexW(0)
				If am.HasTextureCoords(1) Then DebugLog " VertexTexCoords(0,1): "+am.VertexU(0,1)+", "+am.VertexV(0,1)+", "+am.VertexW(0,1)
				If am.HasVertexColors(0) Then DebugLog " VertexColor(0): "+am.VertexRed(0)+", "+am.VertexGreen(0)+", "+am.VertexBlue(0)+", "+am.VertexAlpha(0)
				'If am.HasTangentsAndBitangents() Then DebugLog " VertexTangent(0): "+am.VertexTX(0)+", "+am.VertexTY(0)+", "+am.VertexTZ(0)
				'If am.HasTangentsAndBitangents() Then DebugLog " VertexBitangent(0): "+am.VertexBX(0)+", "+am.VertexBY(0)+", "+am.VertexBZ(0)
			EndIf
			
			For id = 0 To am.mNumFaces - 1
				' Assimp returns out of range indexes on rare occasions with PreTransformVertices
				Local invalidIndex:Int = False
				Local t0:Int = am.TriangleVertex(id, 0)
				Local t1:Int = am.TriangleVertex(id, 1)
				Local t2:Int = am.TriangleVertex(id, 2)
				
				' fixes MAV when index values < zero
				If t0 < 0 Or t0 >= am.mNumVertices Then invalidIndex = True
				If t1 < 0 Or t1 >= am.mNumVertices Then invalidIndex = True
				If t2 < 0 Or t2 >= am.mNumVertices Then invalidIndex = True
				
				If invalidIndex
					If TGlobal3D.Log_Assimp Then DebugLog " TriangleVertex index out of range for triangle: "+id
					If TGlobal3D.Log_Assimp Then DebugLog " t0="+t0+", t1="+t1+", t2="+t2
				Else
					AddTriangle(surf, t0, t1, t2)
				EndIf
			Next
			
		Next
		
		Return root
		
	End Function
	
End Type
