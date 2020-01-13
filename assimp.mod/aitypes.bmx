' aitypes.bmx

Type aiColor4D
	Field r:Float, g:Float, b:Float, a:Float
End Type

Type aiQuaternion
	Field w:Float, x:Float, y:Float, z:Float
End Type

Type aiVector2D
	Field x:Float, y:Float
End Type

Type aiVector3D
	Field x:Float, y:Float, z:Float
End Type

Type aiMatrix3x3
	Field a1:Float, a2:Float, a3:Float
	Field b1:Float, b2:Float, b3:Float
	Field c1:Float, c2:Float, c3:Float
End Type

Type aiMatrix4x4
	Field a1:Float, a2:Float, a3:Float, a4:Float
	Field b1:Float, b2:Float, b3:Float, b4:Float
	Field c1:Float, c2:Float, c3:Float, c4:Float
	Field d1:Float, d2:Float, d3:Float, d4:Float
End Type

Type aiMatrix4x4Ex Extends aiMatrix4x4

	Field heading:Float
	Field attitude:Float
	Field bank:Float
	
	Field Tx:Float, Ty:Float, Tz:Float
	Field Sx:Float, Sy:Float, Sz:Float
	Field Rx:Float, Ry:Float, Rz:Float
	
	Function Create:aiMatrix4x4( pMat:Float Ptr )
	
		Local m:aiMatrix4x4 = New aiMatrix4x4
		
		m.a1 = pMat[0]
		m.a2 = pMat[1]
		m.a3 = pMat[2]
		m.a4 = pMat[3]
		
		m.b1 = pMat[4]
		m.b2 = pMat[5]
		m.b3 = pMat[6]
		m.b4 = pMat[7]
		
		m.c1 = pMat[8]
		m.c2 = pMat[9]
		m.c3 = pMat[10]
		m.c4 = pMat[11]
		
		m.d1 = pMat[12]
		m.d2 = pMat[13]
		m.d3 = pMat[14]
		m.d4 = pMat[15]
		
		Rem
		If TGlobal3D.Log_Assimp Then DebugLog " a1="+m.a1+" a2="+m.a2+" a3="+m.a3+" a4="+m.a4
		If TGlobal3D.Log_Assimp Then DebugLog " b1="+m.b1+" b2="+m.b2+" b3="+m.b3+" b4="+m.b4
		If TGlobal3D.Log_Assimp Then DebugLog " c1="+m.c1+" c2="+m.c2+" c3="+m.c3+" c4="+m.c4
		If TGlobal3D.Log_Assimp Then DebugLog " d1="+m.d1+" d2="+m.d2+" d3="+m.d3+" d4="+m.d4
		EndRem
		
		Return m
		
	End Function
	
	Method Decompose()
	
		_Decompose()
		
		rx = heading
		ry = attitude
		rz = bank
		
	End Method
	
	Method _Decompose()
	
		Tx = a4 ; Ty = b4 ; Tz = c4
		
		Sx = Sqr(a1*a1 + a2*a2 + a3*a3)
		Sy = Sqr(b1*b1 + b2*b2 + b3*b3) 
		Sz = Sqr(c1*c1 + c2*c2 + c3*c3)
		
		Local D:Float = a1 * (b2*c3 - c2*b3) - b1 * (a2*c3 - c2*a3) + c1 * (a2*b3 - b2*a3)
		
		Sx:* Sgn(D) ; Sy:* Sgn(D) ; Sz:* Sgn(D)
		
		Local rm:aiMatrix3x3 = New aiMatrix3x3
		
		rm.a1 = a1 ; rm.a2 = a2 ; rm.a3 = a3
		rm.b1 = b1 ; rm.b2 = b2 ; rm.b3 = b3
		rm.c1 = c1 ; rm.c2 = c2 ; rm.c3 = c3		
		
		If sx Then
			rm.a1:/ sx ; rm.a2:/ sx ; rm.a3:/ sx	
		EndIf
		If sy Then
			rm.b1:/ sy ; rm.b2:/ sy ; rm.b3:/ sy	
		EndIf
		If sz Then
			rm.c1:/ sz ; rm.c2:/ sz ; rm.c3:/ sz	
		EndIf
		
		If (b1 > 0.998)
			heading = ATan2(rm.a3, rm.c3)
			attitude = 90 'Pi/2
			bank = 0
			If TGlobal3D.Log_Assimp Then DebugLog " aiMatrix4x4 Decompose: singularity at north pole"
			Return
		EndIf
		
		If (b1 < -0.998)
			heading = ATan2(rm.a3, rm.c3)
			attitude = -90 '-Pi/2
			bank = 0
			If TGlobal3D.Log_Assimp Then DebugLog " aiMatrix4x4 Decompose: singularity at south pole"
			Return
		EndIf
		
		heading = ATan2(-rm.c1, rm.a1)
		bank = ATan2(-rm.b3, rm.b2)
		attitude = ASin(rm.b1)	
		
	End Method
	
	Method GetScaleX:Float()
	
		Return Sqr(a1*a1 + a2*a2 + a3*a3)
		
	End Method
	
	Method GetScaleY:Float()
	
		Return Sqr(b1*b1 + b2*b2 + b3*b3)
		
	End Method
	
	Method GetScaleZ:Float()
	
		Return Sqr(c1*c1 + c2*c2 + c3*c3)
		
	End Method
	
End Type

Type aiCamera ' Helper structure to describe a virtual camera
    Field mName:aiString ' The name of the camera, there must be a node in the scenegraph with the same name
    Field mPosition:aiVector3D ' Position of the camera relative to the coordinate space
    Field mUp:aiVector3D ' 'Up' - vector of the camera coordinate system relative to the coordinate space
    Field mLookAt:aiVector3D ' 'LookAt' - vector of the camera coordinate system relative to the coordinate space
    Field mHorizontalFOV:Float ' Half horizontal Field of view angle, in radians
    Field mClipPlaneNear:Float ' Distance of the near clipping plane from the camera
    Field mClipPlaneFar:Float ' Distance of the far clipping plane from the camera
    Field mAspect:Float ' Screen aspect ratio
End Type

Type aiLight ' Helper structure to describe a light source
	Field mName:aiString ' The name of the light source
    Field mType:Int ' The type of the light source
	Field mPosition:aiVector3D ' Position of the light source in space
	Field mDirection:aiVector3D ' Direction of the light source in space
    Field mAttenuationConstant:Float ' Constant light attenuation factor
    Field mAttenuationLinear:Float ' Linear light attenuation factor
    Field mAttenuationQuadratic:Float ' Quadratic light attenuation factor
	Field mColorDiffuse:aiColor3D ' Diffuse color of the light source
	Field mColorSpecular:aiColor3D ' Specular color of the light source
	Field mColorAmbient:aiColor3D ' Ambient color of the light source
    Field mAngleInnerCone:Float ' Inner angle of a spot light's light cone
    Field mAngleOuterCone:Float ' Outer angle of a spot light's light cone
