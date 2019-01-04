'=======================================================================================================================================
' Main.bas
'=======================================================================================================================================
#Define __main__ 
'=======================================================================================================================================
'--------------------------------------------------------------------------------
' RMapSundry.bi
'--------------------------------------------------------------------------------
#Define __sundry
Const As Long SC_LSHIFT = &H2A, _
				  SC_RSHIFT = &H36, _
				  SC_LEFT = &H4B, _
				  SC_RIGHT = &H4D, _ 
				  SC_HOME = &H47, _
				  SC_END = &H4F
'--------------------------------------------------------------------------------
#Define EXTCHAR  Chr(255)
#Define _CHAR_WIDTH 8 
#Define _CHAR_HEIGHT 16 
''--------------------------------------------------------------------------------
'#Include Once "SortedString.bi"
'#Include once "Mouse.bi"
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
'#Include Once "multikey.bi"
'--------------------------------------------------------------------------------
#Ifndef GFX_FULLSCREEN 
	#Define GFX_FULLSCREEN 1 
#EndIf
Type TRandom 
	Declare Static Function get_rnd(ByVal min As Integer, ByVal max As Integer) As Integer
	Declare Constructor()
	Declare Constructor(ByVal seed As Integer)
	Declare Property is_initialized() As boolean 
	Private:    
		As boolean _is_init
End Type
	Constructor TRandom()
		'
		Randomize Timer
		this._is_init = TRUE  
	End Constructor
	Constructor TRandom(ByVal seed As Integer)
		'
		Randomize seed
		this._is_init = TRUE  
	End Constructor
	Function TRandom.get_rnd(ByVal min As Integer, ByVal max As Integer) As Integer
		'
		Return Int(Rnd * (max - min + 1) + min) 
	End Function
'--------------------------
Union char_ref  
	As UByte n 
	As String * 1 c  
End Union
'--------------------------
Union color_ref 
	As Ulong value 
	Type 
		As Ubyte blue 
		As Ubyte green 
		As Ubyte red 
		As Ubyte a 
	End Type 
End Union 
'--------------------------
Type TVector2d
	As ulong x
	As Ulong y 
End Type
'--------------------------
Type TPoint extends TVector2D
	Declare Constructor()
	Declare Constructor (ByVal _X As ULong, ByVal _Y As ULong)
End Type
'--------------------------
	Constructor TPoint():End Constructor 
	Constructor TPoint(ByVal _X As ULong, ByVal _Y As ULong)
		'
		this.X = _X 
		this.Y = _Y
	End Constructor
'--------------------------
'#Include Once "range.bas"
Type TRange extends object 
	Declare Sub Reset() 
	Declare Function pop_x1(ByRef value As Integer = 0) As boolean 
	Declare Function pop_x2(ByRef value As Integer = 0) As boolean 
	Declare Function pop_top(ByRef value As Integer = 0) As boolean 
	Declare Function pop_bottom(ByRef value As Integer = 0) As boolean 
	Declare Sub for_max_to_min(ByVal call_back As Sub(ByVal value As Integer))
	Declare Sub for_min_to_max(ByVal call_back As Sub(ByVal value As Integer))
	Declare Sub unset_x1()
	Declare Sub unset_x2()
	Declare Sub set_upper_limit(ByVal value As Integer, ByVal force As boolean = TRUE)  
	Declare Sub set_lower_limit(ByVal value As Integer, ByVal force As boolean = TRUE)  
	Declare Function float(ByRef value As Integer) As boolean
	Declare Function sink(ByRef value As Integer) As boolean    
	Declare Static Function is_value_in_range (ByVal value As Integer, ByVal _x1 As Integer, ByVal _x2 As Integer) As boolean    
	
	Declare virtual Property Width() as Integer 
	Declare Property value_in_range(Byval value As Integer) As Boolean
	Declare Property max() As Integer
	Declare Property min() As Integer 
	Declare Property x1() ByRef As Integer 
	Declare Property x1(ByVal value As Integer) 
	Declare Property x2() ByRef As Integer 
	Declare Property x2(ByVal value As Integer)
	Declare Property upper_limit(ByVal value As Integer) 
	Declare Property upper_limit() As Integer 
	Declare Property lower_limit(ByVal value As Integer) 
	Declare Property lower_limit() As Integer
	Declare Property force_limit() As boolean 
	Declare Property force_limit(ByVal value As boolean)  
	Declare Property is_valid_range() As boolean
	Declare Property is_x1_set() As boolean 
	Declare Property is_x1_set(ByVal value As boolean) 
	Declare Property is_x2_set() As boolean 
	Declare Property is_x2_set(ByVal value As boolean)
	Declare Property is_limited() As boolean 
	Declare Property Is_limited(ByVal value As boolean)  
	
	Declare Operator Let(ByRef rhs As String)
	 
	Declare Constructor() 
	Declare Constructor(ByVal start_x As Integer, ByVal end_x As Integer)
	Declare Constructor(ByVal start_x As Integer, ByVal end_x As Integer, _
							 ByVal low_limit As Integer, ByVal up_limit As Integer, ByVal force As boolean = TRUE)
	
	Private: 
		As Integer _x1 
		As Integer _x2
		As Integer _lower_limit
		As Integer _upper_limit
		As boolean _has_lower_limit = FALSE 
		As boolean _has_upper_limit = FALSE
		As boolean _force_limit = TRUE  		 
		As boolean _is_x1_set = FALSE  
		As boolean _is_x2_set = FALSE 
		As boolean _limited = FALSE 
End Type
	'---------------------------------------------------------------------
	Constructor TRange()
		'
	End Constructor
	Constructor TRange(ByVal range_start As Integer, ByVal range_end As Integer)
		'
		this._x1 = range_start
		this._x2 = range_end
	End Constructor
	Constructor Trange(ByVal start_x As Integer, ByVal end_x As Integer, _
							 ByVal low_limit As Integer, ByVal up_limit As Integer, ByVal force As boolean = TRUE)
		'
		With This 
			.constructor(start_x, end_x) 
			._lower_limit = low_limit
			._upper_limit = up_limit
			._limited = TRUE 
			._has_lower_limit = TRUE 
			._has_upper_limit = TRUE  
			._force_limit = force  
		End With
	End Constructor
	'---------------------------------------------------------------------
	Property TRange.is_limited() As boolean
		'
		Return this._limited
	End Property
	Property TRange.is_limited(ByVal value As boolean)
		'
		this._limited = value 
	End Property
	Property TRange.is_x1_set() As boolean 
		' 
		Return this._is_x1_set
	End Property
	Property TRange.is_x1_set(ByVal value As boolean) 
		'
		this._is_x1_set = value 
	End Property
	Property TRange.is_x2_set() As boolean 
		' 
		Return this._is_x2_set
	End Property
	Property TRange.is_x2_set(ByVal value As boolean) 
		'
		this._is_x2_set = value 
	End Property
	Property TRange.is_valid_range() As boolean
		' 
		Return cbool(this._is_x1_set = TRUE AndAlso this._is_x2_set = TRUE) 
	End Property

	Property TRange.max() As Integer
		'
		With This 
			Return IIf(._x2 > ._x1, ._x2, ._x1) 
		End With 
	End Property
	Property TRange.min() As Integer
		'
		With This 
			Return IIf(._x2 > ._x1, ._x1, ._x2) 
		End With 
	End Property
	Property TRange.Width() As Integer 
		'
		Return Abs(this._x2 - this._x1) + 1 
	End Property
	Property TRange.value_in_range(Byval value As Integer) As Boolean 
		'
		With This
			Dim As Integer _min = .min, _max = .max 
			If value > _max Then Return FALSE  
			If value < _min Then Return FALSE
			Return TRUE
		End With  
	End Property
	Property TRange.x1() ByRef As Integer
		'
		Return this._x1 
	End Property
#Macro __limit_check__()
	With This 
		If ._has_lower_limit = TRUE Then 
			If value < ._lower_limit Then
				If ._force_limit Then 
					value = ._lower_limit
				Else 
					Return 
				EndIf 
			EndIf
		EndIf
		If ._has_upper_limit = TRUE Then 
			If value > ._upper_limit Then 
				If ._force_limit Then 
					value = ._upper_limit
				Else
					Return 
				EndIf
			EndIf
		EndIf
	End With 
#EndMacro
	Property TRange.x1(ByVal value As Integer)
		'
		__limit_check__()
		With This 
			._x1 = value
			._is_x1_set = TRUE 
		End With 
	End Property
	Property TRange.x2() ByRef As Integer
		'
		Return this._x2
	End Property
	Property TRange.x2(ByVal value As Integer)
		'
		__limit_check__()
		With This
			._x2 = value
			._is_x2_set = TRUE 
		End With  
	End Property
	Property TRange.force_limit() As boolean
		'
		Return this._force_limit 
	End Property
	Property TRange.force_limit(ByVal value As boolean)
		'
		this._force_limit = value 
	End Property
	Property TRange.upper_limit(ByVal value As Integer)
		'
		this._upper_limit = value
		this._has_upper_limit = TRUE
		this._limited = TRUE  
	End Property
	Property TRange.upper_limit() As Integer
		'
		Return this._upper_limit
	End Property
	Property TRange.lower_limit(ByVal value As Integer)
		'
		this._lower_limit = value
		this._has_lower_limit = TRUE
		this._limited = TRUE   
	End Property
	Property TRange.lower_limit() As Integer
		'
		Return this._lower_limit
	End Property
	'---------------------------------------------------------------------------------------------------------------
	Sub TRange.reset() 
		'
		With This 
			._is_x1_set = FALSE 
			._is_x2_set = FALSE 
			._x1 = 0 
			._x2 = 0
		End With 
	End Sub
	Function TRange.pop_x1(ByRef value As Integer = 0) As boolean
		'
		' Return in byref parameter value x1 and step it 1 towards x2 
		' If x1 = x2 then return false otherwise return true 
		With This 
			value = ._x1 
			If ._x1 = ._x2 Then 
				.reset()
				Return FALSE  
			ElseIf ._x1 < ._x2 Then
				._x1 += 1
			ElseIf ._x1 > ._x2 Then 
				._x1 -= 1 
			EndIf
			Return TRUE 
		End With
	End Function
	Function TRange.pop_x2(ByRef value As Integer = 0) As boolean
		'
		' Return in byref parameter value x2 and step it 1 towards x2 
		' If x1 = x2 then return false otherwise return true 
		With This 
			value = ._x2 
			If ._x1 = ._x2 Then
				.reset()
				Return FALSE  
			ElseIf ._x1 < ._x2 Then
				._x2 -= 1
			ElseIf ._x1 > ._x2 Then 
				._x2 += 1 
			EndIf
			Return TRUE 
		End With
	End Function
	Function TRange.pop_top(ByRef value As Integer = 0) As boolean
		'
		' This function takes the max value and moves it down one towards the min value 
		' The higher value is returned byref in parameter value 
		' This function returns true unless min = max and thus value = min
		' when min = max both x1 and x2 are reset and set to 0
		With This 
			If .min = .max Then 
				value = .max
				.reset() 
				Return FALSE 
			EndIf
			If ._x1 < ._x2 Then 
				value = ._x2 
				._x2 -= 1
			ElseIf ._x1 > ._x2 Then 
				value = ._x1 
				._x1 -= 1 
			EndIf
			Return TRUE 
		End With
	End Function
	Function TRange.pop_bottom(ByRef value As Integer = 0) As boolean 
		'
		' This function takes the min value and moves it up one towards the max value 
		' The lower value is returned byref in parameter value 
		' This function returns true unless min = max and thus value = max
		' when min = max both x1 and x2 are reset and set to 0
		With This 
			If .min = .max Then 
				value = .max
				.reset() 
				Return FALSE 
			EndIf
			If ._x1 < ._x2 Then 
				value = ._x1 
				._x1 += 1
			ElseIf ._x1 > ._x2 Then 
				value = ._x2 
				._x2 += 1 
			EndIf
			Return TRUE 
		End With
	End Function
	Sub TRange.set_upper_limit(ByVal value As Integer, ByVal force As boolean = TRUE)
		'
		With This 
			._has_upper_limit = TRUE 
			._force_limit = force 
			._upper_limit = value 
		End With
	End Sub 
	Sub TRange.set_lower_limit(ByVal value As Integer, ByVal force As boolean = TRUE)
		'
		With This 
			._has_lower_limit = TRUE 
			._force_limit = force 
			._lower_limit = value 
		End With
	End Sub  
	Function TRange.is_value_in_range(ByVal value As Integer, ByVal _x1 As Integer, ByVal _x2 As Integer) As boolean
		'
		If value < _x1 Then Return FALSE 
		If value > _x2 Then Return FALSE 
		Return TRUE 
	End Function
	Function TRange.float(ByRef value As Integer) As boolean
		'
		' this function steps the lower value in the range up to the higher value 
		' it returns true and the stepped value until the last value where it returns false ie use it in a do loop not a while loop 
		With This 
			If ._x1 < ._x2 Then  
				value = ._x1
				._x1 += 1
				Return TRUE 
			ElseIf ._x2 < ._x1 Then 
				value = ._x2
				._x2 += 1
				Return TRUE 
			Else
				value = ._x1 
				Return FALSE 
			EndIf    
		End With
	End Function
	Function TRange.sink(ByRef value As Integer) As boolean
		'
		' this function steps the 
		With This 
			If ._x2 > ._x1 Then  
				value = ._x2
				._x2 -= 1
				Return TRUE 
			ElseIf ._x1 > ._x2 Then 
				value = ._x1
				._x1 -= 1
				Return TRUE 
			Else
				value = ._x2 
				Return FALSE 
			EndIf    
		End With
		
	End Function
	Sub TRange.for_min_to_max(ByVal call_back As Sub(ByVal value As Integer))
		'
		With This 
			Dim As Integer _min = .min, _max = .max
			?"sss "; _min, _max 
			For i As Integer = _min To _max 
				call_back(i)
			Next
		End With 
	End Sub
	Sub TRange.for_max_to_min(ByVal call_back As Sub(ByVal value As Integer))
		'
		With This 
			Dim As Integer _min = .min, _max = .max
			For i As Integer = _max To _min Step -1  
				call_back(i)
			Next
		End With 
		
	End Sub
