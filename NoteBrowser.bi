'========================================================================================================================================
' TODO: unselecting a notebar button should leave passive button notes on the board, the clr button should unselect passive buttons   
' NoteBrowser.bi
'========================================================================================================================================
#Define __NoteBrowser__
'========================================================================================================================================
'#Define __NOTES NoteBrowser_.pNotes
#Define __NOTES NoteBrowser_.pNotes
#Define __NOTE(S,F) __NOTES[(S - 1) * Main_._pGuitar->fret_count + F]  
#Define __NOTE_COUNT  (Main_._pGuitar->string_count * Main_._pGuitar->fret_count)  
'========================================================================================================================================
Namespace NoteBrowser_
	'Enum TBrowserNoteType
	'	bntSingle
	'	bntSet
	'End Enum 
	'Type TStringFret
	'	As Integer strng 
	'	As Integer fret 
	'End Type
	'Type TBrowserNotes
	'	As TStringFret Ptr notes  
	'	As Integer count   
	'	Declare Sub clear_notes()
	'End Type
	'	Sub TBrowserNotes.clear_notes() 
	'		
	'	End Sub
	'Type TGNote extends TFretNote
	'	Declare Property showing() As boolean 
	'	Private: 
	'		As boolean _is_showing 	
	'End Type
	'Static Shared As TBrowserNotes Ptr pNotes  
	'Static Shared As String notes(any)
	'	Static Shared As TFretNote Ptr pFNotes(Any)
	Static Shared As TFretNote Ptr pNotes  

	'Static Shared As String Ptr pNotes(Any) 
	Static Shared As Integer note_count
	Static Shared As Button_.TButton Ptr pClear_btn
	'========================================================================================================================================
	Declare Function main_loop() As boolean 
	Declare Sub add_note(ByRef note As Const String) 
	Declare Sub add_single_note(ByVal _string As Integer, ByVal _fret As Integer)
	Declare Sub toggle_single_note(ByRef string_fret As Const String)
	Declare Sub remove_single_note(ByVal _string As Integer, ByVal _fret As Integer)
	Declare Sub remove_note(ByRef note As Const String) 
	Declare Sub parse_input(ByRef txt As Const String) 	
	Declare Sub draw_notes()
	Declare Sub clear_notes()
	'Declare Sub clear_status()
	Declare Sub on_exit() 
	Declare Sub destroy() 		'Destructor 
	Declare Sub init()  
	Declare Sub init_fretnotes()
	Declare Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
	'========================================================================================================================================
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
		__NBCLEAR = StatusBar_.create_button("Clr", x,,"clr",3)

		init_fretnotes() 
		'Locate 3,100:Print __NOTES[131].name 
	End Sub 
	Sub init_fretnotes()
		'
		Dim As Integer n 
		' formula for note = (string * fret_count) + fret 
		__NOTES = New TFretNote[Main_._pGuitar->string_count * Main_._pGuitar->fret_count]

		For _string As Integer = 1 To 6 
			For _fret As Integer = 0 To Main_._pGuitar->fret_count - 1
				__NOTES[n].strng = _string
				__NOTES[n].fret = _fret 
				__NOTES[n].name = Main_._pGuitar->get_note(_string, _fret)
				n += 1 
			Next
		Next
	End Sub
	Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
		'
		' guitar hotspots
		Dim As Integer strng, fret 
		If Main_._pGuitar->is_point_in_hotspot(pnt, strng, fret) = TRUE Then
			key = "~" & Str(strng) & " " & Str(fret)
			Return  	
		EndIf

		'note buttons
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
		
		' clear button 
		If __NBCLEAR->is_point_in_rect(pnt) = TRUE Then 
			key = "r"
			Return 
		EndIf
		
		'exit button
		If Main_.pExit_btn->poll(pnt) = TRUE Then
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
				Locate 1,1:Print "moo"
				key = ""
			ElseIf Left(key, 1) = "-" Then 
				' remove note
				NoteBrowser_.remove_note(Mid(key, 2)) 
				key = "" 
			ElseIf Left(key, 1) = "~" Then 
				'NoteBrowser_.add_single_note(Mid(key,2))
				NoteBrowser_.toggle_single_note(Mid(key,2))
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
		'NoteBrowser_.remove_buttons()		' remove the clear button  
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
		' 
		If __NBCLEAR <> 0 Then Delete __NBCLEAR
		__NBCLEAR = 0
		
		If __NOTES <> 0 Then 
			Delete[] __NOTES
		EndIf 
		__NOTES = 0 
	End Sub
	Sub clear_notes() 
		'
		Main_._pGuitar->revert()
		For i As Integer = 0 To __NOTE_COUNT - 1
			__NOTES[i].is_showing = FALSE 
		Next
		NoteBar_.set_selected(FALSE) 
	End Sub
	Sub add_note(ByRef note As Const String) 
		'
		' Show every occurance of selected note on the guitar 
		If Notes_._get_note_index(note) <> 0 Then		' if this is a valid note
			Main_._pGuitar->draw_all_note(note, __NOTES)
			'Locate 2,1:Print __NOTE(1,1).is_showing;"<<<" 
		EndIf 		 
						
	End Sub
	'Sub add_single_note(ByRef string_fret As Const String)
	Sub add_single_note(ByVal _string As Integer, ByVal _fret As Integer) 
		'
		Dim As String note 
		__NOTE(_string, _fret).is_showing = TRUE 	' update the array 			
		note = Main_._pGuitar->draw_note(_string, _fret)		' draw the single note on the guitar 
		NoteBar_.pGet_button_by_name(" " & note & " ")->draw_passive()	' hilite the note button as passive  
	End Sub
	Sub toggle_single_note(ByRef string_fret As Const String)
		'
		Dim As Integer strng, fret, n  
		Dim As string note  
		n = InStr(string_fret, " ")					' separate the string and fret values  
		strng = Val(Left(string_fret, n-1))
		fret = Val(Mid(string_fret, n + 1))
		
		note = Main_._pGuitar->get_note(strng, fret)		' get note from string and fret  
		
		If Notes_._get_note_index(note) <> 0 Then		' if this is a valid note  
			If __NOTE(strng, fret).is_showing = FALSE Then
				'add_single_note(ByRef note As Const String)
				add_single_note(strng, fret) 
			Else 
				remove_single_note(strng, fret) 
			EndIf
		EndIf 
	End Sub
	Sub remove_single_note(ByVal _string As Integer, ByVal _fret As Integer)
		'
		Dim As String note 
		__NOTE(_string, _fret).is_showing = FALSE 			
		note = Main_._pGuitar->undraw_note(_string, _fret)
		Dim As Button_.TButton Ptr pB = NoteBar_.pGet_button_by_name(" " & note & " ")
		If pB->selected = FALSE Then 
			NoteBar_.pGet_button_by_name(" " & note & " ")->draw_unselected()	' unhilite the note button as passive (unselected = not passive)
		EndIf    
	End Sub
	Sub remove_note(ByRef note As Const String) 
		'
		If Notes_._get_note_index(note) <> 0 Then		' if this is a valid note  
			'If is_value_in_array(note, NoteBrowser_.notes()) = TRUE Then 	' if this note is in the list
			'If is_value_in_array(note, __NOTES()) = TRUE Then 	' if this note is in the list
			For i As Integer = 0 To __NOTE_COUNT
				'If InStr(LCase(Trim(__NOTES[i].name)), "b")>0 Then ?"[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[["
				If LCase(note) = LCase(Trim(__NOTES[i].name)) Then 
					'Locate 1,1:Print "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
					__NOTES[i].is_showing = FALSE
				EndIf 
			Next  
		EndIf
		Main_._pGuitar->revert()
		NoteBrowser_.draw_notes()	
		
	End Sub
	Sub draw_notes() 
		'
		For i As Integer = 0 To __NOTE_COUNT
			If __NOTES[i].is_showing = TRUE Then 
				Main_._pGuitar->draw_note(__NOTES[i].strng, __NOTES[i].fret) 
			EndIf
			'?"looooooo "; *(__NOTES(i)), __NOTE_COUNT
			'Main_._pGuitar->draw_note(NoteBrowser_.notes(i))
			'Main_._pGuitar->draw_all_note(*(__NOTES(i))) 
		Next
	End Sub
	
End Namespace