End Type

' metadata.h

Type aiMetadataEntry ' Metadata entry, the type field uniquely identifies the underlying type of the data field
	Field mType:Int
	Field mData:Byte Ptr
End Type

Type aiMetadata ' Metadata is a key-value store using string keys and values
	Field mNumProperties:Int ' Length of the mKeys and mValues arrays, respectively
	Field mKeys:aiString[] ' Arrays of keys, may Not be Null, entries in this array may Not be Null
	Field mValues:aiMetadataEntry[] ' Arrays of values, may Not be Null, array entries may be Null if key has no value
End Type

' texture.h

Type aiTexel ' Helper structure to represent a texel in a ARGB8888 format, used by aiTexture
	Field b:Byte, g:Byte, r:Byte, a:Byte
End Type

Type aiTexture ' Helper structure to describe an embedded texture
	Field mWidth:Int ' Width of the texture, in pixels
	Field mHeight:Int ' Height of the texture, in pixels
	Field achFormatHint:Byte[4] ' A hint from the loader to help determine the type of embedded compressed textures
	Field pcData:aiTexel[] ' Data of the texture, points to an array of mWidth * mHeight aiTexel's
End Type

' types.h

Type aiPlane ' Represents a plane in a three-dimensional, euclidean space
	Field a:Float, b:Float, c:Float, d:Float
End Type

Type aiRay ' Represents a ray
	Field pos:aiVector3D, dir:aiVector3D ' Position and direction of the ray
End Type

Type aiColor3D ' Represents a color in Red-Green-Blue space
    Field r:Float, g:Float, b:Float ' Red, green and blue color values
End Type

Type aiString ' Represents an UTF-8 string, zero byte terminated, used instead of std::string to be C-compatible

	?ptr64
	Field length:Long
	?Not ptr64
	Field length:Int ' Binary length of the string excluding the terminal 0
	?
	Field data:Byte[MAXLEN] 'String buffer, size limit is MAXLEN (note aiString size is 16 bytes so data is a pointer)
	
	Method SetCString( s:String )
	
		If s.length < MAXLEN Then MemCopy(data, s, Size_T(s.length))
		
	End Method
	
	Method GetCString:String()
	
		Return String.FromCString(data)
		
	End Method
	
End Type

Type aiMemoryInfo ' Stores the memory requirements for different components of an import, all sizes are in bytes
	Field textures:Int ' Storage allocated for texture data
	Field materials:Int ' Storage allocated for material data
	Field meshes:Int ' Storage allocated for mesh data
	Field nodes:Int ' Storage allocated for node data
	Field animations:Int ' Storage allocated for animation data
	Field cameras:Int ' Storage allocated for camera data
	Field lights:Int ' Storage allocated for light data
	Field total:Int ' Total storage allocated for the full import
End Type

' material.h

Type aiUVTransform ' Defines how an UV channel is transformed, helper structure For the #AI_MATKEY_UVTRANSFORM key
    Field mTranslation:aiVector2D ' Translation on the u and v axes, default value is (0|0)
    Field mScaling:aiVector2D ' Scaling on the u and v axes, default value is (1|1)
    Field mRotation:Float ' Rotation in counter-clockwise direction, rotation angle is specified in radians
End Type

Type aiMaterialProperty ' Data structure for a single material property, just use the aiMaterial::Get() functions
	Field mKey:aiString ' Specifies the name of the property (key)
	Field mSemantic:Int ' Textures: Specifies their exact usage semantic
	Field mIndex:Int ' Textures: Specifies the index of the texture
	Field mDataLength:Int ' Size of the buffer mData is pointing to, in bytes, including string length and terminal 0
	Field mType:Int ' Type information for the property
	Field mData:Byte Ptr ' Binary buffer to hold the property's value
End Type

Type aiMaterialPropertyEx Extends aiMaterialProperty

	Function GetBytePtrAddress:Byte Ptr( p:Byte Ptr )
	
		?ptr64
		Return Byte Ptr( Long Ptr( p )[0] )
		?Not ptr64
		Return Byte Ptr( Int Ptr( p )[0] )
		?
		
	End Function
	
	Function Create:aiMaterialPropertyEx( pProps:Byte Ptr )
	
		Local mp:aiMaterialPropertyEx = New aiMaterialPropertyEx
		mp.mKey = New aiString
		
		Local pOffset:Byte Ptr = pProps + SizeOf(mp.mKey.length) ' 4/8
		mp.mKey.SetCString(String.FromCString(pOffset))
		
		pOffset :+ SizeOf(mp.mKey.data) ' 1024
		mp.mSemantic = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(mp.mSemantic) ' 4
		mp.mIndex = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(mp.mIndex) ' 4
		mp.mDataLength = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(mp.mDataLength) ' 4
		mp.mType = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(mp.mType) ' 4
		mp.mData = GetBytePtrAddress(pOffset)
		
		Rem
		If TGlobal3D.Log_Assimp Then DebugLog " mp.mKey="+mp.mKey.GetCString()
		If TGlobal3D.Log_Assimp Then DebugLog " mp.mSemantic="+mp.mSemantic
		If TGlobal3D.Log_Assimp Then DebugLog " mp.mIndex="+mp.mIndex
		If TGlobal3D.Log_Assimp Then DebugLog " mp.mDataLength="+mp.mDataLength
		If TGlobal3D.Log_Assimp Then DebugLog " mp.mType="+mp.mType
		If TGlobal3D.Log_Assimp Then DebugLog " mp.mData="+mp.mData
		EndRem
		
		Return mp
		
	End Function
	
	Method GetFloatValue:Float( index:Int )
	
		Return Float Ptr( mData )[index]
		
	End Method
	
	Method GetStringValue:String()
	
		Return String.FromCString(mData + SizeOf(mDataLength)) ' 4 - data string length is always int
		
	End Method
	
	Method GetIntValue:Int( index:Int )
	
		Return Int Ptr( mData )[index]
		
	End Method
	
	Method GetByteValue:Byte( index:Int )
	
		Return mData[index]
		
	End Method
	
End Type

Type aiMaterial ' Material data is stored using a key-value structure, a single key-value pair is called a material property
	Field mProperties:aiMaterialPropertyEx[] ' List of all material properties loaded
	Field mNumProperties:Int ' Number of properties in the data base
	Field mNumAllocated:Int ' Storage allocated
End Type