#Ifndef __edit2
#Ifndef __sundry 	
Sub test(ByVal value As Integer) 
	? value 
End Sub
Dim As TRange r

r.x1 = 5
r.x2 = 4 
?"ho "; r.value_in_range(4) 


? r.is_valid_range

r.lower_limit = 15
'r.set_upper_limit(17, FALSE) 
r.x2 = 14
r.x1 = 29
(r.x1) += 1
(r.x2) += 1 
'? r.is_valid_range, r.max 
'
'	Dim As boolean result 
'Do
'	Dim As Integer value
'	result = r.sink(value)
'	? value 
'Loop While result = TRUE
'?
'r.for_min_to_max(@test)
?
'r.for_max_to_min(@test)

Dim As Integer n
Dim As boolean b 
Do 
	'b = r.pop_bottom(n)
	b = r.pop_x2(n) 
	? n, b  
Loop While r.is_valid_range = TRUE 
sleep

#EndIf
#EndIf  
'--------------------------
'-----------------------------------------------------------------------------------------------------------	
Type TRect 
	As Ulong x1 
	As Ulong y1
	As Ulong x2 
	As Ulong y2
	Declare Sub vert_shift(Byval amount As ulong)
	Declare Sub horiz_shift(Byval amount As Ulong) 
	Declare Function is_point_in_rect(Byref value As TVector2d) As Boolean 
	Declare Operator +=(Byref rhs As TVector2d) 
	Declare Property Width() as Ulong
	Declare Property height() as ULong
	Declare Operator Cast() As String
	Declare Constructor() 
	Declare Constructor(ByVal leftX As ULong, ByVal topY As ULong, ByVal rightX As ULong, ByVal bottomY As ULong)   
End Type
'---------------------------------------------------------------------------------------------------
	Constructor TRect()
		'
	End Constructor
	Constructor TRect(ByVal leftX As ULong, ByVal topY As ULong, ByVal rightX As ULong, ByVal bottomY As ULong)
		'
		this.x1 = leftX 
		this.x2 = rightX 
		this.y1 = topY 
		this.y2 = bottomY 
	End Constructor
	   
	Property TRect.height() as Ulong 
		Return Abs(this.y2-this.y1 + 1) 	
	End Property
	Property TRect.Width() As Ulong 
		Return Abs(this.x2-this.x1 + 1)	
	End Property
	Operator TRect.cast() As String 
		'
		Return this.x1 & " " & this.y1 & " " & this.x2 & " " & this.y2
	End Operator
	Operator TRect.+=(Byref rhs As TVector2d) 
		this.x1 += rhs.x
		this.x2 += rhs.x
		this.y1 += rhs.y
		this.y2 += rhs.y
	End Operator
	Function TRect.is_point_in_rect(Byref value As TVector2d) As Boolean
		'
		Dim As TRange r
		r.x1 = this.x1
		r.x2 = this.x2
		
		If r.value_in_range(value.x) = false Then Return False 
		
		r.x1 = this.y1
		r.x2 = this.y2

		If r.value_in_range(value.y) = false Then Return False 
		Return True 
	End Function
	Sub TRect.horiz_shift(Byval amount As Ulong) 
		'
		this.x1 += amount 
		this.x2 += amount 	
	End Sub
	Sub TRect.vert_shift(Byval amount As ulong)
		this.y1 += amount
		this.y2 += amount 	
	End Sub
'--------------------------------------------------------------------------
Type TGraphicsRect extends TRect
		As ULong back_color = RGB(255,255,255) 
		As ULong border_color = RGB(255,255,255) 
		Declare Sub Draw(ByVal pTarget As Any Ptr = 0)
		Declare Constructor
		Declare Constructor (ByVal rect As TRect, ByVal backcolor As ULong, ByVal bordercolor As ULong)
End Type
	Constructor TGraphicsRect()
		'
	End Constructor
	Constructor TGraphicsRect(ByVal rect As TRect, ByVal backcolor As ULong, ByVal bordercolor As ULong)
		'
		With This 
			.x1 = rect.x1
			.x2 = rect.x2
			.y1 = rect.y1 
			.y2 = rect.y2
			.back_color = backcolor 
			.border_color = bordercolor
		End With
	End Constructor
	'---------------------------------------------------------
	Sub TGraphicsRect.draw(ByVal pTarget As Any Ptr = 0)
		With This		
			If pTarget = 0 Then 
				Line (.x1,.y1)-(.x2,.y2), back_color, bf 
				Line (.x1,.y1)-(.x2,.y2), border_color, b
			Else 
				Line pTarget, (0, 0) - Step(this.width-1, this.height-1), back_color, bf 
				Line pTarget, (0, 0) - Step(this.width-1, this.height-1), border_color, b
			EndIf  
		End With 
	End Sub
'--------------------------------------------------------------------------
#Macro _wait()
	Scope 
		While Inkey = ""
			Dim As TMouse mouse 
			mouse.res = Getmouse(mouse.x, mouse.y, mouse.wheel, mouse.buttons) 
			If mouse.res = 0 Then 
				If mouse.buttons <>0 Then 
					Exit While
				End If			
			End If		
		Wend
	End Scope 
#Endmacro
#macro _sleep( args... )
    While InKey() <> "" : Wend
    Sleep args
#endmacro				
#Macro __graphics(t)		
	Scope 
		If #t="off" Then 
			Screen 0 
		Elseif #t="f" Then 
			If Screenptr() = 0 Then 
				Screenres  1024,768, 32,, GFX_FULLSCREEN
				Width 1024\_CHAR_WIDTH, 768\_CHAR_HEIGHT
			End If
		ElseIf #t="2" Then 
			If Screenptr() = 0 Then 
				Screenres  1024,768, 32,2, GFX_FULLSCREEN
				Width 1024\_CHAR_WIDTH, 768\_CHAR_HEIGHT
			End If
		ElseIf #t="s" Then 
			If Screenptr() = 0 Then 
				Screenres  1024,288, 32
				Width 1024\_CHAR_WIDTH, 288\_CHAR_HEIGHT 
			End If
		Else 
			If Screenptr() = 0 Then 
				ScreenRes  1024,768, 32
				Width 1024\_CHAR_WIDTH, 768\_CHAR_HEIGHT 
			End If
		Endif 
	End Scope 
#EndMacro
#Macro __CLEAR_KEY_BUFFER()
	While InKey<>"":Wend
#EndMacro 
'--------------------------------------------------------------------------
sub draw_centered_string(Byref s As string, Byval y As Integer, Byval c As Ulong)
	'
	dim As Integer w = Len(s) * _CHAR_WIDTH, x
	x = (1024 - w) \ 2
	Draw String (x, y), s, c
End Sub
'--------------------------------------------------------------------------
'#include Once "log.bi"

'#include Once "Button.bi"
'--------------------------------------------------------------------------
Function zero_prefix_number(ByVal number As Integer, ByVal count As Integer = 6) As String
	'
	Dim As String s = Str(number) 
	While Len(s) < count  
		s = "0" & s 
	Wend
	Return s 
End Function
Function string_array_to_string(s() As String, ByRef delim As String = " ") As String 
	'
	Dim As String ret_val 
	For i As Integer = LBound(s) To UBound(s) 
		ret_val &= s(i)
		If i < UBound(s) Then ret_val &= delim 
	Next
	Return ret_val 
End Function
'------------------------------------------------------------------------------------
' marpons split function - requires two functions 
#Include "crt/string.bi"   'needed for memchr function
'helper function for String_tok_r
Private Function h_tok_r(byref ps1 as byte ptr, byref ps2 as byte ptr, byval i as long )as byte ptr
   dim p as byte ptr
   if i > 1 THEN
      while memchr(ps2, *ps1 ,  i) <> 0
         ps1 += 1
      wend
   else
      while *ps1 = *ps2
         ps1 += 1
      wend   
   END IF   
   if *ps1 = 0 THEN
      ps1 = 0
      return 0
   END IF
   p = ps1
   if i > 1 THEN
      while memchr(ps2, *ps1 , i) = 0  
         ps1 += 1
         if *ps1 = 0 then exit while
      wend
   else
      while *ps1 <> *ps2 
         ps1 += 1
         if *ps1 = 0 then exit while
      wend   
   end if      
   if *ps1 <> 0 THEN
      *ps1 = 0
      ps1 += 1
   end if
   return p
end function  
'thread-safe alternative to Split_tok
'splits TEXT using every char of DELIMIT as delimiter,  
'works as Split_any but only the non-empty elements will be on the RET array  
Private Function Split_tok_r(byref TEXT As String , byref DELIMIT As String ,  RET() As String) As Long
   Dim ptemp As Zstring Ptr
   Dim ctr As Long
   Dim size1 As uLong 
   
   dim as long ilen = len(DELIMIT)
   if(len(TEXT) = 0 or ilen = 0) then
      Redim RET(1 To 1) 
      RET(1) = TEXT
      return 1
   end if
   dim as string s1 = TEXT            'copy TEXT to avoid alteration of the input
   dim As byte Ptr p = strptr(s1)   'get pointers
   dim As byte Ptr d = strptr(DELIMIT)
   ptemp = p 
   while ptemp <> 0
      ptemp = h_tok_r(p, d, ilen)  ' p is sent byref and it will be modified on the f_strtok_r function 
      if ptemp <> 0 THEN
         ctr += 1
         if ctr = 1  THEN
            size1 = 1
            Redim RET(1 To size1)     'redim the array
         elseif ctr > size1 then
            size1 *= 2
            redim preserve RET(1 To size1)     'redim the array
         END IF
         RET(ctr)= *ptemp
      end if
   WEND
   If ctr = 0 Then Return 0
   if size1 > ctr then Redim preserve RET(1 To ctr)     'redim the array
   Return ctr
