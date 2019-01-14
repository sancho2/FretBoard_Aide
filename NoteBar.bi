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
	Declare Function pGet_button_by_name(ByRef id As Const String) As Button_.TButton Ptr 
	'========================================================================================================================================
	Static Shared As Button_.TButton Ptr buttons(1 To 12)
	'========================================================================================================================================
	Sub set_selected(ByVal selected As boolean)
		'
		For i As Integer = 1 To 12 
			NoteBar_.buttons(i)->selected = selected
			NoteBar_.buttons(i)->Draw()
			'If selected = TRUE Then
			'	NoteBar_.buttons(i)->draw_selected()
			'Else
			'	NoteBar_.buttons(i)->draw_unselected()
			'EndIf
		Next
	End Sub
	Function pGet_button_by_name(ByRef id As Const String) As Button_.TButton Ptr 
		'
		For i As Integer = 1 To 12
			If LCase(id) = LCase(Trim(NoteBar_.buttons(i)->name)) Then 
				Return buttons(i) 
			EndIf
		Next
	End Function

	Function create_note_bar(ByVal x As Integer) As boolean  
		'
		For i As Integer = 1 To 12 
			Dim As String s = Trim(Notes_.notes(i)) 
			s = " " & s & " "
			NoteBar_.buttons(i) = New Button_.TButton(Button_.TButtonClass.bcCommand)			
			*(NoteBar_.buttons(i)) = MenuBar_.create_button(s , x,,s,0,,FALSE)   
  			x = NoteBar_.buttons(i)->x2 + 6 
		Next
		Return FALSE 
	End Function
	Sub Draw(ByVal selected As boolean = TRUE)
		'
		For i As Integer = 1 To 12
			NoteBar_.buttons(i)->Draw() 
			'If selected = TRUE Then 
  			'	NoteBar_.buttons(i)->Draw_selected() 
			'Else 
  			'	NoteBar_.buttons(i)->draw_unselected()
			'EndIf 
		Next
	End Sub
	Sub remove()
		Dim As Button_.TButton Ptr pBl, pBr 
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