Type aiMaterialEx Extends aiMaterial

	Field pMaterial:Byte Ptr
	?ptr64
	Field pProperties:Long Ptr
	?Not ptr64
	Field pProperties:Int Ptr
	?
	
	' helper functions based on Assimp api 
	
	Method GetMaterialName:String()
	
		Return GetMaterialString(AI_MATKEY_NAME)
		
	End Method	
	
	Method IsTwoSided:Int()
	
		Local values:Int[] = GetMaterialIntegerArray(AI_MATKEY_TWOSIDED)
		If values.length Then Return values[0]
		
	End Method
	
	Method GetAlpha:Float()
	
		Local values:Float[] = GetMaterialFloatArray(AI_MATKEY_OPACITY)
		If values.length
			Return values[0]	
		Else		
			Return 1.0
		EndIf
		
	End Method
	
	Method GetShininess:Float()
	
		Local values:Float[] = GetMaterialFloatArray(AI_MATKEY_SHININESS)
		If values.length
			Return values[0]	
		Else		
			Return 1.0
		EndIf
		
	End Method
	
	' diffuse
	Method GetDiffuseRed:Float()
	
		Local Colors:Float[] = GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)
		If Colors.length Then Return Colors[0]
		
	End Method
	
	Method GetDiffuseGreen:Float()
	
		Local Colors:Float[] = GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)
		If Colors.length Then Return Colors[1]
		
	End Method
	
	Method GetDiffuseBlue:Float()
	
		Local Colors:Float[] = GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)
		If Colors.length Then Return Colors[2]
		
	End Method
	
	Method GetDiffuseAlpha:Float()
	
		Local Colors:Float[] = GetMaterialColor(AI_MATKEY_COLOR_DIFFUSE)
		If Colors.length Then Return Colors[3]
		
	End Method		
	
	' helper functions, assumes material properties were loaded with scene 
	
	Method GetPropertyNames:String[]()
	
		Local names:String[mNumProperties]
		For Local id:Int = 0 To mNumProperties - 1
		
			names[id] = mProperties[id].mKey.GetCString()
			
			Rem
			If TGlobal3D.Log_Assimp Then DebugLog " Property key: "+mProperties[id].mKey.GetCString()
			If TGlobal3D.Log_Assimp Then DebugLog " Property type: "+mProperties[id].mType
			If TGlobal3D.Log_Assimp Then DebugLog " Property index "+mProperties[id].mIndex
			If TGlobal3D.Log_Assimp Then DebugLog " Property length "+mProperties[id].mDataLength
			If TGlobal3D.Log_Assimp Then DebugLog " Property semantic: "+mProperties[id].mSemantic
			
			Select mProperties[id].mType
				Case aiPTI_Float
					For Local index:Int = 0 Until (mProperties[id].mDataLength / 4)
						If TGlobal3D.Log_Assimp Then DebugLog " Property data Float: "+mProperties[id].GetFloatValue(index)
					Next
					
				Case aiPTI_String
					If TGlobal3D.Log_Assimp Then DebugLog " Property data String: "+mProperties[id].GetStringValue()
					
				Case aiPTI_Integer
					For Local index:Int = 0 Until (mProperties[id].mDataLength / 4)
						If TGlobal3D.Log_Assimp Then DebugLog " Property data Int: "+mProperties[id].GetIntValue(index)
					Next
					
				Case aiPTI_Buffer
					For Local index:Int = 0 Until mProperties[id].mDataLength
						If TGlobal3D.Log_Assimp Then DebugLog " Property data Byte: "+mProperties[id].GetByteValue(index)
					Next
					
			End Select
			EndRem
			
		Next
		
		Return names
		
	End Method
	
	' native ai functions
	
	Method GetMaterialString:String( Key:String )
	
		Local as:aiString = New aiString
		Local retVal:Int = aiGetMaterialString(pMaterial, Key, 0, 0, Varptr as.data[0])
		
		If retVal = AI_SUCCESS
			Return String.FromCString(Varptr as.data[SizeOf(as.length)]) ' 4/8
		Else
			If TGlobal3D.Log_Assimp Then DebugLog " GetMaterialString failed with code: "+retVal
		EndIf
		
	End Method
	
	Method GetMaterialColor:Float[]( Key:String )	
	
		Local colors:Float[4]
		
		If aiGetMaterialColor(pMaterial, Key, 0, 0, colors) = AI_SUCCESS
			Return colors
		EndIf
		
	End Method
	
	Method GetMaterialIntegerArray:Int[]( Key:String )
	
		Local size:Int = MAXLEN
		Local values:Int[size]
		
		If aiGetMaterialIntegerArray(pMaterial, Key, 0, 0, values, Varptr size) = AI_SUCCESS
			values = values[..size]
			Return values
		EndIf
		
	End Method	
	
	Method GetMaterialFloatArray:Float[]( Key:String )
	
		Local size:Int = MAXLEN
		Local values:Float[size]
		
		If aiGetMaterialFloatArray(pMaterial, Key, 0, 0, values, Varptr size) = AI_SUCCESS
			values = values[..size]
			Return values
		EndIf
		
	End Method
	
	Method GetMaterialTexture:String( aiTextureType:Int,index:Int=0 )
	
		Local as:aiString = New aiString
		Local retval:Int = aiGetMaterialTexture(pMaterial, aiTextureType, index, Varptr as.data[0])
		
		If retVal = AI_SUCCESS
			Return String.FromCString(Varptr as.data[SizeOf(as.length)]) ' 4/8
		Else
			If TGlobal3D.Log_Assimp Then DebugLog " GetMaterialTexture failed with code: "+retVal
		EndIf
		
	End Method
	
End Type

' anim.h

Type aiVectorKey ' A time-value pair specifying a certain 3D vector for the given time
	Field mTime:Double ' The time of this key
	Field mValue:aiVector3D ' The value of this key
End Type

Type aiQuatKey ' A time-value pair specifying a quaternion rotation for the given time
	Field mTime:Double ' The time of this key
	Field mValue:aiQuaternion ' The value of this key
End Type

Type aiMeshKey ' Binds a anim mesh to a specific point in time
	Field mTime:Double ' The time of this key
	Field mValue:Int ' Index into the aiMesh::mAnimMeshes array of the mesh corresponding to the #aiMeshAnim
End Type

Type aiNodeAnim ' Describes the animation of a single node, the name specifies the bone/node which is affected
	Field mNodeName:aiString ' The name of the node affected by this animation
	Field mNumPositionKeys:Int ' The number of position keys
	Field mPositionKeys:aiVectorKey[] ' The position keys of this animation channel, specified as 3D vector
	Field mNumRotationKeys:Int ' The number of rotation keys
	Field mRotationKeys:aiQuatKey[] ' The rotation keys of this animation channel, given as quaternions
	Field mNumScalingKeys:Int ' The number of scaling keys
	Field mScalingKeys:aiVectorKey[] ' The scaling keys of this animation channel, specified as 3D vector
	Field mPreState:Int ' Defines how the animation behaves before the first key is encountered
	Field mPostState:Int ' Defines how the animation behaves after the last key was processed
End Type