end Function
Function is_value_in_array(ByRef s As Const String, array() As String) As boolean
	'
	For i As Integer = LBound(array) To UBound(array) 
		If s = array(i) Then Return TRUE 
	Next
	Return FALSE 
End Function
Sub remove_array_element OverLoad (ByVal index As Integer, array() As Any Ptr) 
	'
	' remove element from a pointer array via index 
	Dim As Integer l, u, n  
	l = LBound(array): u =  UBound(array)
	For i As Integer = l To u
		If i <> index Then
			u -= 1 
			n += 1
			array(n) = array(i) 
		EndIf
	Next
	ReDim Preserve array(l To n) 
			
End Sub
Sub remove_array_element(ByRef element As String, array() As String) 
	'
	' remove element from string array via string matching 
	Dim As Integer l, u, n  
	l = LBound(array): u =  UBound(array)
	If l = u Then
		' this is the best we can do with a single element array 
		ReDim array(0 To 0)
		Return  
	EndIf
	For i As Integer = l To u
		If element <> array(i) Then
			u -= 1 
			n += 1
			array(n) = array(i) 
		EndIf
	Next
	ReDim Preserve array(l To n) 
End Sub
	
#EndIf 

Const As ULong GUITAR_NECK_LENGTH = 900, GUITAR_LEFT_X = 50, GUITAR_TOP_Y = 84, GUITAR_FRET_COUNT = 22, GUITAR_NECK_WIDTH = 121, _
 					GUITAR_NUT_WIDTH = 5, SCALE_LENGTH = 1300, SKILL_COUNT = 28  
Const As ULong DEFAULT_SET_ROUND_COUNT = 5, DEFAULT_ROUND_COURSE_COUNT = 12, DEFAULT_MATCH_SET_COUNT = 3
Const As ULong GAME_BUTTON_LEFT = 220
Const As Double PHASE_1_TIME = 10, PHASE_2_TIME = 30, PHASE_3_TIME = 50
Const As ULong MENU_BAR_TOP = 27, MENU_BAR_BOTTOM = 53, MENU_BAR_LEFT = 220, MENU_BAR_RIGHT = 840
Const As ULong STATUS_BAR_LEFT = 58, STATUS_BAR_TOP = 233, STATUS_BAR_RIGHT = 914, STATUS_BAR_BOTTOM = 259  
'---------------------------------------------------------------------------------------------------------------------------------------
#Define __dim_guitar_ptr Dim As TGuitar Ptr pGtr = @Main_._guitar

#Macro __get_rand_string_fret(T)
	__string = T##_guitar.get_random_string()
	__fret = T##_guitar.get_random_fret() 
#EndMacro
#Macro  __dim_string_fret()
	Dim As Integer __string, __fret
#EndMacro
'=======================================================================================================================================
#Ifndef __data__
	'#Include Once "data.bi"  
	#Define __data__
	SKILLs_DATA: 	' 28
	Data "Virtuoso", "Prodigy", "Artiste", "Wizard", "Musician", "Accomplished", "Performer", "Dilletante", "Authority"		' 9
	Data "Expert", "Proficient", "Talented", "Adept"	' 4
	Data "Decent", "Midling", "Ordinary", "Intermediate", "Passable", "Tolerable"		' 6
	Data "Uninspired", "Humble", "Subpar", "Trivial", "Meager", "Inferior", "Weak", "Pitiful", "Untested"	'9			
	Data 100000, 75000, 50000, 25000, 10000, 9000, 8000, 7000, 6000
	Data 5000, 4000, 3000, 2000
	Data 1000, 900, 800, 700, 600, 500
	Data 400, 350, 300, 250, 200, 150, 100, 50, 0  		
#EndIf 
#Ifndef __guitar__
	'#Include Once "guitar.bas"  
'========================================================================================================================================
' Guitar.bas
'========================================================================================================================================
#Define __guitar__ 
'========================================================================================================================================
'#Include Once "guitar.bi"
'----------------------------------------------------------------------------------------------------------------------------------------
' Guitar.bas
'----------------------------------------------------------------------------------------------------------------------------------------
'#Include Once "sundry.bi"
'#Include Once "palette.bi"
'------------------------------------------------------------------------------------------------------------------------------------------
' palette.bi
'------------------------------------------------------------------------------------------------------------------------------------------
Namespace pal
Const As Ulong  BLACK = &HFF000000, _
				PURPLE = &HFF262144, _
				DARK_BLUEGRAY = &HFF355278, _
				BLUEGRAY = &HFF60748A, _ 
				GRAY = &HFF898989, _
				DARK_CYAN = &HFF5aa8b2, _ 
				CYAN = &HFF91d9f3, _
				WHITE = &HFFffffff, _
				SAND = &HFFf4cd72, _ 
				CLAY = &HFFbfb588, _
				WOOD = &HFFc58843, _
				BROWN = &HFF9e5b47, _
				PURPLE_BROWN = &HFF5f4351, _
				RED = &HFFdc392d, _
				GREEN = &HFF6ea92c, _
				BLUE = &HFF1651dd
End Namespace

'#Include Once "notes.bi" 
'========================================================================================================================================
' Notes.bi
'========================================================================================================================================
#Define __Notes__
'========================================================================================================================================
Namespace Notes_
	'========================================================================================================================================
	Type TNoteSet 
		As String * 2 notes(any)
		As Integer count
		Declare Sub add_note(ByRef note As Const String)
		Declare Constructor(ByVal note_count As Integer)
		Declare Constructor() 
		Declare Sub dump()  
	End Type
	'--------------------------------------------------------------------------------------------------------------------------------------
		Constructor TNoteSet():End Constructor 
		Constructor TNoteSet(ByVal note_count As Integer)
			'
			ReDim notes(1 To note_count) 
		End Constructor
		'--------------------------------------------------------------------------------------------------------------------------------------
		Sub TNoteSet.add_note(ByRef note As Const String)
			'
			With This
				ReDim Preserve .notes(0 To .count)
				.count += 1 
				.notes(count - 1) = note 
				'?"ccc "; .count, .notes(count-1)
			End With  
		End Sub
		Sub TNoteSet.dump() 
			For i As Integer = 0 To this.count-1 
				? i & "> " & this.notes(i) &  " <"
			Next
		End Sub
	'========================================================================================================================================
	Dim Shared As String * 2 notes(1 To 12) = {"A ", "A#", "B ", "C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#"}
	'========================================================================================================================================
	Declare Sub create_noteset(ByRef root_note As Const String, ByRef note_set As TNoteSet)
	Declare Sub get_n_notes_from_a(ByRef a As Const String, ByVal n As Integer, ret_val() As string)
	Declare Function _get_note_index(ByRef note As Const String) As integer   
	Declare Function is_valid_note(ByRef s As String) As boolean  
	'========================================================================================================================================
	sub create_noteset(ByRef root_note As Const String, ByRef note_set As TNoteSet)
		'
		Dim As Integer r = _get_note_index(root_note), n, count = UBound(note_set.notes) 
		If r = 0 Then 
			?"Error in "& __FUNCTION__ 
			? "Note > " & root_note & " < not found"
			Sleep 
			End   
		EndIf
			
		While n < count 
			note_set.add_note(notes(r))
			n += 1 
			r += 1 
			If r > 12 Then r = 1
		Wend
	End Sub  
	Sub get_n_notes_from_a(ByRef a As Const String, ByVal n As Integer, ret_val() As string)
		'
		
	End Sub
	Function _get_note_index(ByRef note As Const String) As Integer
		'
		For i As Integer = 1 To 12 
			Dim As String * 2 s  
			LSet s, note
			'? ">";LCase(notes(i));"<", ">";LCase(s);"<", LCase(notes(i)) = LCase(s) 			
			If LCase(notes(i)) = LCase(s) Then Return i 
		Next
		Return 0 
	End Function
 End Namespace 

'----------------------------------------------------------------------------------------------------------------------------------------
#Define __FRET_RATIO 1.059463
#Define __RULE_OF_18 17.817153
'----------------------------------------------------------------------------------------------------------------------------------------
Type TString 
	'As TFretNote frets(0 To 21)
	As Notes_.TNoteSet notes
	Declare Sub init(ByRef note As String, ByVal fret_count As integer)
	
	Declare Property note(ByVal fret_number As Integer) As String  
	'Declare Sub copy_from_noteset(ByRef note_set As Notes_) 
End Type
	Property TString.note(ByVal fret_number As Integer) As String
		'
		'Dim As String * 2 s = "  "
		's = notes.notes(fret_number) 
		'Return s
		Return notes.notes(fret_number)   
	End Property

	Sub TString.init(ByRef open_note As String, ByVal fret_count As integer)
		'
		ReDim this.notes.notes(0 To fret_count)
		Notes_.create_noteset(open_note, this.notes)
	End Sub
'----------------------------------------------------------------------------------------------------------------------------------------
'----------------------------------------------------------------------------------------------------------------------------------------
Type TGuitar
	As Any Ptr guitar_img		' guitar image that will be shown and drawn on  
	As Any Ptr _guitar_img 		' guitar image that will be used to restore drawn image
	
	As ULong left_x 				' where the guitar is drawn on the screen 
	As ULong top_y 			
	As ULong Width 
	As ULong height 
	
	As ULong neck_width 
	As ULong fret_count 
	As ULong string_count = 6
	As ULong scale_length 
	As ULong neck_length
	As Integer nut_width 
	As ULong border_color = pal.PURPLE
	As ULong fill_color = pal.PURPLE_BROWN
	As ULong dot_color = pal.PURPLE 
	As ULong string_color = pal.CYAN
	As ULong nut_color = pal.CLAY
	As ULong fret_color = pal.GRAY	   
	'--------------------------------------------------
	Declare Constructor()
	Declare Destructor()  
	'-------------------------------------------------- 
	Declare Sub init( ByVal x As ULong, ByVal y As ULong, ByVal nw As ULong, ByVal fc As ULong, _
							ByVal sl As ULong, ByVal nl As ULong, ByVal nuw As ulong)
	Declare Sub Paint() 
	Declare Sub draw_note(ByRef note As Const String, ByVal clr As ULong = &hFFFFFFFF)
	Declare Sub draw_note(ByVal string_number As Integer, ByVal fret_number As Integer, ByVal clr As ULong = &HFFFFFFFF)
	Declare Function get_string_center_y(ByVal string_number As Integer) As Integer 
	Declare function get_fret_x(ByVal fret_number As Integer) As Integer 
	Declare function get_fret_center_x(ByVal fret_number As Integer) As Integer 
	Declare Function is_point_in_hotspot(ByVal pnt As TPoint, ByRef String_number As integer = 0, ByRef fret_number As Integer = 0) As boolean 
	Declare Function get_random_fret(ByVal min As Integer = 0, ByVal max As Integer = -1) As Integer 
	Declare Function get_random_string(ByVal min As Integer = 1, ByVal max As Integer = 6) As Integer
	Declare Function get_note(ByVal string_number As Integer, ByVal fret_number As Integer) As String 
	Declare Sub _draw_hotspots()
	Declare Sub revert(ByRef note As Const String)
	Declare Sub revert(ByVal string_number As Integer, ByVal fret_number As Integer)
	Declare Sub revert()  
	'-------------------------------------------------- 
	Declare Operator Cast() As Any Ptr		' returns guitar_img
	'-------------------------------------------------- 
	Private: 
		Declare Sub _init_image() 
		Declare Sub _init_hotspots()
		Declare Sub _init_strings()
		'-------------------------------------------------- 
		As TString _strings(1 To 6)
		As TRect _hotspots(Any, Any)  
