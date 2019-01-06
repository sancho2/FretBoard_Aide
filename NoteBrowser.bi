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
		Main_._pGuitar->revert()
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
		Main_._pGuitar->revert()
		NoteBrowser_.draw_notes()	
		
	End Sub
	Sub draw_notes() 
		'
		For i As Integer = 1 To NoteBrowser_.note_count
			Main_._pGuitar->draw_note(NoteBrowser_.notes(i)) 
		Next
	End Sub
	
End Namespace
