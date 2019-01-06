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
#Ifndef __Sundry__ 	
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