Type aiMeshAnim ' Describes vertex-based animations for a single mesh or a group of meshes
    Field mName:aiString ' Name of the mesh to be animated, an empty string is not allowed
    Field mNumKeys:Int ' Size of the #mKeys array. Must be 1, at least
    Field mKeys:aiMeshKey[] ' Key frames of the animation, may not be Null
End Type

Type aiAnimation ' An animation consists of keyframe data for a number of nodes
	Field mName:aiString ' The name of the animation, should be empty if only a single animation channel
	Field mDuration:Double ' Duration of the animation in ticks
	Field mTicksPerSecond:Double ' Ticks per second, 0 if not specified in the imported file
	Field mNumChannels:Int ' The number of bone animation channels, each channel affects a single node
	Field mChannels:aiNodeAnim[] ' The node animation channels, each channel affects a single node
    Field mNumMeshChannels:Int ' The number of mesh animation channels, each channel affects a single mesh
    Field mMeshChannels:aiMeshAnim[] ' The mesh animation channels, each channel affects a single mesh
End Type

' mesh.h

Type aiFace ' A single face in a mesh, referring to multiple vertices
	Field mNumIndices:Int ' Number of indices defining this face
	Field mIndices:Int Ptr ' Pointer to the indices array, numIndices in size
End Type

Type aiVertexWeight ' A single influence of a bone on a vertex
	Field mVertexId:Int ' Index of the vertex which is influenced by the bone
	Field mWeight:Float ' The strength of the influence, the influence from all bones at one vertex amounts to 1
End Type

Type aiBone ' A single bone of a mesh, a bone has a name by which it can be found in the frame hierarchy
	Field mName:aiString ' The name of the bone
	Field mNumWeights:Int ' The number of vertices affected by this bone
	Field mWeights:aiVertexWeight[] ' The vertices affected by this bone
	Field mOffsetMatrix:aiMatrix4x4 ' Matrix that transforms from mesh space to bone space in bind pose
End Type

Type aiAnimMesh ' NOT CURRENTLY IN USE. An AnimMesh is an attachment to an #aiMesh, stores per-vertex animations
	Field mVertices:aiVector3D[] ' Replacement for aiMesh::mVertices
	Field mNormals:aiVector3D[] ' Replacement for aiMesh::mNormals
	Field mTangents:aiVector3D[] ' Replacement for aiMesh::mTangents
	Field mBitangents:aiVector3D[] ' Replacement for aiMesh::mBitangents
	Field mColors:aiColor4D[AI_MAX_NUMBER_OF_COLOR_SETS] ' Replacement for aiMesh::mColors
	Field mTextureCoords:aiVector3D[AI_MAX_NUMBER_OF_TEXTURECOORDS] ' Replacement for aiMesh::mTextureCoords
    Field mNumVertices:Int ' The number of vertices in the aiAnimMesh, and thus the length of all the member arrays
End Type

Type aiMesh ' A mesh represents a geometry or model with a single material
	Field mPrimitiveTypes:Int ' Bitwise combination of the members of the #aiPrimitiveType enum
	Field mNumVertices:Int ' The number of vertices in this mesh
	Field mNumFaces:Int ' The number of primitives (triangles, polygons) in this mesh
	Field mVertices:aiVector3D[] ' Vertex positions, always present in a mesh, mNumVertices in size
	Field mNormals:aiVector3D[] ' Vertex normals, normalized vectors, NULL if not present, mNumVertices in size
	Field mTangents:aiVector3D[] ' The tangent of a vertex points in the direction of the positive X texture axis
	Field mBitangents:aiVector3D[] ' The tangent of a vertex points in the direction of the positive Y texture axis
	Field mColors:aiColor4D[AI_MAX_NUMBER_OF_COLOR_SETS][] ' Vertex color sets, NULL if not present
	Field mTextureCoords:aiVector3D[AI_MAX_NUMBER_OF_TEXTURECOORDS][] ' Vertex texture coords, UV channels
	Field mNumUVComponents:Int[AI_MAX_NUMBER_OF_TEXTURECOORDS] ' Specifies the number of components for a given UV channel
	Field mFaces:aiFace[] ' Each face refers to a number of vertices by their indices, mNumFaces in size
	Field mNumBones:Int ' The number of bones this mesh contains, if 0 the mBones array is NULL
	Field mBones:aiBone[] ' A bone consists of a name by which it can be found in the frame hierarchy
	Field mMaterialIndex:Int ' The material used by this mesh, a mesh uses only a single material
	Field mName:aiString ' Name of the mesh, meshes can be named but this is not a requirement
	Field mNumAnimMeshes:Int ' NOT CURRENTLY IN USE. The number of attachment meshes
	Field mAnimMeshes:aiAnimMesh[] ' NOT CURRENTLY IN USE. Attachment meshes for this mesh, for vertex-based animation
End Type

