'========================================================================================================================================
' NoteBrowser.bi
'========================================================================================================================================
#Define __NoteBrowser__
'========================================================================================================================================
Namespace NoteBrowser_
	Static Shared As String notes(any)
	Static Shared As Integer note_count
	Static Shared As Button_.TButton Ptr clear_btn
	Static Shared As Button_.TButton Ptr exit_btn   
	'========================================================================================================================================
	Declare Function main_loop() As boolean 
	Declare Sub add_note(ByRef note As Const String) 
	Declare Sub remove_note(ByRef note As Const String) 
	Declare Sub draw_status() 
	Declare Sub parse_input(ByRef txt As Const String) 	
	Declare Sub draw_notes()
	Declare Sub clear_notes()
	'Declare Sub clear_status()
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
	'Sub clear_status() 
	'	'
	'	Main_.Clear_status_bar(-1, 661)
	'End Sub
	Sub draw_status() 
		'
		Dim As String txt = "Notes: " & string_array_to_string(notes()) 
		StatusBar_.draw_text(txt, 0,, FALSE)
	
	End Sub
	Sub init()  
		'
		Dim As Integer x
	
		StatusBar_.draw_text("Note Browser")

		' grey out the main menu 
		PrimaryMenu_.disable_menu()

		' draw separater bar
		Dim As Button_.TButton Ptr pMb = @(MenuBar_.pGet_button_by_name("help"))
		x = Button_.draw_separater_bar(pMb) + 6 

		' draw the notebar unselected
		'x = pMb->x2 + 6
		NoteBar_.create_note_bar(x) 
		NoteBar_.Draw(FALSE)
		
		x = STATUS_CLIENT_LEFT
		'NoteBrowser_.clear_btn = New Button_.TButton(Button_.TButtonClass.bcCommand)
		NoteBrowser_.clear_btn = StatusBar_.create_button("Clr", x,,"clr",3)

	End Sub 
	Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
		'
		For i As Integer = 1 To 12
			Dim As Button_.TButton Ptr pB = NoteBar_.buttons(i) 
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
		
		If NoteBrowser_.clear_btn->is_point_in_rect(pnt) = TRUE Then 
			key = "r"
			Return 
		EndIf
		If NoteBrowser_.exit_btn->poll(pnt) = TRUE Then
			key = "x" 
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
				EndIf
				If key = "" Then 
					key = InKey()
				EndIf 
				Sleep 15 
			Loop While key = ""
			Select Case key
				Case "a" To "g"
					Dim As Button_.TButton Ptr pB = NoteBar_.pGet_button_by_name(key) 
					pB->toggle_selected()
					If pB->selected = TRUE Then 
						key = "+" & Trim(pB->Name)
					Else 
						key = "-" & Trim(pB->Name) 
					EndIf
				Case "A" To "G"
					Dim As Button_.TButton Ptr pB = NoteBar_.pGet_button_by_name(key & "#") 
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
				Case "x" 
					Exit Do 
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
		NoteBrowser_.remove_buttons()		' remove the clear button  
		NoteBrowser_.clear_notes()			' clear the notes off the guitar 

		' remove the separater bar 
		Dim As Integer x = NoteBar_.buttons(1)->x1 - 4, y1 = NoteBar_.buttons(1)->y1, y2 = NoteBar_.buttons(1)->y2 
		Dim As TSeparaterBar sb 
		sb = Type<TRect>(x, y1, x+4, y2)
		sb.clr = pal.BLUEGRAY 
		sb.draw()   
		Line(x,y1)-Step(4,0), pal.BLACK
		Line(x,y2)-Step(4,0), pal.BLACK

		NoteBar_.remove()			' remove the note bar
		NoteBar_.destroy() 

		PrimaryMenu_.enable_menu()			' enable the main menu 

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