End Type
'----------------------------------------------------------------------------------------------------------------------------------------
	Constructor TGuitar():End Constructor
	Destructor TGuitar() 
		'
		With This 
			If .guitar_img <> 0 Then 
				imagedestroy .guitar_img
				.guitar_img = 0
			EndIf 
			If ._guitar_img <> 0 Then 
				ImageDestroy ._guitar_img 
				._guitar_img = 0
			EndIf
		End With 
	End Destructor
	'-------------------------------------------------- 
	Sub TGuitar.draw_note(ByRef note As Const String, ByVal clr As ULong = &hFFFFFFFF)
		'
		With This 
			For _string As Integer = 1 To 6 
				For _fret As Integer = 0 To .fret_count
					Dim As String s = Trim(.get_note(_string,_fret))
					If LCase(note) = lcase(s) Then
						.draw_note(_string, _fret)
					EndIf
				Next
			Next
		End With
	End Sub

	Function TGuitar.get_note(ByVal string_number As Integer, ByVal fret_number As Integer) As String
		'
		With This 
			Return ._strings(string_number).note(fret_number)
		End With
	End Function

	'------------------------------------------------
	Sub TGuitar.paint()
		'
		With This 
			Put (.left_x, .top_y), .guitar_img, PSet 
		End With
	End Sub
	Function TGuitar.is_point_in_hotspot(ByVal pnt As TPoint, ByRef String_number As integer = 0, ByRef fret_number As Integer = 0) As boolean
		'
		With This 
			Dim As Integer minY, maxY, minX, maxX
			minY = ._hotspots(1,0).y1 
			If pnt.y < minY Then Return FALSE 
			maxY = ._hotspots(6,0).y2 
			If pnt.y > maxY Then Return FALSE 
			
			minX = ._hotspots(1,0).x1 
			If pnt.x < minX Then Return FALSE 
			maxX = ._hotspots(1,.fret_count).x2
			If pnt.x > maxX Then Return FALSE  
			
			For i As Integer = 1 To 6
				Dim As Integer x, y 
				If TRange.is_value_in_range(pnt.y, ._hotspots(i,0).y1, ._hotspots(i,0).y2) = TRUE Then 
					For f As Integer = 0 To .fret_count 
						If TRange.is_value_in_range(pnt.x, ._hotspots(i,f).x1, ._hotspots(i,f).x2) = TRUE Then 
							string_number = i: fret_number = f 
							Return TRUE 
						EndIf
					Next
				EndIf
			Next
			Return FALSE 
		End With 
	End Function
	Sub TGuitar._init_strings() 
		'
		Dim As String * 1 s(1 To 6) = {"E", "B", "G", "D", "A", "E"}
		
		For i As Integer = 1 To 6 
			this._strings(i).init(s(i), this.fret_count)
		Next
		
	End Sub
	Sub TGuitar.revert() 
		'
		With This 
			Get ._guitar_img, (0, 0)-(.width-1, .height-1), .guitar_img 
			Paint() 
		End With
	
	End Sub
	Sub TGuitar.revert(ByRef note As Const String)
		'
		With This 
			For _string As Integer = 1 To 6 
				For _fret As Integer = 0 To .fret_count
					Dim As String s = Trim(.get_note(_string,_fret))
					If LCase(note) = lcase(s) Then
						.revert(_string, _fret)
					EndIf
				Next
			Next
		End With 
	End Sub 

'========================================================================================================================================
Operator TGuitar.Cast() As Any Ptr 
	Return this.guitar_img 
End Operator
'========================================================================================================================================
Sub TGuitar.init(	ByVal x As ULong, ByVal y As ULong, ByVal nw As ULong, ByVal fc As ULong, _
						ByVal sl As ULong, ByVal nl As ULong, ByVal nuw As ulong)
	'
	With This 
		.left_x = x
		.top_y = y 
		.neck_width = nw 
		.fret_count = fc
		.scale_length = sl
		.neck_length = nl
		.nut_width = nuw   

		ReDim ._hotspots(1 To 6, 0 To .fret_count) 
		._init_image()
		._init_strings()
		._init_hotspots() 
	End With 
End Sub
Function TGuitar.get_fret_center_x(ByVal fret_number As Integer) As Integer
'
	If fret_number = 0 Then Return 18 
	Dim As Integer lf, rf
	lf = this.get_fret_x(fret_number - 1):rf = this.get_fret_x(fret_number)
	Return (rf - lf) \ 2 + lf
End Function 
Function TGuitar.get_string_center_y(ByVal string_number As Integer) As Integer
	'
	With This 
		Dim As Integer n = (.neck_width - (6 * 18)) \ 2, r = (.neck_width Mod 18) \ 2, gap, rem_space
		gap = .neck_width \ 6
		rem_space = (.neck_width Mod (gap * 5)) \ 2
		n = rem_space 
		n += (string_number - 1) * gap 
		Return n
	End With  
End Function
Function TGuitar.get_fret_x(ByVal fret_number As Integer) As Integer
	'
	With This 
		Dim As Integer fret_x = 18
		For i As Integer = 1 To fret_number
			fret_x = (.scale_length - fret_x) \ __RULE_OF_18 + fret_x
		Next
		Return fret_x
	End With 
End Function
Sub TGuitar._init_image() 
	'
	With This 
		Dim As Integer fret_x = 0, fret_count 
		Dim As Integer p = 0 ', w, h
		Dim As Any Ptr Ptr pGuitar = @.guitar_img 
		
		.width = .neck_length + 20
		.height = .neck_width   
	
		*pGuitar = ImageCreate(.width, .height,,32) 		    
		._guitar_img = ImageCreate(.width, .height,,32)

		' fretboard
		Line *pGuitar, (0, 0)-Step(.width-1, .height-1), .border_color, b 
	
		Line *pGuitar, (1,1)-Step(.width-2, .height-2), .fill_color, bf
	
		'dots  todo: the dots are fixed to the current neck width. they need to be sizeable 
		Dim As Integer x, lf, rf
	
		For i As Integer = 3 To 9 Step 2 
			x = get_fret_center_x(i)  
			Circle *pGuitar, (x, 60),12, .dot_color,,,,F
		Next
	
		x = get_fret_center_x(12) 
		Circle *pGuitar, (x, 28),10, .dot_color,,,,F
		Circle *pGuitar, (x, 92),10, .dot_color,,,,F
	
		For i As Integer = 15 To 21 Step 2 
			x = get_fret_center_x(i)  
			Circle *pGuitar, (x, 60),8, .dot_color,,,,F
		Next 
	
		' strings 
		For i As Integer = 1 To 6
			Dim As Integer y = get_string_center_y(i) 
			Line *pGuitar, (18, y)-Step(.neck_length - 1, 0), .string_color 
		Next

		'nut
		Line *pGuitar, (18, 0)-Step( -.nut_width, .neck_width), .nut_color, bf 

		'frets
		fret_x = 18 
		While fret_count < .fret_count
	
			Dim As Integer prev_fret = fret_x
			fret_x = (.scale_length - fret_x) \ __RULE_OF_18 + fret_x
	
			Line *pGuitar, (fret_x, 0)-Step(0, .neck_width), .fret_color ' .DARK_CYAN 
	
			fret_count += 1
		Wend
		
		' copy the image 
		Get *pGuitar, (0,0)-(.width-1, .height-1), ._guitar_img  
	End With 
End Sub
Sub TGuitar._draw_hotspots()
	' draws the hotspots green - adjust s and/or f in for next loop to test
	With This 
		For s As Integer = 1 To 6 Step 2 
			For f As integer = 4 To 4  '.fret_count Step 2
				Line .guitar_img, (_hotspots(s, f).x1, _hotspots(s,f).y1)-(_hotspots(s,f).x2, _hotspots(s,f).y2), pal.GREEN, bf 
			Next
		Next
	End With 
End Sub
Function TGuitar.get_random_fret(ByVal min As Integer = 0, ByVal max As Integer = -1) As Integer 
	'
	If max = -1 Then max = this.fret_count
	Return TRandom.get_rnd(min, max)
End Function
Function TGuitar.get_random_string(ByVal min As Integer = 1, ByVal max As Integer = 6) As Integer
	'
	Return TRandom.get_rnd(min, max) 
End Function
Sub TGuitar._init_hotspots()
	'
	With This 
		For i As Integer = 1 To 6
			Dim As Integer x1, y1, x2, y2 
			'x1 = .left_x - 30: x2 = .left_x -1
			x1 = 0: x2 = .get_fret_x(0) 				
			y1 = .get_string_center_y(i) - 8:y2 = y1 + 16
			._hotspots(i, 0) = Type<TRect>(x1,y1,x2,y2) 
			For f As Integer = 1 To .fret_count
				x1 = .get_fret_x(f - 1) + 1:x2 = .get_fret_x(f) - 1
				._hotspots(i, f) = Type<TRect>(x1,y1,x2,y2) 
			Next
		Next
	End With 
End Sub
Sub TGuitar.revert(ByVal string_number As Integer, ByVal fret_number As Integer) 
	'
	With This 
		Dim As TRect Ptr r = @._hotspots(string_number, fret_number)
		Dim As Integer w,h
		Dim As Any Ptr p  
		w = r->Width 
		h = r->height
		p = ImageCreate(w, h) 
		Get ._guitar_img, (r->x1, r->y1)-(r->x2, r->y2), p 
		Put .guitar_img, (r->x1, r->y1), p, PSet
		ImageDestroy p  
		Paint() 
	End With
End Sub
Sub TGuitar.draw_note(ByVal string_number As Integer, ByVal fret_number As Integer, ByVal clr As ULong = &HFFFFFFFF) 
	'
	With This 
		Dim As Integer x, y
		Dim As String * 2 note  
		x = .get_fret_center_x(fret_number) - 8 ' two chars per note
		If fret_number = 0 Then x -= 8
		y = .get_string_center_y(string_number) - 8 		
		note = ._strings(string_number).note(fret_number)  
		
		Draw String .guitar_img, (x,y), note, clr
		.paint() 
	End With   
End Sub
	
#EndIf 
'#Ifndef __sundry
	'#Include Once "sundry.bi"
'=======================================================================================================================================
Namespace Main_ 

	'========================================================================================================================================
	Type TGRect extends TRect
		Declare Sub draw_border(ByVal clr As ULong)
		Declare Sub draw_filled(ByVal clr As ULong)
		Declare Constructor()
		Declare Operator Let(ByRef rhs As TRect)   
	End Type
	'---------------------------------------------------------------------------------------------------------------------------------------
		Constructor TGRect():End Constructor
		'---------------------------------------------------------------------------------------------------------------------------------------
		Operator TGRect.Let(ByRef rhs As TRect)
			'
			Cast(TRect, This) = rhs '(rhs.x1, rhs.y1, rhs.x2, rhs.y2)
		End Operator
		'---------------------------------------------------------------------------------------------------------------------------------------
		Sub TGRect.draw_border(ByVal clr As ULong)
			'
			With This
				Line (.x1, .y1)-(.x2, .y2), clr, b
			End With
		End Sub
		Sub TGRect.draw_filled(ByVal clr As ULong)
			'
			With This
				Line (.x1, .y1)-(.x2, .y2), clr, bf
			End With
		End Sub
	'========================================================================================================================================
	Type TGMouse extends TMouse
		Declare Operator Cast() As TPoint 
	End Type
	'---------------------------------------------------------------------------------------------------------------------------------------
		Operator TGMouse.Cast() As TPoint 
			Return Type<TPoint>(this.x, this.y)
		End Operator
	'========================================================================================================================================
	Type TButton
		As TGRect hotspot
	End Type
	'========================================================================================================================================
	' graphics.bi declarations 
	Declare Sub init_exit_button()
	Declare Sub draw_guitar() 
	Declare Sub draw_info_bar() 
	Declare Sub update_info_bar()
	Declare Sub draw_shadow(	ByRef txt As Const String, ByVal x As Integer, ByVal y As Integer, _
							ByVal fore_clr As ULong, ByVal shadow_clr As ULong, ByVal depth As Integer = 1)
	Declare Sub draw_title() 
	Declare Sub show()
	'----------------------------------------------------------------------------------------------
	' game declarations 
	Declare Sub init() 
	Declare Sub main_loop()
	Declare Sub on_exit()
	'=======================================================================================================================================
	Dim Shared As TGuitar _guitar
	Static Shared As TButton exit_btn 
	'=======================================================================================================================================
	'#Include Once "status.bi"