Rem
bbdoc: A mesh represents a geometry or model with a single material.
about: It usually consists of a number of vertices and a series of primitives/faces 
referencing the vertices. In addition there might be a series of bones, each 
of them addressing a number of vertices with a certain weight. Vertex data 
is presented in channels with each channel containing a single per-vertex 
information such as a set of texture coords or a normal vector.
If a data pointer is non-null, the corresponding data stream is present.
From C++ programs you can also use the comfort functions Has*() to
test for the presence of various data streams.
<br><br>
A mesh uses only a single material which is referenced by a material ID.
@note The mPositions member is usually not optional. However, vertex positions 
*could* be missing if the AI_SCENE_FLAGS_INCOMPLETE flag is set in aiScene::mFlags.
*/
EndRem
Type aiMeshEx Extends aiMesh

	Field pVertices:Float Ptr
	Field pNormals:Float Ptr
	Field pTangents:Float Ptr
	Field pBitangents:Float Ptr
	Field pColors:Byte Ptr[AI_MAX_NUMBER_OF_COLOR_SETS]
	Field pTextureCoords:Byte Ptr[AI_MAX_NUMBER_OF_TEXTURECOORDS]
	?ptr64
	Field pBones:Long Ptr
	Field pFaces:Long Ptr
	?Not ptr64
	Field pBones:Int Ptr
	Field pFaces:Int Ptr
	?
	
	Method VertexX:Float( index:Int )
	
		Return mVertices[index].x
		
	End Method
	
	Method VertexY:Float( index:Int )
	
		Return mVertices[index].y
		
	End Method
	
	Method VertexZ:Float( index:Int )
	
		Return mVertices[index].z
		
	End Method
	
	Method VertexNX:Float( index:Int )
	
		Return mNormals[index].x
		
	End Method
	
	Method VertexNY:Float( index:Int )
	
		Return mNormals[index].y
		
	End Method
	
	Method VertexNZ:Float( index:Int )
	
		Return mNormals[index].z
		
	End Method
	
	Method VertexU:Float( index:Int,coord_set:Int=0 )
	
		Return mTextureCoords[coord_set][index].x
		
	End Method
	
	Method VertexV:Float( index:Int,coord_set:Int=0 )
	
		Return mTextureCoords[coord_set][index].y
		
	End Method
	
	Method VertexW:Float( index:Int,coord_set:Int=0 )
	
		Return mTextureCoords[coord_set][index].z
		
	End Method
	
	Method VertexRed:Float( index:Int,color_set:Int=0 )
	
		Return mColors[color_set][index].r * 255.0
		
	End Method
	
	Method VertexGreen:Float( index:Int,color_set:Int=0 )
	
		Return mColors[color_set][index].g * 255.0
		
	End Method
	
	Method VertexBlue:Float( index:Int,color_set:Int=0 )
	
		Return mColors[color_set][index].b * 255.0
		
	End Method
	
	Method VertexAlpha:Float( index:Int,color_set:Int=0 )
	
		Return mColors[color_set][index].a ' alpha in range 0..1
		
	End Method
	
	Method VertexTX:Float( index:Int )
	
		Return mTangents[index].x
		
	End Method
	
	Method VertexTY:Float( index:Int )
	
		Return mTangents[index].y
		
	End Method
	
	Method VertexTZ:Float( index:Int )
	
		Return mTangents[index].z
		
	End Method
	
	Method VertexBX:Float( index:Int )
	
		Return mBitangents[index].x
		
	End Method
	
	Method VertexBY:Float( index:Int )
	
		Return mBitangents[index].y
		
	End Method
	
	Method VertexBZ:Float( index:Int )
	
		Return mBitangents[index].z
		
	End Method
	
	Method HasPositions:Int() ' Check whether the mesh contains positions
	
		If pVertices <> Null And mNumVertices > 0 Then Return True
		
	End Method
	
	Method HasFaces:Int() ' Check whether the mesh contains faces
	
		If pFaces <> Null And mNumFaces > 0 Then Return True
		
	End Method
	
	Method HasNormals:Int() ' Check whether the mesh contains normal vectors
	
		If pNormals <> Null And mNumVertices > 0 Then Return True
		
	End Method	
	
	Method HasTangentsAndBitangents:Int() ' Check whether the mesh contains tangent and bitangent vectors
	
		If pTangents <> Null And pBitangents <> Null And mNumVertices > 0 Then Return False
		
	End Method
	
	Method HasTextureCoords:Int( coord_set:Int ) ' Check whether the mesh contains a texture coordinate set
	
		If coord_set >= AI_MAX_NUMBER_OF_TEXTURECOORDS Then Return False
		If pTextureCoords[coord_set] <> Null And mNumVertices > 0 Then Return True
		
	End Method
	
	Method HasVertexColors:Int( color_set:Int ) ' Check whether the mesh contains a vertex color set
	
		If color_set >= AI_MAX_NUMBER_OF_COLOR_SETS Then Return False
		If pColors[color_set] <> Null And mNumVertices > 0 Then Return True
		
	End Method
	
	Method HasBones:Int() ' Check whether the mesh contains bones
	
		If pBones <> Null And mNumBones > 0 Then Return True
		
	End Method	
	
	Method TriangleVertex:Int( index:Int,corner:Int )
	
		Return mFaces[index].mIndices[corner]
		
	End Method
	
	Method GetTriangularFaces:Int[,]()
	
		Local faces:Int[mNumFaces, 3]
		
		For Local count:Int = 0 To mNumFaces - 1
		
			For Local n:Int = 0 To 2 ' only supporting triangle faces
				faces[count, n] = mFaces[count].mIndices[n]
			Next
			
		Next
		
		Return faces
		
	End Method
	
End Type

' scene.h

Type aiNode ' Each node has a name, a parent node a transformation relative to its parent and possibly several child nodes
	Field mName:aiString ' The name of the node
	Field mTransformation:aiMatrix4x4 ' The transformation relative to the node's parent
	Field mParent:aiNodeEx ' Parent node, Null if this node is the root node
	Field mNumChildren:Int ' The number of child nodes of this node
	Field mChildren:aiNodeEx[] ' The child nodes of this node, Null if mNumChildren is 0
	Field mNumMeshes:Int ' The number of meshes of this node
	Field mMeshes:Int[] ' The meshes of this node, each entry is an index into the mesh
	Field mMetaData:aiMetadata ' Metadata associated with this node or Null if there is no metadata
End Type

Type aiNodeEx Extends aiNode

	Field pParent:Byte Ptr
	?ptr64
	Field pChildren:Long Ptr
	?Not ptr64
	Field pChildren:Int Ptr
	?
	
	Function Pad64Bit:Int( size:Int )
	
		?ptr64
		Return size
		?Not ptr64
		Return 0
		?
		
	End Function
	
	Function GetBytePtrAddress:Byte Ptr( p:Byte Ptr )
	
		?ptr64
		Return Byte Ptr( Long Ptr( p )[0] )
		?Not ptr64
		Return Byte Ptr( Int Ptr( p )[0] )
		?
		
	End Function
	
	?ptr64
	Function GetLongPtrAddress:Long Ptr( p:Byte Ptr )
	
		Return Long Ptr( Long Ptr( p )[0] )
		
	End Function
	?Not ptr64
	Function GetLongPtrAddress:Int Ptr( p:Byte Ptr )
	
		Return Int Ptr( Int Ptr( p )[0] )
		
	End Function
	?
	
	Function Create:aiNodeEx( pNode:Byte Ptr,parent:aiNodeEx=Null )
	
		Local node:aiNodeEx = New aiNodeEx
		node.mName = New aiString
		node.mParent = parent
		
		Local pOffset:Byte Ptr = pNode + SizeOf(node.mName.length) ' 4/8
		node.mName.SetCString( String.FromCString(pOffset) )
		
		pOffset :+ SizeOf(node.mName.data) ' 1024
		node.mTransformation = aiMatrix4x4Ex.Create(pOffset)
		
		pOffset :+ SizeOf(node.mTransformation) ' 64
		pOffset :+ SizeOf(node.pParent) ' 4/8
		node.mNumChildren = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(node.mNumChildren) + Pad64Bit(4) ' 4 + 0/4
		
		If node.mNumChildren > 0 ' get child nodes
			node.pChildren = GetLongPtrAddress(pOffset)
			node.mChildren = node.mChildren[..node.mNumChildren]
			
			For Local id:Int = 0 To node.mNumChildren - 1
				node.mChildren[id] = aiNodeEx.Create(Byte Ptr( node.pChildren[id] ), node)
			Next
		EndIf
		
		pOffset :+ SizeOf(node.pChildren) ' 4/8
		node.mNumMeshes = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(node.mNumMeshes) + Pad64Bit(4) ' 4 + 0/4
		Local pMeshes:Int Ptr = Int Ptr( GetBytePtrAddress(pOffset) )
		node.mMeshes = node.mMeshes[..node.mNumMeshes]
		
		For Local id:Int = 0 To node.mNumMeshes - 1
			node.mMeshes[id] = pMeshes[id]
		Next
		
		If TGlobal3D.Log_Assimp Then DebugLog " node.mName: "+node.mName.GetCString()
		If TGlobal3D.Log_Assimp And parent <> Null Then DebugLog "node.mParent.mName: "+node.mParent.mName.GetCString()
		If TGlobal3D.Log_Assimp Then DebugLog " node.mNumChildren: "+node.mNumChildren
		If TGlobal3D.Log_Assimp Then DebugLog " node.mNumMeshes: "+node.mNumMeshes
		
		Return node
		
	End Function
	
