#Include Once "../util/util.bas"
#Include Once "graphicUDT.bas"
#Include Once "buttonUDT.bas"

Type scrollUDT extends graphicUDT
	As Integer status
	As Integer maxStatus
	As Integer itemHeight
	As buttonUDT ptr button
	As Byte buttonIsMoving,isLock
	As Integer buttonDiffY
	Declare Constructor(position As pointUDT Ptr=0,Width_ As Integer,height As Integer,itemHeight As Integer)
	Declare virtual Function todo As Byte
	Declare virtual Sub Paint
	Declare virtual Sub setStatus(status As Integer)
	Declare virtual Function toString As String
End Type

Constructor scrollUDT(position As pointUDT Ptr=0,Width_ As Integer,height As Integer, itemHeight As Integer)
	base(position,width_,height)
	base.isMoveable=0
	this.itemHeight=itemHeight
	Paint
	button = New buttonUDT("",New PointUDT(position->x,position->y),width_,height,0)
	button->isMoveable=0
	button->isResizeable=0
	button->background = this.background
	isResizeable=0
	base.AllowMouseOverEffect=0
End Constructor


Sub scrollUDT.paint
	Line buffer(1),(0,0)-(Width_-1,height-1),RGBa(red/3,green/3,blue/3,255),bf
	Line buffer(1),(0,0)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(1),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(1),(1,1)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	Line buffer(2),(0,0)-(Width_-1,height-1),RGBa(red/3,green/3,blue/3,200),bf
	Line buffer(2),(0,0)-(Width_-1,height-1),RGB(143,76,25),b
	Line buffer(2),(2,2)-(Width_-1-2,height-1-2),RGB(0,0,0),b
	Line buffer(2),(1,1)-(Width_-1-1,height-1-1),RGB(0,0,0),b
	
	'line buffer(1),(Width_*process-1,4)-(width_-4,height-4),rgba(red/3,green/3,blue/3,100),bf
	'line buffer(2),(Width_*process-1,4)-(width_-4,height-4),rgba(red/3,green/3,blue/3,100),bf
	
	If background<>0 Then Put buffer(1),(0,0),background->buffer,alpha
	If background<>0 Then Put buffer(2),(0,0),background->buffer,Alpha
End Sub

Function scrollUDT.todo As Byte
	If enable=0 Then Return 0
	repaint


	
	If ((height/(maxStatus)))<1  Then
		If height * ((height/(maxStatus)))>1 then
			button->resize(Width_, height * ((height/(maxStatus))))
		End if
	Else
		button->resize(Width_, height )
		
	End if
	button->position.x=position.x
	button->position.y=(status*(height-button->height))/((MaxStatus-(height/itemHeight))) + position.y
	button->todo
	If button->background <> this.background Then
		button->background = this.background
	EndIf
	
	Dim As Integer mx,my,mb
	If this.GetMouseState(mx,my,,mb) = -1 Then Return 0
	
	If button->mouseOver=1 And mb<>0 And buttonIsMoving=0 Then
		buttonIsMoving=1
		buttonDiffY= my-button->position.y
		
	EndIf
	
	If mb=0 Then buttonIsmoving=0 
	
	If buttonIsMoving=1 Then
		wasChanged=1
		Islock=0
		button->position.y=my-buttonDiffY
		If (my-buttonDiffY)<=position.y Then button->position.y=position.y
		
		If button->position.y+button->height>position.y+height Then button->position.y = position.y+height-button->height : isLock=1
		status = ((MaxStatus-(height/itemHeight))) * ((button->position.y-position.y) / (height-button->height))
	EndIf
	
	
	
	
	
	If isLock=1 Then
		button->position.y=position.y+height-button->height
		status = ((MaxStatus-(height/itemHeight))) * ((button->position.y-position.y) / (height-button->height))
	EndIf
	
	
	Return 1
End Function

Sub scrollUDT.setStatus(Status As Integer)
	IsLock=0
	If status<0 Then Return
	
	If ((status*(height-button->height))/((MaxStatus-(height/itemHeight))) + position.y)+button->height>position.y+height Then
		button->position.y = position.y+height-button->height 
		isLock=1
		status = ((MaxStatus-(height/itemHeight))) * ((button->position.y-position.y) / (height-button->height))
		wasChanged=1
		todo
		return
	EndIf
	
	this.status=status
	button->position.y = (status*(height-button->height))\((MaxStatus-(height/itemHeight))) + position.y
	If button->position.y+button->height>position.y+height Then button->position.y = position.y+height-button->height : isLock=1
	todo
End Sub

Function scrollUDT.toString As String
	Return "scroll-element"
End Function