'========================================================================================================================================
' Status.bi
'========================================================================================================================================
#Define __Status__
'========================================================================================================================================
Namespace Status_ 
	'========================================================================================================================================
	Type TStatusText 
		As String txt 
		As Integer x 
		As ULong clr
		Declare Constructor 
		Declare Constructor(ByRef text As Const String, ByVal left_x As Integer, ByVal text_color As ULong)   
	End Type
	'---------------------------------------------------------------------------------------------------------------------------------------
	 	Constructor TStatusText():End Constructor
	 	Constructor TStatusText(ByRef text As Const String, ByVal left_x As Integer, ByVal text_color As ULong)
	 		'
	 		With This 
	 			.txt = text
	 			.x = left_x 
	 			.clr = text_color 
	 		End With
	 	End Constructor
	'========================================================================================================================================
	Type TStatusButton extends TGRect
		As String Name  
		As Integer text_x 
		As Integer text_y
		As String txt 
		As Integer key_index
		As ULong fore_color  
		As ULong key_color  
		As ULong fill_color 
		As ULong border_color
		Declare Sub hilite()
		Declare Sub unhilite()  
		Declare Property enabled() As boolean
		Declare Property enabled(ByVal value As boolean)  
		Declare Operator Let(ByRef rhs As Const TRect)
		Declare Sub Draw()
		Declare Sub draw_grey()   
		Private: 
			As boolean _is_enabled 
	End Type
		Property TStatusButton.enabled() As boolean
			'
			Return this._is_enabled 
		End Property
		Property TStatusButton.enabled(ByVal value As boolean)
			'
			this._is_enabled = value 
		End Property
		'-------------------------------------------------------------------------------------------------------------------------------------
		Operator TStatusButton.Let(ByRef rhs As Const TRect) 
			Cast(TRect, This) = rhs  
		End Operator
		'-------------------------------------------------------------------------------------------------------------------------------------
		Sub TStatusButton.unhilite() 
			'
			this.draw_border(this.border_color) 
		End Sub
		Sub TStatusButton.hilite() 
			'
			this.draw_border(pal.WHITE) 
		End Sub
		Sub TStatusButton.draw_grey() 
			'
			With This 
				.draw_filled(.fill_color)
				.draw_border(.border_color)
			
				Dim As Integer hx = text_x + (8 * (.key_index - 1))
				Dim As String c = Mid(txt, .key_index, 1) 

				..Draw String (text_x, text_y), txt, pal.GRAY
				..Draw String (hx, text_y), c, pal.BROWN
			End With
		End Sub
		Sub TStatusButton.Draw()
			'
			With This
				If ._is_enabled = FALSE Then 
					.draw_grey() 
					Return 
				EndIf
				.draw_filled(.fill_color)
				.draw_border(.border_color)
			
				Dim As Integer hx = text_x + (8 * (.key_index - 1))
				Dim As String c = Mid(txt, .key_index, 1) 

				..Draw String (text_x, text_y), txt, .fore_color
				..Draw String (hx, text_y), c, .key_color
			End With 
		End Sub
	
	'========================================================================================================================================
	Declare Sub draw_text overload(ByRef stxt As Const TStatusText, ByVal wipe As boolean = TRUE) 
	Declare Sub draw_text(ByRef txt As Const String, ByVal x As Integer = -1, ByVal clr As ULong = pal.CLAY, ByVal wipe As boolean = TRUE ) 
	Declare Sub draw_status_bar() 
	Declare Sub init()
	Declare Function create_status_button(ByRef txt As Const String, ByVal x As Integer, ByVal key_index As Integer) As TGRect
	Declare Sub teststatus()
	'========================================================================================================================================
	Static Shared As TStatusText status_text	
	Static Shared As TStatusButton Ptr buttons(Any)  
	'========================================================================================================================================
	Sub teststatus()
		Line (0, STATUS_BAR_top)-Step(1000, 0), pal.GREEN
		Line (0, STATUS_BAR_BOTTOM)-Step(1000, 0), pal.GREEN
		
	End Sub

	Sub init()
		' 
		draw_status_bar() 
	End Sub
	Sub draw_text(ByRef stxt As Const TStatusText, ByVal wipe As boolean = TRUE) 
		'
		draw_text(stxt.txt, stxt.x, stxt.clr, wipe) 
	End Sub
	Sub draw_text(ByRef txt As Const String, ByVal x As Integer = -1, ByVal clr As ULong = pal.CLAY, ByVal wipe As boolean = TRUE ) 
		'
		Dim As Integer y = 240
		If wipe = TRUE Then 
			Line(54, 233)-step(860, 26), pal.BLACK, bf
			status_text = Type<TStatusText>(txt, x, clr)  
		EndIf  
		If x = 0 Then x = STATUS_BAR_LEFT 
		If x < 0 Then 
			x = (870 - (Len(txt) * 8)) \ 2 
			x += _guitar.left_x 
		EndIf
		Draw String (x, y), txt, clr
	End Sub
	Sub draw_status_bar() 
		'
		Dim As Integer l = 230
		Color , pal.BLUEGRAY
		Line (50,l)-Step(920,32), pal.DARK_BLUEGRAY, b
		Line (51,l+1)-Step(918,30), pal.DARK_BLUEGRAY, b
		Line (52,l+2)-Step(916,28), pal.DARK_BLUEGRAY, b
		
		'draw_text("123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789", 54)		 
	End Sub

	Function create_status_button(ByRef txt As Const String, ByVal x As Integer, ByVal key_index As Integer) As TGRect
		'
		'Dim As TGRect gr 
		'gr = Type<TRect>(x-4, STATUS_BAR_TOP-6, x + (8 * Len(txt)) + 4, STATUS_BAR_TOP + 18)
		'gr.draw_filled(pal.BLUEGRAY)
	
		'Dim As Integer hx = x + (8 * (key_index - 1))
		'Dim As String c = Mid(txt, key_index, 1) 
		'Draw String (x, STATUS_BAR_TOP), txt, pal.CYAN
		'Draw String (hx, STATUS_BAR_TOP), c, pal.RED
	
		'Return gr
		Dim As TGRect gr 
		
		Return gr 
		
	End Function
	Function create_button(ByRef txt As Const String, ByVal x As Integer, _
													ByRef id As const String="", ByVal key_index As Integer = 1, _
													ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) ByRef As Status_.TStatusButton
		'
		' lets keep track of these buttons 
		Dim As Integer n = UBound(Status_.buttons) 
		If n < 1 Then 
			n = 1
		Else 
			n += 1
		EndIf
		ReDim Preserve Status_.buttons(1 To n) 
		Status_.buttons(n) = New Status_.TStatusButton

		Dim As Status_.TStatusButton Ptr pB = Status_.buttons(n)  
		*pB = Type<TRect>(x-6, STATUS_BAR_TOP, x + (8 * Len(txt)) + 4, STATUS_BAR_BOTTOM)
		With *pB  
			.name = id 
			.text_x = x 
			.text_y = MENU_BAR_TOP + 6
			.txt = txt 
			.key_index = key_index 
			.fore_color = pal.CYAN 
			.border_color = pal.BLACK
			.fill_color = pal.BLUEGRAY
			.key_color = pal.RED
			.enabled = enabled 
			If show_me = TRUE Then
				.draw()
			EndIf
		End With

		Return *(Status_.buttons(n)) 
		
	End Function 


End Namespace


	'#Include Once "menubar.bi" 
'========================================================================================================================================
' MenuBar.bi
'========================================================================================================================================
#Define __MenuBar__ 
'========================================================================================================================================
Namespace MenuBar_
	'========================================================================================================================================
	Type TMenuButton extends TGRect
		As String Name  
		As Integer text_x 
		As Integer text_y
		As String txt 
		As Integer key_index
		As ULong fore_color  
		As ULong key_color  
		As ULong fill_color 
		As ULong border_color
		Declare Sub hilite()
		Declare Sub unhilite()  
		Declare Property enabled() As boolean
		Declare Property enabled(ByVal value As boolean)  
		Declare Property selected() As boolean
		Declare Property selected(ByVal value As boolean)  
		Declare Operator Let(ByRef rhs As Const TRect)
		Declare Sub Draw()
		Declare Sub draw_grey()
		Declare Sub draw_unselected()    
		Declare Sub draw_selected()
		Declare Sub toggle_selected() 
		Private: 
			As boolean _is_enabled
			As boolean _is_selected 
	End Type
	'-------------------------------------------------------------------------------------------------------------------------------------
		Property TMenuButton.enabled() As boolean
			'
			Return this._is_enabled 
		End Property
		Property TMenuButton.enabled(ByVal value As boolean)
			'
			this._is_enabled = value 
		End Property
		Property TMenuButton.selected() As boolean
			'
			Return this._is_selected 
		End Property
		Property TMenuButton.selected(ByVal value As boolean)
			'
			this._is_selected = value 
		End Property
		'-------------------------------------------------------------------------------------------------------------------------------------
		Operator TMenuButton.Let(ByRef rhs As Const TRect) 
			Cast(TRect, This) = rhs  
		End Operator
		'-------------------------------------------------------------------------------------------------------------------------------------
		Sub TMenuButton.unhilite() 
			'
			'this.draw_border(this.border_color)
			this.draw()  
		End Sub
		Sub TMenuButton.hilite() 
			'
			'this.draw_border(pal.WHITE)
			this.draw_selected() 
		End Sub
		Sub TMenuButton.toggle_selected()
			'
			With This 
				If ._is_selected = TRUE Then 
					._is_selected = FALSE 
					.draw_unselected()
				Else
					._is_selected = TRUE 
					.draw_selected() 
				EndIf
			End With
		End Sub
		Sub TMenuButton.draw_selected()
			'
			With This 
				Dim As ULong glowa = pal.BLUE, glow = pal.white, source = pal.WHITE	' pal.BLUE 
				Dim As ULong fcolor = pal.DARK_CYAN	' pal.DARK_BLUEGRAY

				.draw_filled(fcolor)
				.draw_border(.border_color)
			
				'Dim As Integer hx = text_x + (8 * (.key_index - 1))
				'Dim As String c = Mid(txt, .key_index, 1) 
				'..Draw String (text_x -2, text_y), txt, glowa 
				'..Draw String (text_x+2, text_y), txt, glowa 
				'..Draw String (text_x, text_y-2), txt, glowa
				'..Draw String (text_x, text_y+2), txt, glowa 

				'..Draw String (text_x -1, text_y), txt, glow 
				'..Draw String (text_x+1, text_y), txt, glow 
				'..Draw String (text_x, text_y-1), txt, glow 
				'..Draw String (text_x, text_y+1), txt, glow 
				
				..Draw String (text_x, text_y), txt, source 
				'..Draw String (hx, text_y), c, pal.BROWN
				
			End With
		End Sub
		Sub TMenuButton.draw_unselected() 
			'
			With This 
				.draw_filled(.fill_color)
				.draw_border(.border_color)
			
				'Dim As Integer hx = text_x + (8 * (.key_index - 1))
				'Dim As String c = Mid(txt, .key_index, 1) 

				..Draw String (text_x, text_y), txt, pal.DARK_CYAN	' pal.CYAN 
				'..Draw String (hx, text_y), c, pal.BROWN
			End With
		End Sub
		Sub TMenuButton.draw_grey() 
			'
			With This 
				.draw_filled(.fill_color)
				.draw_border(.border_color)
			
				Dim As Integer hx = text_x + (8 * (.key_index - 1))
				Dim As String c = Mid(txt, .key_index, 1) 

				..Draw String (text_x, text_y), txt, pal.GRAY
				..Draw String (hx, text_y), c, pal.BROWN
			End With
		End Sub
		Sub TMenuButton.Draw()
			'
			With This
				If ._is_enabled = FALSE Then 
					.draw_grey() 
					Return 
				EndIf
				.draw_filled(.fill_color)
				.draw_border(.border_color)
			
				Dim As Integer hx = text_x + (8 * (.key_index - 1))
				Dim As String c = Mid(txt, .key_index, 1) 

				..Draw String (text_x, text_y), txt, .fore_color
				..Draw String (hx, text_y), c, .key_color
			End With 
		End Sub
	'========================================================================================================================================
	Declare Function create_menu_button(ByRef txt As Const String, ByVal x As Integer, _
													ByRef id As const String="", ByVal key_index As Integer = 1, _
													ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) ByRef As MenuBar_.TMenuButton 
	Declare Function get_button_by_name(ByRef id As Const String) ByRef As MenuBar_.TMenuButton
	Declare Sub remove_button_by_name(ByRef id As Const String)
	Declare Sub destroy()   
	Declare Sub draw_back() 
	'========================================================================================================================================
	Static Shared As TMenuButton Ptr buttons(Any) 
	'========================================================================================================================================
	Function create_menu_button(ByRef txt As Const String, ByVal x As Integer, _
													ByRef id As const String="", ByVal key_index As Integer = 1, _
													ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) ByRef As MenuBar_.TMenuButton
		'
		' lets keep track of these buttons 
		Dim As Integer n = UBound(MenuBar_.buttons) 
		If n < 1 Then 
			n = 1
		Else 
			n += 1
		EndIf
		ReDim Preserve MenuBar_.buttons(1 To n) 
		MenuBar_.buttons(n) = New TMenuButton

		Dim As TMenuButton Ptr pB = MenuBar_.buttons(n)  
		*pB = Type<TRect>(x-6, MENU_BAR_TOP, x + (8 * Len(txt)) + 4, MENU_BAR_BOTTOM)
		With *pB  
			.name = id 
			.text_x = x 
			.text_y = MENU_BAR_TOP + 6
			.txt = txt 
			.key_index = key_index 
			.fore_color = pal.CYAN 
			.border_color = pal.BLACK
			.fill_color = pal.BLUEGRAY
			.key_color = pal.RED
			.enabled = enabled 
			If show_me = TRUE Then
				.draw()
			EndIf
		End With

		Return *(MenuBar_.buttons(n)) 
		
	End Function 
	Function get_button_by_name(ByRef id As Const String) ByRef As MenuBar_.TMenuButton
		'
		For i As Integer = 1 To UBound(MenuBar_.buttons) 
			If MenuBar_.buttons(i)->Name = id Then Return *(MenuBar_.buttons(i))  
		Next
		Return *Cast(MenuBar_.TMenuButton Ptr, 0) 
	End Function
	Sub remove_button_by_name(ByRef id As Const String)
		'
		Dim As Integer l, u, n  
		l = LBound(MenuBar_.buttons): u =  UBound(MenuBar_.buttons)
		Dim As Any Ptr p(l To u)
		For i As Integer = l To u
			p(i) = MenuBar_.buttons(i)
			If id = MenuBar_.buttons(i)->name Then
				n = i 	' index used to remove the item from the array later 
				
				' this section frees the memory and draws over the button 
				Dim As TMenuButton Ptr pB = MenuBar_.buttons(i) 
				pB->draw_filled(pB->fill_color)
				Line(pB->x1, pB->y1)-(pB->x2,pB->y1), pal.BLACK
				Line(pB->x1, pB->y2)-(pB->x2,pB->y2), pal.BLACK
				Delete pB
				MenuBar_.buttons(i) = 0
			EndIf
		Next

		' this section removes the item from the array via the index 
		remove_array_element(n, p())
		u = UBound(p)
		ReDim Preserve MenuBar_.buttons(l To u)  
		For i As Integer = l To u
			MenuBar_.buttons(i) = Cast(TMenuButton Ptr, p(i))
		Next
	End Sub
	Sub destroy() Destructor  
		For i As Integer = 1 To UBound(MenuBar_.buttons) 
			If MenuBar_.buttons(i) <> 0 Then 
				Delete MenuBar_.buttons(i)
				MenuBar_.buttons(i) = 0 
			EndIf
		Next
		ReDim MenuBar_.buttons(0 To 0)
	End Sub
	Sub draw_back() 
		' todo: change this so that it uses member value not global constants 
		Dim As Integer y = 32 
		Line (220, y-4)-Step(620,24), pal.BLUEGRAY, bf
		Line(MENU_BAR_LEFT, MENU_BAR_TOP)-(MENU_BAR_LEFT+5, MENU_BAR_BOTTOM), pal.DARK_BLUEGRAY, bf
		Line(MENU_BAR_RIGHT, MENU_BAR_TOP)-(MENU_BAR_RIGHT - 5, MENU_BAR_BOTTOM), pal.DARK_BLUEGRAY, bf  

	End Sub