End Type

Type aiScene ' The root structure of the imported data, everything that was imported from the file can be accessed from here
	Field mFlags:Int ' Any combination of the AI_SCENE_FLAGS_XXX flags, by default this value is 0
	Field mRootNode:aiNodeEx ' The root node of the hierarchy
	Field mNumMeshes:Int ' The number of meshes in the scene
	Field mMeshes:aiMeshEx[] ' The array of meshes
	Field mNumMaterials:Int ' The number of materials in the scene
	Field mMaterials:aiMaterialEx[] ' The array of materials
	Field mNumAnimations:Int ' The number of animations in the scene
	Field mAnimations:aiAnimation[] ' The array of animations
	Field mNumTextures:Int ' The number of textures embedded into the file
	Field mTextures:aiTexture[] ' The array of embedded textures
	Field mNumLights:Int ' The number of light sources in the scene
	Field mLights:aiLight[] ' The array of light sources
	Field mNumCameras:Int ' The number of cameras in the scene
	Field mCameras:aiCamera[] ' The array of cameras
End Type

Type aiSceneEx Extends aiScene

	Field pRootNode:Byte Ptr
	?ptr64
	Field pScene:Long Ptr
	Field pMeshes:Long Ptr
	Field pTextures:Long Ptr
	Field pMaterials:Long Ptr
	Field pAnimations:Long Ptr
	?Not ptr64
	Field pScene:Int Ptr
	Field pMeshes:Int Ptr
	Field pTextures:Int Ptr
	Field pMaterials:Int Ptr
	Field pAnimations:Int Ptr
	?
	
	Function Pad64Bit:Int( size:Int )
	
		?ptr64
		Return size
		?Not ptr64
		Return 0
		?
		
	End Function
	
	Function GetBytePtrAddress:Byte Ptr( p:Byte Ptr )
	
		?ptr64
		Return Byte Ptr( Long Ptr( p )[0] )
		?Not ptr64
		Return Byte Ptr( Int Ptr( p )[0] )
		?
		
	End Function
	
	?ptr64
	Function GetLongPtrAddress:Long Ptr( p:Byte Ptr )
	
		Return Long Ptr( Long Ptr( p )[0] )
		
	End Function
	?Not ptr64
	Function GetLongPtrAddress:Int Ptr( p:Byte Ptr )
	
		Return Int Ptr( Int Ptr( p )[0] )
		
	End Function
	?
	
	Method LoadSceneFromStream:Byte Ptr( stream:TStream,url:Object,readflags:Int,props:Byte Ptr )
	
		Local filename:String = String(url)
		Local ext:String = filename[filename.FindLast(".")+1..]
		?ptr64
		Local bufLen:Long = StreamSize(stream)
		?Not ptr64
		Local bufLen:Int = StreamSize(stream)
		?
		Local buffer:Byte Ptr = MemAlloc(Size_T(bufLen))
		Local ram:TRamStream = CreateRamStream(buffer, Size_T(bufLen), True, True)
		CopyStream(stream, ram)
		
		pScene = aiImportFileFromMemoryWithProperties(buffer, Int(bufLen), readflags, ext, props)
		
		CloseStream(ram)
		MemFree(buffer)
		
		If pScene <> Null Then LoadSceneFromMemory( Self )
		Return pScene
		
	End Method
	
	Method LoadScene:Byte Ptr( url:Object,readflags:Int,props:Byte Ptr )
	
		Local filename:String = String(url)
		Local ext:String = filename[filename.FindLast(".")+1..]
		
		If filename[..5] = "zip::" ' load zip mesh (ram stream by Pertubatio)
		
			Local stream:TStream = CreateBufferedStream(filename)
			?ptr64
			Local bufLen:Long = StreamSize(stream)
			?Not ptr64
			Local bufLen:Int = StreamSize(stream)
			?
			Local buffer:Byte Ptr = MemAlloc(Size_T(bufLen))
			Local ram:TRamStream = CreateRamStream(buffer, Size_T(bufLen), True, True)
			CopyStream(stream, ram)
			
			pScene = aiImportFileFromMemoryWithProperties(buffer, Int(bufLen), readflags, ext, props)
			
			MemFree(buffer)
			CloseStream(stream)
			CloseStream(ram)
			
		ElseIf filename[..8] = "incbin::" ' load incbin mesh by Happy Cat - Jan 2013
		
			Local binName:String = filename[8..]
			Local buffer:Byte Ptr = IncbinPtr(binName)
			Local bufLen:Int = IncbinLen(binName)
			If (buffer = Null Or bufLen = 0) Then Return Null
			
			pScene = aiImportFileFromMemoryWithProperties(buffer, bufLen, readflags, ext, props)
			
		Else
			' TODO this is a fix for wavefront MTL not being found
			' does this mess up UNC paths or something else?
			?win32
			filename = filename.Replace("/", "\")
			?
			pScene = aiImportFileExWithProperties(filename, readflags, Null, props)
			
		EndIf
		
		If pScene <> Null Then LoadSceneFromMemory( Self )
		Return pScene
		
	End Method
	
	Function LoadSceneFromMemory( scene:aiSceneEx )
	
		Local pOffset:Byte Ptr = scene.pScene
		scene.mFlags = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(scene.mFlags) + Pad64Bit(4) ' 4 + 0/4
		scene.mRootNode = aiNodeEx.Create(GetBytePtrAddress(pOffset))
		
		pOffset :+ SizeOf(scene.pRootNode) ' 4/8
		scene.mNumMeshes = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(scene.mNumMeshes) + Pad64Bit(4) ' 4 + 0/4
		scene.pMeshes = GetLongPtrAddress(pOffset)
		scene.mMeshes = scene.mMeshes[..scene.mNumMeshes]
		
		If TGlobal3D.Log_Assimp Then DebugLog " scene.mFlags: "+scene.mFlags
		If TGlobal3D.Log_Assimp Then DebugLog " scene.mNumMeshes: "+scene.mNumMeshes
		If TGlobal3D.Log_Assimp Then DebugLog " scene.pMeshes: "+scene.pMeshes
		
		For Local id:Int = 0 To scene.mNumMeshes - 1
		
			scene.mMeshes[id] = New aiMeshEx
			
			Local pMeshOffset:Byte Ptr = Byte Ptr( scene.pMeshes[id] )
			scene.mMeshes[id].mPrimitiveTypes = Int Ptr( pMeshOffset )[0]
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].mPrimitiveTypes) ' 4
			scene.mMeshes[id].mNumVertices = Int Ptr( pMeshOffset )[0]
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].mNumVertices) ' 4
			scene.mMeshes[id].mNumFaces = Int Ptr( pMeshOffset )[0]
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].mNumFaces) + Pad64Bit(4) ' 4 + 0/4
			scene.mMeshes[id].pVertices = Float Ptr( GetBytePtrAddress(pMeshOffset) )
			scene.mMeshes[id].mVertices = scene.mMeshes[id].mVertices[..scene.mMeshes[id].mNumVertices]
			
			If scene.mMeshes[id].pVertices <> Null
				For Local n:Int = 0 To scene.mMeshes[id].mNumVertices - 1
					scene.mMeshes[id].mVertices[n] = New aiVector3D
					scene.mMeshes[id].mVertices[n].x = scene.mMeshes[id].pVertices[(n * 3)]
					scene.mMeshes[id].mVertices[n].y = scene.mMeshes[id].pVertices[(n * 3) + 1]
					scene.mMeshes[id].mVertices[n].z = scene.mMeshes[id].pVertices[(n * 3) + 2]
				Next
			EndIf
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].pVertices) ' 4/8
			scene.mMeshes[id].pNormals = Float Ptr( GetBytePtrAddress(pMeshOffset) )
			scene.mMeshes[id].mNormals = scene.mMeshes[id].mNormals[..scene.mMeshes[id].mNumVertices]
			
			If scene.mMeshes[id].pNormals <> Null
				For Local n:Int = 0 To scene.mMeshes[id].mNumVertices - 1
					scene.mMeshes[id].mNormals[n] = New aiVector3D
					scene.mMeshes[id].mNormals[n].x = scene.mMeshes[id].pNormals[(n * 3)]
					scene.mMeshes[id].mNormals[n].y = scene.mMeshes[id].pNormals[(n * 3) + 1]
					scene.mMeshes[id].mNormals[n].z = scene.mMeshes[id].pNormals[(n * 3) + 2]
				Next
			EndIf
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].pNormals) ' 4/8
			scene.mMeshes[id].pTangents = Float Ptr( GetBytePtrAddress(pMeshOffset) )
			scene.mMeshes[id].mTangents = scene.mMeshes[id].mTangents[..scene.mMeshes[id].mNumVertices]
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].pTangents) ' 4/8
			scene.mMeshes[id].pBitangents = Float Ptr( GetBytePtrAddress(pMeshOffset) )
			scene.mMeshes[id].mBitangents = scene.mMeshes[id].mBitangents[..scene.mMeshes[id].mNumVertices]
			
			If scene.mMeshes[id].pTangents <> Null And scene.mMeshes[id].pBitangents <> Null
				For Local n:Int = 0 To scene.mMeshes[id].mNumVertices - 1
					scene.mMeshes[id].mTangents[n] = New aiVector3D
					scene.mMeshes[id].mTangents[n].x = scene.mMeshes[id].pTangents[(n * 3)]
					scene.mMeshes[id].mTangents[n].y = scene.mMeshes[id].pTangents[(n * 3) + 1]
					scene.mMeshes[id].mTangents[n].z = scene.mMeshes[id].pTangents[(n * 3) + 2]
				Next
				
				For Local n:Int = 0 To scene.mMeshes[id].mNumVertices - 1
					scene.mMeshes[id].mBitangents[n] = New aiVector3D
					scene.mMeshes[id].mBitangents[n].x = scene.mMeshes[id].pBitangents[(n * 3)]
					scene.mMeshes[id].mBitangents[n].y = scene.mMeshes[id].pBitangents[(n * 3) + 1]
					scene.mMeshes[id].mBitangents[n].z = scene.mMeshes[id].pBitangents[(n * 3) + 2]
				Next
			EndIf
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].pBitangents) ' 4/8
			
			For Local n:Int = 0 To AI_MAX_NUMBER_OF_COLOR_SETS - 1
				scene.mMeshes[id].pColors[n] = GetBytePtrAddress(pMeshOffset)
				scene.mMeshes[id].mColors[n] = scene.mMeshes[id].mColors[n][..scene.mMeshes[id].mNumVertices]
				
				Local pfloat:Float Ptr = Float Ptr( scene.mMeshes[id].pColors[n] )
				If pfloat <> Null And scene.mMeshes[id].pColors[n] <> Null
					For Local v:Int = 0 To scene.mMeshes[id].mNumVertices - 1
						scene.mMeshes[id].mColors[n][v] = New aiColor4D
						scene.mMeshes[id].mColors[n][v].r = pfloat[(v * 4)]
						scene.mMeshes[id].mColors[n][v].g = pfloat[(v * 4) + 1]
						scene.mMeshes[id].mColors[n][v].b = pfloat[(v * 4) + 2]
						scene.mMeshes[id].mColors[n][v].a = pfloat[(v * 4) + 3]
					Next
				EndIf
				
				pMeshOffset :+ SizeOf(scene.mMeshes[id].pColors[0]) ' 4/8
			Next
			
			For Local n:Int = 0 To AI_MAX_NUMBER_OF_TEXTURECOORDS - 1
				scene.mMeshes[id].pTextureCoords[n] = GetBytePtrAddress(pMeshOffset)
				scene.mMeshes[id].mTextureCoords[n] = scene.mMeshes[id].mTextureCoords[n][..scene.mMeshes[id].mNumVertices]
				
				Local pfloat:Float Ptr = Float Ptr( scene.mMeshes[id].pTextureCoords[n] )
				If pfloat <> Null And scene.mMeshes[id].pTextureCoords[n] <> Null
					For Local v:Int = 0 To scene.mMeshes[id].mNumVertices - 1
						scene.mMeshes[id].mTextureCoords[n][v] = New aiVector3D
						scene.mMeshes[id].mTextureCoords[n][v].x = pfloat[(v * 3)]
						scene.mMeshes[id].mTextureCoords[n][v].y = pfloat[(v * 3) + 1]
						scene.mMeshes[id].mTextureCoords[n][v].z = pfloat[(v * 3) + 2]
					Next
				EndIf
				
				pMeshOffset :+ SizeOf(scene.mMeshes[id].pTextureCoords[0]) ' 4/8
			Next
			
			For Local n:Int = 0 To AI_MAX_NUMBER_OF_TEXTURECOORDS - 1
				scene.mMeshes[id].mNumUVComponents[n] = Int Ptr( pMeshOffset )[0]
				pMeshOffset :+ SizeOf(scene.mMeshes[id].mNumUVComponents[0]) ' 4/8
			Next
			
			scene.mMeshes[id].pFaces = GetLongPtrAddress(pMeshOffset)
			scene.mMeshes[id].mFaces = scene.mMeshes[id].mFaces[..scene.mMeshes[id].mNumFaces]
			
			If scene.mMeshes[id].pFaces <> Null
				For Local n:Int = 0 To scene.mMeshes[id].mNumFaces - 1
					scene.mMeshes[id].mFaces[n] = New aiFace
					scene.mMeshes[id].mFaces[n].mNumIndices = scene.mMeshes[id].pFaces[(n * 2)] ' indices should always be 3
					scene.mMeshes[id].mFaces[n].mIndices = Int Ptr( scene.mMeshes[id].pFaces[(n * 2) + 1] )
				Next
			EndIf
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].pFaces) ' 4/8
			scene.mMeshes[id].mNumBones = Int Ptr( pMeshOffset )[0]
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].mNumBones) + Pad64Bit(4) ' 4 + 0/4
			scene.mMeshes[id].pBones = GetLongPtrAddress(pMeshOffset)
			scene.mMeshes[id].mBones = scene.mMeshes[id].mBones[..scene.mMeshes[id].mNumBones]
			
			'For Local n:Int = 0 To mMeshes[id].mNumBones - 1
			
			'Next
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].pBones) ' 4/8
			scene.mMeshes[id].mMaterialIndex = Int Ptr( pMeshOffset )[0]
			
			pMeshOffset :+ SizeOf(scene.mMeshes[id].mMaterialIndex) + Pad64Bit(4) ' 4 + 0/4
			scene.mMeshes[id].mName = New aiString
			scene.mMeshes[id].mName.SetCString( String.FromCString(pMeshOffset) )
			
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes id: "+id
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].mPrimitiveTypes: "+scene.mMeshes[id].mPrimitiveTypes 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].mNumVertices: "+scene.mMeshes[id].mNumVertices 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].mNumFaces: "+scene.mMeshes[id].mNumFaces 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pVertices: "+scene.mMeshes[id].pVertices 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pNormals: "+scene.mMeshes[id].pNormals 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pTangents: "+scene.mMeshes[id].pTangents 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pBitangents: "+scene.mMeshes[id].pBitangents 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pColors[0]: "+scene.mMeshes[id].pColors[0]
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pTextureCoords[0]: "+scene.mMeshes[id].pTextureCoords[0]
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pTextureCoords[1]: "+scene.mMeshes[id].pTextureCoords[1]
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].mNumUVComponents[0]: "+scene.mMeshes[id].mNumUVComponents[0]
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pFaces: "+scene.mMeshes[id].pFaces
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].mNumBones: "+scene.mMeshes[id].mNumBones 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].pBones: "+scene.mMeshes[id].pBones 
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].mMaterialIndex: "+scene.mMeshes[id].mMaterialIndex
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMeshes[].mName: "+scene.mMeshes[id].mName.GetCString()
			
		Next
		
		pOffset :+ SizeOf(scene.pMeshes) ' 4/8
		scene.mNumMaterials = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(scene.mNumMaterials) + Pad64Bit(4) ' 4 + 0/4
		scene.pMaterials = GetLongPtrAddress(pOffset)
		scene.mMaterials = scene.mMaterials[..scene.mNumMaterials]
		
		If TGlobal3D.Log_Assimp Then DebugLog " scene.mNumMaterials: "+scene.mNumMaterials
		If TGlobal3D.Log_Assimp Then DebugLog " scene.pMaterials: "+scene.pMaterials
		
		For Local id:Int = 0 To scene.mNumMaterials - 1
			scene.mMaterials[id] = New aiMaterialEx
			
			Local pMaterialOffset:Byte Ptr = Byte Ptr( scene.pMaterials[id] )
			scene.mMaterials[id].pMaterial = pMaterialOffset
			scene.mMaterials[id].pProperties = GetLongPtrAddress(pMaterialOffset)
			
			pMaterialOffset :+ SizeOf(scene.mMaterials[id].pProperties) ' 4/8
			scene.mMaterials[id].mNumProperties = Int Ptr( pMaterialOffset )[0]
			
			pMaterialOffset :+ SizeOf(scene.mMaterials[id].mNumProperties) ' 4
			scene.mMaterials[id].mNumAllocated = Int Ptr( pMaterialOffset )[0]
			
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMaterials[] id: "+id
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMaterials[].mNumProperties: "+scene.mMaterials[id].mNumProperties
			If TGlobal3D.Log_Assimp Then DebugLog " scene.mMaterials[].mNumAllocated: "+scene.mMaterials[id].mNumAllocated
			
			pMaterialOffset = scene.mMaterials[id].pProperties
			scene.mMaterials[id].mProperties = scene.mMaterials[id].mProperties[..scene.mMaterials[id].mNumProperties]
			
			' loading properties is not needed, but I do it for now to make a list of loaded properties
			For Local pid:Int = 0 To scene.mMaterials[id].mNumProperties - 1
				scene.mMaterials[id].mProperties[pid] = aiMaterialPropertyEx.Create(GetBytePtrAddress(pMaterialOffset))
				pMaterialOffset :+ SizeOf(scene.mMaterials[id].pProperties) ' 4/8
			Next
			
		Next
		
		pOffset :+ SizeOf(scene.pMaterials) ' 4/8
		scene.mNumAnimations = Int Ptr( pOffset )[0]

		pOffset :+ SizeOf(scene.mNumAnimations) + Pad64Bit(4) ' 4 + 0/4
		scene.pAnimations = GetLongPtrAddress(pOffset)
		scene.mAnimations = scene.mAnimations[..scene.mNumAnimations]
		
		If TGlobal3D.Log_Assimp Then DebugLog " scene.mNumAnimations: "+scene.mNumAnimations
		If TGlobal3D.Log_Assimp Then DebugLog " scene.pAnimations: "+scene.pAnimations
		
		pOffset :+ SizeOf(scene.pAnimations) ' 4/8
		scene.mNumTextures = Int Ptr( pOffset )[0]
		
		pOffset :+ SizeOf(scene.mNumTextures) + Pad64Bit(4) ' 4 + 0/4
		scene.pTextures = GetLongPtrAddress(pOffset)
		scene.mTextures = scene.mTextures[..scene.mNumTextures]
		
		If TGlobal3D.Log_Assimp Then DebugLog " scene.mNumTextures: "+scene.mNumTextures
		If TGlobal3D.Log_Assimp Then DebugLog " scene.pTextures: "+scene.pTextures
		
	End Function
	
	Method ReleaseImport()
	
		If pScene <> Null
			aiReleaseImport(pScene)
		EndIf
		
		pScene = Null
		mRootNode = Null
		mMeshes = Null
		mNumMeshes = 0
		mFlags = 0
	
	End Method
	
End Type
