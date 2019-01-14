'========================================================================================================================================
' PatternBar.bi
'========================================================================================================================================
#Define __PatternBar__ 
'========================================================================================================================================
Namespace PatternBar_
	'========================================================================================================================================
	Declare Function create_pattern_bar(ByVal x As Integer) As boolean
	Declare Sub Draw(ByVal grey As boolean = TRUE)
	Declare Sub destroy() 
	Declare Sub remove()  
	Declare Sub set_selected(ByVal selected As boolean)
	Declare Function pGet_button_by_name(ByRef id As Const String) ByRef As Button_.TButton
	'========================================================================================================================================
	' the seventh pattern button will always be what step is necessary to get back to root (show it as passive)
	Static Shared As Button_.TButton Ptr buttons(1 To 7)	
	'========================================================================================================================================
	Sub activate(ByRef scale_pattern As Const String)
		'
		' starting at 0 total must equal 12 
		' major wwhwww(x = h) 2 + 2 + 1 + 2 + 2 + 2 + x
		' minor whwwhw(x = w) 2 + 1 + 2 + 2 + 1 + 2 + x    
		Dim As String s
		Dim As Integer n 
		For i As Integer = 1 To 6
			 s = UCase(Chr(scale_pattern[i-1]))
			PatternBar_.buttons(i)->txt = s
			PatternBar_.buttons(i)->draw_enabled() 	
			Select Case s 
				Case "W"		' whole step = 2
			 		n += 2 
				case "H"		' half step = 1
					n += 1
				Case "+"		' whole + half step = 3
					n += 3
			End Select  
		Next
		If n < 9 OrElse n > 11 Then 
			s = "x"
		ElseIf n = 9 Then 
			s = "+"
		ElseIf n = 10 Then  
			s = "W"
		ElseIf n = 11 Then
			s = "H"
		EndIf
		PatternBar_.buttons(7)->txt = UCase(s)
		PatternBar_.buttons(7)->draw_passive()
		'	End Select
		'Next
		
	End Sub
	Sub set_selected(ByVal selected As boolean)
		'
		For i As Integer = 1 To 6 
			PatternBar_.buttons(i)->selected = selected
			PatternBar_.buttons(i)->Draw()
		Next
	End Sub
	Function pGet_button_by_name(ByRef id As Const String) ByRef As Button_.TButton
		'
		For i As Integer = 1 To 7
			If LCase(id) = LCase(Trim(PatternBar_.buttons(i)->name)) Then 
				Return *buttons(i) 
			EndIf
		Next
	End Function

	Function create_pattern_bar(ByVal x As Integer) As boolean  
		'
#Define __major_scale "WWHWWWH"	
		For i As Integer = 1 To 7 
			Dim As String s = Chr((__major_scale)[i-1]) ' Mid(__major_scale, i, 1)   'Mid("WWHWWWH", i , 1)  ' Mid(__major_scale, i, 1) 
			's = " " & s & " "
			PatternBar_.buttons(i) = New Button_.TButton(Button_.TButtonClass.bcCommand)			
			PatternBar_.buttons(i) = StatusBar_.create_button(s , x,,Trim(s) & Str(i),0,FALSE,FALSE)   
  			x = PatternBar_.buttons(i)->x2 + 6 
		Next
		PatternBar_.buttons(7)->draw_passive			
		 
		Return FALSE 
	End Function
	Sub Draw(ByVal selected As boolean = TRUE)
		'
		For i As Integer = 1 To 6
			PatternBar_.buttons(i)->Draw() 
		Next
	End Sub
	Sub remove()
		Dim As Button_.TButton Ptr pBl, pBr 
		pBl = PatternBar_.buttons(1)
		pBr = PatternBar_.buttons(6) 
		Line(pBl->x1+1, pBl->y1+1)-(pBr->x2, pBr->y2-1), pal.BLUEGRAY, bf 
	End Sub
	Sub destroy() Destructor  
		'
		For i As Integer = 1 To 6 
			If PatternBar_.buttons(i) <> 0 Then  
				Delete PatternBar_.buttons(i) 
				PatternBar_.buttons(i) = 0 
			EndIf
		Next
	End Sub
End Namespace