End Namespace 	
	'#Include Once "notebar.bi"
'========================================================================================================================================
' NoteBar.bi 
'========================================================================================================================================
#Define __NoteBar__
'========================================================================================================================================
Namespace NoteBar_
	'========================================================================================================================================
	Declare Function create_note_bar(ByVal x As Integer) As boolean
	Declare Sub Draw(ByVal grey As boolean = TRUE)
	Declare Sub destroy() 
	Declare Sub remove()  
	Declare Sub set_selected(ByVal selected As boolean)
	Declare Function get_button_by_name(ByRef id As Const String) ByRef As MenuBar_.TMenuButton
	'========================================================================================================================================
	Static Shared As MenuBar_.TMenuButton Ptr buttons(1 To 12)
	'========================================================================================================================================
	Sub set_selected(ByVal selected As boolean)
		'
		For i As Integer = 1 To 12 
			NoteBar_.buttons(i)->selected = selected
			If selected = TRUE Then
				NoteBar_.buttons(i)->draw_selected()
			Else
				NoteBar_.buttons(i)->draw_unselected()
			EndIf
		Next
	End Sub
	Function get_button_by_name(ByRef id As Const String) ByRef As MenuBar_.TMenuButton
		'
		For i As Integer = 1 To 12
			If LCase(id) = LCase(Trim(NoteBar_.buttons(i)->name)) Then 
				Return *buttons(i) 
			EndIf
		Next
	End Function

	Function create_note_bar(ByVal x As Integer) As boolean  
		'
		For i As Integer = 1 To 12 
			Dim As String s = Trim(Notes_.notes(i)) 
			s = " " & s & " "
			NoteBar_.buttons(i) = New MenuBar_.TMenuButton			
			*(NoteBar_.buttons(i)) = MenuBar_.create_menu_button(s, x, s,,,FALSE)   
  			x = NoteBar_.buttons(i)->x2 + 6 
		Next
		Return FALSE 
	End Function
	Sub Draw(ByVal selected As boolean = TRUE)
		'
		For i As Integer = 1 To 12 
			If selected = TRUE Then 
  				NoteBar_.buttons(i)->Draw_selected() 
			Else 
  				NoteBar_.buttons(i)->draw_unselected()
			EndIf 
		Next
	End Sub
	Sub remove()
		Dim As MenuBar_.TMenuButton Ptr pBl, pBr 
		pBl = NoteBar_.buttons(1)
		pBr = NoteBar_.buttons(12) 
		Line(pBl->x1+1, pBl->y1+1)-(pBr->x2, pBr->y2-1), pal.BLUEGRAY, bf 
	End Sub
	Sub destroy() Destructor  
		'
		For i As Integer = 1 To 12 
			If NoteBar_.buttons(i) <> 0 Then  
				Delete NoteBar_.buttons(i) 
				NoteBar_.buttons(i) = 0 
			EndIf
		Next

	End Sub
End Namespace 		 	
	'#Include Once "graphics.bi"
'========================================================================================================================================
' Graphics.bi
'========================================================================================================================================
'========================================================================================================================================
Sub draw_guitar() 
	' 
	__dim_guitar_ptr 
	Put(GUITAR_LEFT_X, GUITAR_TOP_Y), *pGtr, PSet 
End Sub
Sub Clear_status_bar(ByVal x1 As Integer = -1, ByVal x2 As Integer = STATUS_BAR_RIGHT + 1)
	If x1 < 0 Then x1 = STATUS_BAR_LEFT - 4  
	Line (x1, STATUS_BAR_TOP)-(x2, 259), pal.BLACK, bf
End Sub
Sub draw_info_bar() 
	' 
	Dim As Integer l = 42 
	Dim As Integer x = 328,y = 32
	
	'set  
	Color pal.SAND
	Draw String (x+1, y+1), "Set:", pal.DARK_BLUEGRAY
	Draw String (x, y), "Set:", pal.CLAY

	'round 
	l += 8: x += 64 
	Draw String (x, y), "Round:", pal.CLAY  

	'course 
	l += 10: x += 80 
	Draw String (x,y), "Course: ", pal.CLAY

	'score
	l += 12: x += 88 
	Draw String (x,y), "Score:", pal.CLAY

	'skill 
	l += 14: x += 120
	Draw String (x,y), "Skill:", pal.CLAY
	Locate 3, l + 7:Print "Accomplished"
	
End Sub
Sub update_info_bar()
	' todo: update this
	'Dim As Integer l = 42
	'
	'' set
	'Locate 3, l + 5:Print Str(pGame->set_number)
	'' round
	'l += 8 
	'Locate 3, l + 7:Print Str(pGame->round_number)
	''course
	'l += 10 
	'Locate 3, l + 8:Print str(pGame->course_number)
	''score
	'l += 12 
	'Locate 3, l + 6:Print Using "\     \"; zero_prefix_number(pGame->player.score)
	''skill 
	'l += 14
	'Locate 3, l + 7:Print Using "\          \";get_skill_level() 
	'
	'draw_status_text(pGame->state) 		
End Sub
Sub draw_shadow(	ByRef txt As Const String, ByVal x As Integer, ByVal y As Integer, _
						ByVal fore_clr As ULong, ByVal shadow_clr As ULong, ByVal depth As Integer = 1)
	'
	For i As Integer = depth To 1 Step -1 
		Draw String (x + i, y + i), txt, shadow_clr 
	Next
	Draw String (x, y), txt, fore_clr
End Sub
Sub draw_title() 
	'
	Dim As Integer l = _guitar.left_x, y = 32
	draw_shadow("FretBoard-Aide", l +14, y, pal.CYAN, pal.DARK_BLUEGRAY, 2) 

	'Draw String (l + 808, y+2),"Sancho 0.01a", pal.DARK_BLUEGRAY  
	'Draw String (l + 807, y+1),"Sancho 0.01a", pal.DARK_BLUEGRAY
	'Draw String (l + 806, y),"Sancho 0.01a", pal.CYAN
	draw_shadow("Sancho 0.01", l +806, y, pal.CYAN, pal.DARK_BLUEGRAY, 2)   
	Line (50,y - 8) -Step(920,32), pal.DARK_BLUEGRAY, b
	Line (51,y - 7)-Step(918,30), pal.DARK_BLUEGRAY, b
	Line (52,y - 6)-Step(916,28), pal.DARK_BLUEGRAY, b
End Sub
'-------------------------------------------------------------------------------------------------------------------------------------------
	'#Include Once "NoteBrowser.bi"
