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
		Main_._pGuitar->revert()
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
			Main_._pGuitar->draw_note(ScaleBrowser_.notes(i)) 
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
