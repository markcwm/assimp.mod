' showsingle.bmx

Strict

Framework Openb3dmax.B3dglgraphics
Import Scheutz.Assimp

Incbin "../media/zombie.b3d"
Incbin "../media/Zombie.jpg"

Local width%=DesktopWidth(),height%=DesktopHeight(),depth%=0,Mode%=2

Graphics3D width,height,depth,Mode

Local cam:TCamera=CreateCamera()
PositionEntity cam,0,10,-15
CameraClsColor cam,50,100,150

Local light:TLight=CreateLight()

Local sphere:TMesh=CreateSphere()
HideEntity sphere

Local mesh:TMesh

' Note: you can load password protected zips but these are easily opened with 7zip as the filenames are not encrypted, 
' a zip inside a password zip is encrypted but zipstream can't open these, so use custom pak file to protect assets.
'SetZipStreamPassword zipfile,"blitzmax"

TGlobal3D.Log_Assimp=1 ' debug data
MeshLoader "assimp",-1 ' use assimp from file, -1 smooth normals, -2 flat shaded, -4 single mesh
'MeshLoader "assimpstream",-1 ' use assimp streams

Local test%=1
Select test
	Case 1 ' load assimp mesh
		Local time:Int=MilliSecs()
		'mesh=LoadAnimMesh("../media/zombie.b3d")
		'mesh=LoadAnimMesh("../media/rallycar1.3ds")
		mesh=LoadAnimMesh("../assimplib.mod/assimp/test/models/OBJ/spider.obj") ' note: OBJ materials don't load from stream
		'mesh=LoadAnimMesh("../../../openb3dmax.docs/media/tris.md2")
		'mesh=LoadAnimMesh("../../../openb3dmax.docs/media/bath/RomanBath.b3d")
		
		DebugLog "assimp time="+Abs(MilliSecs()-time)
		
	Case 2 ' load incbin mesh
		Local time:Int=MilliSecs()
		mesh=LoadAnimMesh("incbin::../media/zombie.b3d")
		
		DebugLog "incbin time="+Abs(MilliSecs()-time)
		
	Case 3 ' load zip mesh
		Local time:Int=MilliSecs()
		Local zipfile:String="../media/zombie.zip"
		mesh=LoadAnimMesh("zip::"+zipfile+"//zombie.b3d")
		
		DebugLog "zip time="+Abs(MilliSecs()-time)
		
	Default ' load library mesh
		MeshLoader "cpp"
		TextureLoader "cpp"
		
		Local time:Int=MilliSecs()
		mesh=LoadAnimMesh("../media/zombie.b3d")
		
		DebugLog "lib time="+Abs(MilliSecs()-time)
		
End Select

' child entity variables
Local child_ent:TEntity ' this will store child entity of anim mesh
Local child_no%=1 ' used to select child entity
Local count_children%=TEntity.CountAllChildren(mesh) ' total no. of children belonging to entity

' marker entity. will be used to highlight selected child entity (with zombie anim mesh it will be a bone)
Local marker_ent:TMesh=CreateSphere(8)
EntityColor marker_ent,255,255,0
'ScaleEntity marker_ent,.25,.25,.25
EntityOrder marker_ent,-1

' anim time - this will be incremented/decremented each frame and then supplied to SetAnimTime to animate entity
Local anim_time#=0
If mesh Then FitAnimMesh mesh,-10,0,-10,20,20,20,True

' used by fps code
Local old_ms%=MilliSecs()
Local renders%=0, fps%=0


While Not KeyDown(KEY_ESCAPE)		

	If KeyHit(KEY_ENTER) Then DebugStop
	
	If KeyDown(KEY_J) Then TurnEntity mesh,0,3,0
	If KeyDown(KEY_L) Then TurnEntity mesh,0,-3,0
	
	' control camera
	MoveEntity cam,(KeyDown(KEY_D)-KeyDown(KEY_A))/2.0,0,(KeyDown(KEY_W)-KeyDown(KEY_S))/2.0
	TurnEntity cam,KeyDown(KEY_DOWN)-KeyDown(KEY_UP),KeyDown(KEY_LEFT)-KeyDown(KEY_RIGHT),0
	
	' change anim time values
	If KeyDown(KEY_MINUS) Then anim_time#=anim_time#-0.1
	If KeyDown(KEY_EQUALS) Then anim_time#=anim_time#+0.1
	
	' animte entity
	SetAnimTime(mesh,anim_time#)

	' select child entity
	If KeyHit(KEY_OPENBRACKET) Then child_no=child_no-1
	If KeyHit(KEY_CLOSEBRACKET) Then child_no=child_no+1
	If child_no<1 Then child_no=1
	If child_no>count_children Then child_no=count_children
	
	' get child entity
	Local count%=0 ' this is just a count variable needed by GetChildFromAll. must be set to 0.
	child_ent=mesh.GetChildFromAll(child_no,count) ' get child entity

	' position marker entity at child entity position
	If child_ent<>Null
		PositionEntity marker_ent,EntityX(child_ent,True),EntityY(child_ent,True),EntityZ(child_ent,True)
	EndIf

	RenderWorld
	renders=renders+1
	
	' calculate fps
	If MilliSecs()-old_ms>=1000
		old_ms=MilliSecs()
		fps=renders
		renders=0
	EndIf
	
	Text 0,0,"FPS: "+fps
	Text 0,20,"+/- to animate"
	Text 0,40,"[] to select different child entity (bone)"
	Text 0,60,"Arrows/WASD move camera, JL arrows turn entity"
	If child_ent<>Null
		Text 0,80,"Child: "+EntityName(child_ent)
	EndIf
	Text 0,100,"No children: "+count_children
	
	Flip
	
Wend
End