'========================================================================================================================================
' NoteBrowser.bi
'========================================================================================================================================
#Define __NoteBrowser__
'========================================================================================================================================
Namespace NoteBrowser_
	Static Shared As String notes(any)
	Static Shared As Integer note_count
	'Static Shared As MenuBar_.TMenuButton Ptr add_btn 
	Static Shared As MenuBar_.TMenuButton Ptr clear_btn 
	'========================================================================================================================================
	Declare Function main_loop() As boolean 
	Declare Sub add_note(ByRef note As Const String) 
	Declare Sub remove_note(ByRef note As Const String) 
	Declare Sub draw_status() 
	Declare Sub parse_input(ByRef txt As Const String) 	
	Declare Sub draw_notes()
	Declare Sub clear_notes()
	Declare Sub clear_status()
	Declare Sub remove_buttons() 
	Declare Sub on_exit()
	Declare Sub destroy() 		'Destructor 
	Declare Sub init()  
	Declare Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
	'========================================================================================================================================
	Sub remove_buttons() 
		'MenuBar_.remove_button_by_name("add")
		MenuBar_.remove_button_by_name("clr") 
	End Sub
	Sub clear_status() 
		'
		Main_.Clear_status_bar(-1, 661)
	End Sub
	Sub draw_status() 
		'
		Dim As String txt = "Notes: " & string_array_to_string(notes()) 
		Status_.draw_text(txt, 0,, FALSE)
	
	End Sub
	Sub init()  
		'
		Dim As Integer x
	
		Status_.draw_text("Note Browser")

		' grey out the main menu 
		Dim As MenuBar_.TMenuButton Ptr mb = @(MenuBar_.get_button_by_name("mode"))
		mb->enabled = FALSE
		mb->Draw()   

		mb = @(MenuBar_.get_button_by_name("file"))
		mb->enabled = FALSE 
		mb->draw()
		mb = @(MenuBar_.get_button_by_name("help"))
		mb->enabled = FALSE 		
		mb->draw()

		' draw the notebar grey
		x = mb->x2 + 6
		NoteBar_.create_note_bar(x) 
		NoteBar_.Draw(FALSE)
		
		mb = @(MenuBar_.get_button_by_name(" G# "))
		x = mb->x2 + 6

		NoteBrowser_.clear_btn = New MenuBar_.TMenuButton
		*NoteBrowser_.clear_btn = MenuBar_.create_menu_button("Clr", x,"clr",3)

	End Sub 
	Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
		'
		For i As Integer = 1 To 12
			Dim As MenuBar_.TMenuButton Ptr pB = NoteBar_.buttons(i) 
			If pB->is_point_in_rect(pnt) = TRUE Then 
				pB->toggle_selected()	' draw_selected()
				If pB->selected = TRUE Then 
					key = "+" & Trim(pB->Name)
					Return
				Else 
					key = "-" & Trim(pB->Name) 
					Return 
				EndIf
			EndIf
		Next
		
		If NoteBrowser_.clear_btn->is_point_in_rect(pnt) Then 
			key = "r"
			Return 
		EndIf
		key = ""
	End Sub
	Function main_loop() As boolean 
		'
		Dim As String key
		Dim As boolean ok_to_exit = FALSE  
		Dim As TGMouse mouse 
		Do 
			Do
				mouse.poll() 
				If mouse.is_button_released(mbLeft) Then
					poll_buttons(Cast(TPoint, mouse), key) 
					
					'If NoteBrowser_.add_btn->is_point_in_rect(Cast(TPoint, mouse)) Then  
					'	' 
					'	key = "a"
					'ElseIf NoteBrowser_.clear_btn->is_point_in_rect(Cast(TPoint, mouse)) Then 
					'	key = "c"
					'EndIf
				EndIf
				If key = "" Then 
					key = InKey()
				EndIf 
				Sleep 15 
			Loop While key = ""
			Select Case key
				Case "a" To "g"
					Dim As MenuBar_.TMenuButton Ptr pB = @(NoteBar_.get_button_by_name(key)) 
					pB->toggle_selected()
					If pB->selected = TRUE Then 
						key = "+" & Trim(pB->Name)
					Else 
						key = "-" & Trim(pB->Name) 
					EndIf
				Case "A" To "G"
					Dim As MenuBar_.TMenuButton Ptr pB = @(NoteBar_.get_button_by_name(key & "#")) 
					pB->toggle_selected()
					If pB->selected = TRUE Then 
						key = "+" & Trim(pB->Name)
					Else 
						key = "-" & Trim(pB->Name) 
					EndIf
			End Select 
			If Left(key, 1) = "+" Then
				' add note
				NoteBrowser_.add_note(Mid(key, 2)) 
				key = ""
			ElseIf Left(key, 1) = "-" Then 
				' remove note
				NoteBrowser_.remove_note(Mid(key, 2)) 
				key = "" 
			EndIf
			Select Case key
				Case "r"
					clear_notes() 
					key = ""
				Case Chr(27)
					Exit Do 
				Case Else 
					key = ""
			End Select
			
		Loop While ok_to_exit = FALSE 
		
		on_exit()
		
		Return FALSE 
	End Function
	Sub on_exit()
		'
		NoteBrowser_.remove_buttons() 
		NoteBrowser_.clear_notes()

		Dim As MenuBar_.TMenuButton Ptr mb = @(MenuBar_.get_button_by_name("mode")) 
		mb->draw()
		mb = @(MenuBar_.get_button_by_name("file"))
		mb->draw()
		mb = @(MenuBar_.get_button_by_name("help"))		
		mb->draw()

		NoteBar_.remove()
		NoteBar_.destroy() 
		NoteBrowser_.destroy() 
	End Sub
	Sub destroy() Destructor 
		'If NoteBrowser_.add_btn <> 0 Then Delete NoteBrowser_.add_btn
		'NoteBrowser_.add_btn = 0 
		If NoteBrowser_.clear_btn <> 0 Then Delete NoteBrowser_.clear_btn
		NoteBrowser_.clear_btn = 0  
	End Sub
	Sub clear_notes() 
		'
		Main_._guitar.revert()
		ReDim NoteBrowser_.notes(0 To 0)		' resize the array to 1 element because this is as low as I can go  							
		NoteBrowser_.note_count = 0
		NoteBar_.set_selected(FALSE) 
		'NoteBrowser_.clear_status() 
		'NoteBrowser_.draw_status()
	End Sub
	Sub add_note(ByRef note As Const String) 
		'
		If Notes_._get_note_index(note) <> 0 Then		' if this is a valid note  
			If is_value_in_array(note, NoteBrowser_.notes()) = FALSE Then 	' if this note isn't already in the list
				 NoteBrowser_.note_count += 1
				 ReDim Preserve NoteBrowser_.notes(1 To NoteBrowser_.note_count)
				 NoteBrowser_.notes(NoteBrowser_.note_count) = UCase(note)  
			EndIf 
		EndIf
		NoteBrowser_.draw_notes()	
	End Sub
	Sub remove_note(ByRef note As Const String) 
		'
		If Notes_._get_note_index(note) <> 0 Then		' if this is a valid note  
			If is_value_in_array(note, NoteBrowser_.notes()) = TRUE Then 	' if this note is in the list
				 NoteBrowser_.note_count -= 1
				 remove_array_element(Cast(String, note), NoteBrowser_.notes()) 
			EndIf 
		EndIf
		Main_._guitar.revert()
		NoteBrowser_.draw_notes()	
		
	End Sub
	Sub draw_notes() 
		'
		For i As Integer = 1 To NoteBrowser_.note_count
			Main_._guitar.draw_note(NoteBrowser_.notes(i)) 
		Next
	End Sub
	
End Namespace
	'#Include Once "scalebrowser.bi"
'========================================================================================================================================
' ScaleBrowser.bi
'========================================================================================================================================
#Define __ScaleBrowser__ 
'========================================================================================================================================
Namespace ScaleBrowser_ 
	' major wwhwwwh 
	' minor whwwhww 
	Dim Shared As String notes(any)
	Dim Shared As Integer note_count
	Static Shared As MenuBar_.TMenuButton Ptr root_btn 
	Static Shared As MenuBar_.TMenuButton Ptr major_btn 
	Static Shared As MenuBar_.TMenuButton Ptr minor_btn 
	'========================================================================================================================================
	Declare Sub init()  

	Declare Function main_loop() As boolean 
	Declare Sub browse_major()
	Declare Sub browse_minor() 
	Declare Sub set_root_note()  
	Declare Sub draw_status() 
	Declare Sub parse_input(ByRef txt As Const String) 	
	Declare Sub draw_notes()
	Declare Sub clear_notes()
	Declare Sub clear_status()
	Declare Sub remove_buttons() 
	Declare Sub on_exit()
	Declare Sub destroy() 		'Destructor 
	'========================================================================================================================================
	Sub remove_buttons() 
		MenuBar_.remove_button_by_name("root")
		MenuBar_.remove_button_by_name("major") 
		MenuBar_.remove_button_by_name("minor") 
	End Sub
	Sub clear_status() 
		'
		Main_.Clear_status_bar(-1, 661)
	End Sub
	Sub draw_status() 
		'
		Dim As String txt = "Notes: " & string_array_to_string(notes()) 
		Status_.draw_text(txt, 0,, FALSE)
	
	End Sub
	Sub init()  
		'
		Dim As Integer x
	
		'Dim As String s = "Notes: A  A# B  C  C# D  D# E  F  F# G  G#" & string_array_to_string(notes())
		Dim As String s = "Notes: " & string_array_to_string(notes()) 
		Status_.draw_text(s, 0)
	
		Dim As MenuBar_.TMenuButton mb = MenuBar_.get_button_by_name("mode") 
		mb.draw_grey()
		mb = MenuBar_.get_button_by_name("file")
		mb.draw_grey()
		mb = MenuBar_.get_button_by_name("help")		
		mb.draw_grey()

		x = mb.x2 + 6
		ScaleBrowser_.root_btn = New MenuBar_.TMenuButton
		*ScaleBrowser_.root_btn = MenuBar_.create_menu_button("Root", x,"root")

		'x = (MenuBar_.get_button_by_name("major")).x2 + 6
		x = ScaleBrowser_.root_btn->x2 + 6  
		ScaleBrowser_.major_btn = New MenuBar_.TMenuButton
		*ScaleBrowser_.major_btn = MenuBar_.create_menu_button("Major", x,"major",2)

		x = ScaleBrowser_.major_btn->x2 + 6  
		ScaleBrowser_.minor_btn = New MenuBar_.TMenuButton
		*ScaleBrowser_.minor_btn = MenuBar_.create_menu_button("Minor", x,"minor")

	End Sub 
	Function main_loop() As boolean 
		'
		Dim As String key
		Dim As boolean ok_to_exit = FALSE  
		Dim As TGMouse mouse 
		Do 
			Do
				mouse.poll() 
				If mouse.is_button_released(mbLeft) Then 
					If root_btn->is_point_in_rect(Cast(TPoint, mouse)) Then 
						' 
						key = "r"
					ElseIf major_btn->is_point_in_rect(Cast(TPoint, mouse)) Then 
						key = "a"
					ElseIf minor_btn->is_point_in_rect(Cast(TPoint, mouse)) Then
						key = "m"
					EndIf
				EndIf
				If key = "" Then 
					key = InKey()
				EndIf 
				Sleep 15 
			Loop While key = "" 
			Select Case key 
				Case "a"
					browse_major() 
					key = ""
					draw_status() 
				Case "r"
					set_root_note()  
					key = ""
				Case "m"
					browse_minor() 
					key = ""
				Case Chr(27)
					Exit Do 
				Case Else 
					key = ""
			End Select
		Loop While ok_to_exit = FALSE
		
		on_exit() 
		
		Return FALSE 
	End Function
	Sub clear_notes() 
		'
		Main_._guitar.revert()
		ReDim ScaleBrowser_.notes(0 To 0)		' resize the array to 1 element because this is as low as I can go  							
		ScaleBrowser_.note_count = 0
		ScaleBrowser_.clear_status() 
		ScaleBrowser_.draw_status()
	End Sub
	Sub browse_major() 
		'
	'	' clear some text off the status bar without killing the buttons 
	'	'Dim As String s = "Notes: A  A# B  C  C# D  D# E  F  F# G  G#"
	'	'Status_.draw_text(  "                                          ", 0, ,FALSE)
	'	Clear_status_bar(-1, 661)
	'	Status_.draw_text("Enter notes:", 0,,FALSE) 
	'	Dim As TRect r = TRect(STATUS_BAR_LEFT + 106, 241, STATUS_BAR_LEFT + 400, 256) 
	'	Dim As TEdit edit = TEdit(r, pal.WHITE, pal.BLACK)
	'	edit.Paint() 
	'	edit.set_focus()
	'	edit.hide() 
	''Line (STATUS_BAR_RIGHT, 0)-Step(0,300), pal.GREEN
	'	ScaleBrowser_.clear_browser_status() 
	'	Dim As String txt = edit._text	
	'	If txt = "" Then Return 
	'	ScaleBrowser_.parse_input(txt) 	
	'	ScaleBrowser_.draw_notes()	
	End Sub
	Sub browse_minor()
		'
	End Sub
	Sub set_root_note()
		'
	End Sub
	'Sub parse_input(ByRef txt As Const String) 
	'	'
	'	Dim As String s(Any), t = txt
	'	Dim As Integer n = Split_tok_r(t, ",", s())
	'	If n < 1 Then Return			' if there are no notes then exit 
	'	For i As Integer = 1 To n 
	'		If TNotes._get_note_index(s(i)) <> 0 Then		' if this is a valid note  
	'			If is_value_in_array(s(i), ScaleBrowser_.notes()) = FALSE Then 	' if this note isn't already in the list
	'				 ScaleBrowser_.note_count += 1
	'				 ReDim Preserve ScaleBrowser_.notes(1 To ScaleBrowser_.note_count)
	'				 ScaleBrowser_.notes(ScaleBrowser_.note_count) = UCase(s(i))  
	'			EndIf 
	'		EndIf
	'	Next
	'End Sub
	Sub draw_notes() 
		'
		For i As Integer = 1 To ScaleBrowser_.note_count
			Main_._guitar.draw_note(ScaleBrowser_.notes(i)) 
		Next
	End Sub
	Sub destroy() Destructor 
		If ScaleBrowser_.root_btn <> 0 Then Delete ScaleBrowser_.root_btn
		ScaleBrowser_.root_btn = 0 
		If ScaleBrowser_.major_btn <> 0 Then Delete ScaleBrowser_.major_btn
		ScaleBrowser_.major_btn = 0  
		If ScaleBrowser_.minor_btn <> 0 Then Delete ScaleBrowser_.minor_btn
		ScaleBrowser_.minor_btn = 0  
	End Sub
	Sub on_exit()
		'
		ScaleBrowser_.remove_buttons() 
		ScaleBrowser_.clear_notes()

		Dim As MenuBar_.TMenuButton mb = MenuBar_.get_button_by_name("mode") 
		mb.draw()
		mb = MenuBar_.get_button_by_name("file")
		mb.draw()
		mb = MenuBar_.get_button_by_name("help")		
		mb.draw()
		destroy() 
	End Sub
	
