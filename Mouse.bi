'---------------------------------------------------------------------------------------------------
' Mouse.bi
'---------------------------------------------------------------------------------------------------
Enum TMouseButtons
	mbNone 
	mbLeft
	mbRight
	mbMiddle
End Enum
Type TMouse
    As Integer res
    As Integer x, y, wheel, clip
	Union 
		As Integer buttons 
		Type 
			left:1 as Integer 
			right:1 as Integer 
			middle:1 as Integer 
		end Type 
	End union 
	Declare Sub poll() 
	Declare Property is_button_down(Byval button_index As TMouseButtons) As Boolean
	Declare Property is_button_released(Byval button_index As TMouseButtons) As Boolean
	Declare Property is_double_click() As boolean 
	'private: 
		As Double _release_time
		As ubyte _double_click = 0 
		As Boolean _left_down = False 
		As Boolean _left_release = False 
		As Boolean _right_down = False 
		As Boolean _right_release = False 
		As Boolean _mid_down = False 
		As Boolean _mid_release = False 
	
		Declare Sub _set_state() 
End Type
Sub TMouse._set_state()
	' 
#Macro __check_for_double_click__
	If this._double_click = 1 Then 
		If Timer - this._release_time < .5 Then 
			this._double_click = 2
		Else 
			this._double_click = 0 
		EndIf
	Else
		this._double_click = 1  
		this._release_time = Timer 
	EndIf 
#EndMacro

	If this._double_click > 0 AndAlso Timer - this._release_time > .5 Then this._double_click = 0 
	If this._left_down = False Then 
		If this.left = 1 Then 		' the left button has been pressed down
			this._left_down = True 
			this._left_release = False 
		Endif 
	Else
		if this.left = 0 Then 
			this._left_release = True 
			this._left_down = FALSE
			__check_for_double_click__  
		Endif 
	Endif  
	If this._right_down = False Then 
		If this.right = 1 Then 		' the right button has been pressed down
			this._right_down = True 
			this._right_release = False 
		Endif 
	Else
		if this.right = 0 Then 
			this._right_release = True 
			this._right_down = False 
			__check_for_double_click__  
		Endif 
	Endif  
	If this._mid_down = False Then 
		If this.middle = 1 Then 		' the right button has been pressed down
			this._mid_down = True 
			this._mid_release = False 
		Endif 
	Else
		if this.middle = 0 Then 
			this._mid_release = True 
			this._mid_down = False 
			__check_for_double_click__  
		Endif 
	Endif  
	
	
End Sub
Sub TMouse.poll()
	'
	this.res = Getmouse(this.x, this.y, this.wheel, this.buttons, this.clip )
	If this.res = 0 Then 
		_set_state()
	End If
	Sleep 1,1 
End Sub
Property TMouse.is_button_down(Byval button_index As TMouseButtons) As Boolean 
	'
	Select Case button_index 
		Case mbNone
			Return False 
		Case mbLeft 
			Return this._left_down
		Case mbRight 
			Return this._right_down 
		Case mbMiddle 
			return this._mid_down	
	End Select
	' error state 
	Return False 
End Property
Property TMouse.is_button_released(Byval button_index As TMouseButtons) As Boolean 
	'
	Property = False 
	Select Case button_index 
		Case mbNone
			this._left_release = False 
			this._right_release = False 
			this._mid_release = False 
		Case mbLeft 
			Property = this._left_release
			this._left_release = false
		Case mbRight 
			Property = this._right_release
			this._right_release = False 		
		Case mbMiddle 
			Property = this._mid_release
			this._mid_release = FALSE
 	End Select
End Property
Property TMouse.is_double_click() As boolean 
	'
	property = cbool(this._double_click = 2)
	'this._double_click = 0 
End Property
'Screenres 800, 600, 32
'Dim As TMouse mouse 
'Do 
'	mouse.poll()
'	Print mouse.is_button_released(mbLeft)
'Loop while inkey=""