End Namespace
	'#Include Once "ModeMenu.bi"
'========================================================================================================================================
' ModeMenu.bi
'========================================================================================================================================
#Define __ModeMenu__
'========================================================================================================================================
Namespace ModeMenu_
	'========================================================================================================================================
	Declare Function show(ByRef parent_menu As TGrect) As boolean 
	'Declare Function create_status_button(ByRef txt As Const String, ByVal x As Integer, ByVal key_index As Integer) As TGRect
	Declare Function note_browser() As boolean
 	Declare Function scale_browser() As boolean 
	Declare Sub destroy() 
	Declare Function create_hotspot(ByRef txt As Const String, ByVal x As Integer, ByVal y As Integer, _
									ByVal bounds As TRect, ByVal key_index As Integer = 1, ByVal clr As ULong = pal.RED) As TGRect
	'========================================================================================================================================
	Private Function show(ByRef parent_menu As TGrect) As boolean 
		'
	#Macro __HIDE_ACTION_MENU__()
		' remove menu and replace background
		Put (xx,yy), restore_img, PSet 
		parent_menu.draw_border(pal.BLACK)
	#EndMacro
		' 
		Dim As boolean ret_val 
		Dim As Integer x, y 
		Dim As Integer yy, xx 
		Dim As TGRect hotspots(1 To 5)
		Dim As Any Ptr restore_img  
	
		' 
		x = parent_menu.x1 
		y = parent_menu.y2 + 2 
		'draw menu
		yy = y:xx=x
	
		restore_img = ImageCreate(129, 55,,32)
		Get  (xx,yy)-Step(128, 54), restore_img 
	
		Line (x,y)-Step(128, 54), pal.BLUEGRAY, bf
	
		x+=8: y+=4
		hotspots(1) = create_hotspot("Note Browser", x, y, Type<TRect>(x-8, y-4, x+88, y+13))  
	
		y += 16
		hotspots(2) = create_hotspot("Scale Browser", x, y, Type<TRect>(x-8, y-4, x+88, y+13), 5)  
	
		y += 16  
		hotspots(3) = create_hotspot("Exit", x, y, Type<TRect>(x-8, y-1, x+88, y+13))  
		
		ret_val = TRUE 	
		Dim As String key 
		Dim As TGMouse mouse 
		Do 
			mouse.poll() 
			If mouse.is_button_released(mbLeft) Then 
				' button click
				Dim As TPoint p = Cast(TPoint, mouse) 
				If hotspots(1).is_point_in_rect(p) = TRUE Then				' note browser  
					key = "n"
				ElseIf hotspots(2).is_point_in_rect(p) = TRUE Then 		' scale browser 
					key = "s" 
				ElseIf hotspots(3).is_point_in_rect(p) = TRUE Then 		' scale browser 
					key = "x" 
				Else
					key = ""
				EndIf
			EndIf
			If key="" Then 
				key = InKey()
			EndIf
			Sleep 15, 1
		Loop While key = ""
		Select Case key
			Case "n" 			' show note browser
				__HIDE_ACTION_MENU__()
				note_browser()
				'key = ""
			Case "s" 			' scale browser 
				__HIDE_ACTION_MENU__()
				scale_browser()
			Case "x"
				ret_val = FALSE 
				'key = ""
		End Select
		
		__HIDE_ACTION_MENU__()
		Status_.draw_text("Main Menu") 
	
		ImageDestroy(restore_img) 
		restore_img = 0
		Return ret_val 
	End Function
	
	Private Function create_hotspot(ByRef txt As Const String, ByVal x As Integer, ByVal y As Integer, _
									ByVal bounds As TRect, ByVal key_index As Integer = 1, ByVal clr As ULong = pal.RED) As TGRect
		'
		Dim As TGRect gr 
		gr = Type<TRect>(bounds.x1, bounds.y1, bounds.x2, bounds.y2)
		'gr.draw_filled(pal.BLUEGRAY)
	
		Dim As Integer hx = x + (8 * (key_index - 1))
		Dim As String c = Mid(txt, key_index, 1) 
		Draw String (x, y), txt, pal.CYAN
		Draw String (hx, y), c, pal.RED
	
		Return gr
		'Dim As TRect r = TRect(x-2, STATUS_BAR_TOP, x + 8, STATUS_BAR_TOP + 16)
		'Dim As TRect r = TRect(x-2, y, x + 8, STATUS_BAR_TOP + 16)
		'Draw String (x, STATUS_BAR_TOP), txt, clr
		'Draw String (x, y), txt, clr   
		'Return r 
	End Function
	Private Function note_browser() As boolean
		'
		NoteBrowser_.init()
		NoteBrowser_.main_loop()
		Return FALSE  
	End Function
	Private Function scale_browser() As boolean 
		ScaleBrowser_.init() 
		ScaleBrowser_.main_loop()
		Return FALSE 
	End Function
	Private Sub destroy() Destructor
		'
	End Sub
End Namespace 	
	'#Include Once "mainmenu.bi"
'========================================================================================================================================
' MainMenu.bi
'========================================================================================================================================
#Define __MainMenu__ 
'========================================================================================================================================
Namespace MainMenu_
'========================================================================================================================================
	'========================================================================================================================================
	Declare Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
	Declare Sub	show()
	Declare Sub init() 
	'========================================================================================================================================
'---------------------------------------------------------    
#Define __mode MainMenu_.buttons(1)
#Define __file MainMenu_.buttons(2)
#Define __help MainMenu_.buttons(3) 
'---------------------------------------------------------    
 
	Static Shared As MenuBar_.TMenuButton Ptr buttons(Any) 
	'Static Shared As MenuBar_.TMenuButton menu_btn(1 To 3)  
	'========================================================================================================================================
	Sub init()  
		'
		Dim As Integer x
	
		ReDim MainMenu_.buttons(1 To 3) 
		
		x = MENU_BAR_LEFT
		'x = mb.x2 + 6
		__mode = New MenuBar_.TMenuButton
		*(__mode) = MenuBar_.create_menu_button("Main", x,"mode")
		__mode->enabled = TRUE 

		'x = (MenuBar_.get_button_by_name("add")).x2 + 6
		x = (__mode)->x2 + 6
		__file = New MenuBar_.TMenuButton
		*(__file) = MenuBar_.create_menu_button("File", x,"file")
		__file->enabled = FALSE 

		x = (__file)->x2 + 6
		__help = New MenuBar_.TMenuButton
		*(__help) = MenuBar_.create_menu_button("Help", x,"help")
		__help->enabled = FALSE
	End Sub 

	Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
		'
		' exit button 
		If Main_.exit_btn.hotspot.is_point_in_rect(pnt) Then 
			key = "x"
			Return 
		EndIf
		' main button
		If __mode->is_point_in_rect(pnt) Then
			If __mode->enabled = TRUE Then  
				key = "m"
			EndIf 
			Return
		ElseIf __file->is_point_in_rect(pnt) Then 
			If __file->enabled = TRUE Then 
				key = "f"
			EndIf
		ElseIf __help->is_point_in_rect(pnt) Then 
			If __help->enabled = TRUE Then 
				key = "h"
			EndIf
		EndIf
	End Sub
	Sub show()
		'
		MenuBar_.draw_back()  
		__mode->draw() 
		__file->draw_grey() 
		__help->draw_grey() 

		Dim As String key
		Dim As TGMouse mouse 
		Status_.draw_text("Main Menu")
		Do
			mouse.poll()
			If mouse.is_button_released(mbLeft) Then 
				MainMenu_.poll_buttons(mouse, key)
			EndIf 
			If key = "" Then 
				key = InKey()
			EndIf
			Select Case key 
				Case "m"
					__mode->hilite() 
					If ModeMenu_.show(*(__mode)) = FALSE Then Exit Do 
					__mode->unhilite() 
					key=""
				Case "f"
					? "file menu not handled"
					Sleep
					key=""
				Case "h"
					?"help not handled"
					Sleep 
					key=""
				Case "x"
					Exit Do 
				Case Chr(27) 
				Case Else 
					key = ""
				'Case "x", Chr(27)
				'	Dim As TStatusText s = status_text 
				'	If double_check_exit() = TRUE Then Exit Do
				'	key = ""
				'	draw_status_text(s)  
			End Select
			
			Sleep 15, 1
		Loop While key<>Chr(27) 

	End Sub
	Sub destroy() Destructor 
		'
		If __mode <> 0 Then 
			Delete __mode
			__mode = 0 
		EndIf
		If __file <> 0 Then 
			Delete __file 
			__file = 0
		EndIf
		If __help <> 0 Then 
			Delete __help
			__help = 0 
		EndIf
	End Sub

	
End Namespace 	
	'=======================================================================================================================================
	Sub init()
		'
		Cls 
		__dim_guitar_ptr
		
		pGtr->init(GUITAR_LEFT_X, GUITAR_TOP_Y, GUITAR_NECK_WIDTH, GUITAR_FRET_COUNT, SCALE_LENGTH, GUITAR_NECK_LENGTH, GUITAR_NUT_WIDTH)

		draw_title()
		Status_.init() 
		init_exit_button()
		draw_guitar()
	End Sub
	Sub init_exit_button()
		Dim As Integer x = 916, y = 234
		Line (x, y)-Step(50,24), pal.BLUEGRAY, bf   
		Status_.draw_text("Exit", 926, pal.CYAN)
		Status_.draw_text("x", 934, pal.RED)
	
		exit_btn.hotspot = Type<TRect>(x, y, x+50, y+24)
	End Sub
	Sub on_exit() Destructor
		? "destructor"
	End Sub

End Namespace 
'=======================================================================================================================================
'__graphics(s)
__graphics()  	
Main_.init()
Main_.MainMenu_.init() 
Main_.MainMenu_.show()
?"end" 

