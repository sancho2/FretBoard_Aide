'========================================================================================================================================
' ScaleBrowser.bi
'========================================================================================================================================
' todo: fix exit button, change status text between operations
'========================================================================================================================================
#Define __ScaleBrowser__ 
'========================================================================================================================================
#Define __CLEAR 		ScaleBrowser_.clear_btn
#Define __MAJOR 		ScaleBrowser_.major_btn
#Define __MINOR 		ScaleBrowser_.minor_btn
#Define __HARMONIC 	ScaleBrowser_.harmonic_btn
#Define __MELODIC		ScaleBrowser_.melodic_btn
'#Define __root 	ScaleBrowser_.scale->root
'========================================================================================================================================
Namespace ScaleBrowser_
	' the last step is removed as it just returns to root 
	Const As String 	MAJOR_PATTERN = "WWHWWW", 				MINOR_PATTERN = "WHWWHW", _
							HARMONIC_MAJOR_PATTERN = "WWHWH+", 	HARMONIC_MINOR_PATTERN = "WHWWH+", _ 
							MELODIC_MAJOR_PATTERN = "WWHWHW", MELODIC_MINOR_PATTERN = "WHWWWW"  
	' major wwhwwwh 
	' minor whwwhww
	' harmonic minor - sharpen seventh note WHWWH+  + = (W+H)
	' harmonic major - lower sixth note  WWHWH+
	' melodic major - lower sixth and seventh degree half step ex C D E F G Ab/G# Bb/A#  
	' melodic minor - lower the third degree half setp ex C D Eb/D# F G A B 
	 
	'========================================================================================================================================
	Enum TScaleMode
		smNone 
		smMajor
		smMinor 
		smHarmonicMajor
		smHarmonicMinor 
		smMelodicMajor
		smMelodicMinor 		
	End Enum
	Type TScale extends Notes_.TNoteSet 
		As String Name
		As TScaleMode mode  
		Declare Sub clr()
		Declare Sub clr_root() 
		Declare Sub clr_pattern()  
		Declare Property pattern(ByRef value As Const String) 
		Declare Property pattern() As Const String  
		Declare Property root(ByRef value As Const String)
		Declare Property root() As String
		Declare Operator Cast() As String  
		Private: 
			As String _root  
			As String _pattern
			Declare Sub apply_pattern()  
	End Type
		Operator TScale.Cast() As String 
			'
			With This
				Dim As String s
				For i As Integer = 0 To .count - 1 
					s &= .notes(i) &  " "  
				Next
				Return s 
			End With
			
		End Operator
		Property TScale.pattern(ByRef value As Const String)
			'
			With This
				._pattern = value 
				.apply_pattern() 
			End With
		End Property
		Property TScale.pattern() As Const String
			'
			Return this._pattern
		End Property
		Property TScale.root(ByRef value As Const String)
			'
			With This 
				.clr_root()
				._root = value
				.add_note(value)
				If ._pattern <> "" Then 
					.apply_pattern() 
				EndIf
			End With  
		End Property
		Property TScale.root() As String
			'
			Return this._root
		End Property
		Sub TScale.apply_pattern() 
			With This
				Dim As String s = ._root 
				For i As Integer = 1 To Len(._pattern)
					If LCase(Mid(._pattern, i, 1)) = "w" Then
						s = Notes_.get_whole_step(s) 
					ElseIf LCase(Mid(._pattern, i, 1)) = "h" Then
						s = Notes_.get_half_step(s) 
					ElseIf LCase(Mid(._pattern, i, 1)) = "+" Then
						s = Notes_.get_whole_step(s)
						s = Notes_.get_half_step(s)
					EndIf
					.add_note(s) 
				Next
			End With
		End Sub
		Sub TScale.clr() 
			With This 
				.name = ""
				ReDim .notes(0 To 0) 
				.count = 0 
				._root = ""
				._pattern = ""
			End With
		End Sub
		Sub TScale.clr_root() 
			With This 
				.name = ""
				ReDim .notes(0 To 0) 
				.count = 0 
				._root = ""
			End With 
		End Sub
		Sub TScale.clr_pattern() 
			With This 
				.name = ""
				ReDim Preserve .notes(0 To 0) 
				.count = 1 
				._pattern = ""
			End With
		End Sub
	'========================================================================================================================================
	Static Shared As TScale Ptr scale 
	'Dim Shared As String notes(any)
	Static Shared As Button_.TButton Ptr exit_btn 
	Static Shared As Button_.TButton Ptr clear_btn 
	Static Shared As Button_.TButton Ptr root_btn 
	Static Shared As Button_.TButton Ptr major_btn 
	Static Shared As Button_.TButton Ptr minor_btn
	Static Shared As Button_.TButton Ptr harmonic_btn 
	Static Shared As Button_.TButton Ptr melodic_btn 
	'========================================================================================================================================
	Declare Sub init()  

	Declare Function main_loop() As boolean 
	Declare Sub toggle_major()
	Declare Sub toggle_minor() 
	Declare 	Sub set_root_note(ByRef note As Const String)
	Declare Sub draw_status() 
	Declare Sub parse_input(ByRef txt As Const String) 	
	Declare Sub draw_notes()
	Declare Sub clear_notes()
	'Declare Sub clear_status()
	Declare Sub remove_buttons() 
	Declare Sub on_exit()
	Declare Sub destroy() 		'Destructor
'	Declare Sub add_note(ByRef note As Const String)
	Declare Sub remove_note(ByRef note As Const String) 
	Declare Sub toggle_harmonic()
	Declare Sub toggle_melodic()
	'========================================================================================================================================
	'Sub clear_status() 
	'	'
	'	Main_.Clear_status_bar(-1, 661)
	'End Sub
	Sub draw_status() 
		'
'		Dim As String txt = "Notes: " & string_array_to_string(notes()) 
'		StatusBar_.draw_text(txt, 0,, FALSE)
	
	End Sub
	Sub init()  
		'
		Dim As Integer x
		
		StatusBar_.Clear_status_bar()
		
		' create a new scale object 
		ScaleBrowser_.scale = New TScale 
	
		' grey out main menu
		PrimaryMenu_.disable_menu() 
		
		' draw separater bar
		Dim As Button_.TButton Ptr pMb = @(MenuBar_.pGet_button_by_name("help"))
		x = Button_.draw_separater_bar(pMb) + 6 

		' draw the notebar unselected
		NoteBar_.create_note_bar(x) 
		NoteBar_.Draw(FALSE)

		' draw status bar buttons 
		x = STATUS_CLIENT_LEFT 
		ScaleBrowser_.clear_btn = StatusBar_.create_button("Clr", x,,"clr",3)

		' draw separater bar
		x = Button_.draw_separater_bar(__CLEAR) + 6 
		'x = Button_.draw_separater_bar(__CLEAR) + 6 

		' major and minor buttons belong to group (only one can be selected at a time) 
		Dim As Button_.TButtonGroup Ptr pGroup = New Button_.TButtonGroup 

		' major button
		'x = ScaleBrowser_.clear_btn->x2 + 6
		'x = __CLEAR->x2 + 6  
		'ScaleBrowser_.major_btn = StatusBar_.create_button("Major", x,Button_.TButtonClass.bcRadio,"major",3)
		__MAJOR = StatusBar_.create_button("Major", x,Button_.TButtonClass.bcRadio,"major",3)
		pGroup->Add(__MAJOR)

		' minor button 
		'x = ScaleBrowser_.major_btn->x2 + 6
		x = __MAJOR->x2 + 6  
		'ScaleBrowser_.minor_btn = StatusBar_.create_button("Minor", x,Button_.TButtonClass.bcRadio,"minor",3)
		__MINOR = StatusBar_.create_button("Minor", x,Button_.TButtonClass.bcRadio,"minor",3)
		pGroup->Add(__MINOR)

		x = Button_.draw_separater_bar(__minor) + 6 

		Dim As Button_.TButtonGroup Ptr pGroupB = New Button_.TButtonGroup

		' harmonic button 
		'x = __MINOR->x2 + 6
		__HARMONIC = StatusBar_.create_button("Harmonic", x,Button_.TButtonClass.bcRadio,"harmonic",5)
		pGroupB->Add(__HARMONIC) 
		
		' melodic button
		x = __HARMONIC->x2 + 6 
		__MELODIC = StatusBar_.create_button("Melodic", x, Button_.TButtonClass.bcRadio, "melodic", 3) 
		pGroupB->Add(__MELODIC)
		
		' draw separater bar 
		x = Button_.draw_separater_bar(__MELODIC) + 6 
		
		' draw the pattern bar 
		PatternBar_.create_pattern_bar(x)
		PatternBar_.Draw(FALSE)  

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
		
		For i As Integer = 1 To 6 
			Dim As Button_.TButton Ptr pB = PatternBar_.buttons(i) 
			If pB->is_point_in_rect(pnt) = TRUE Then
				key = "~" & PatternBar_.Flip_button(i)
				Return 
			EndIf
		Next

		If __MAJOR->poll(pnt) = TRUE Then
			key = "j"
			Return
		EndIf
		If __MINOR->poll(pnt) = TRUE Then 
			key = "n"
			Return 
		EndIf
		If __HARMONIC->poll(pnt) = TRUE Then 
			key = "o"
			Return 
		EndIf
		If __MELODIC->poll(pnt) = TRUE Then 
			key = "l"
			Return 
		EndIf
		If (__CLEAR)->is_point_in_rect(pnt) = TRUE Then 
			key = "r"
			Return 
		EndIf
		If ScaleBrowser_.exit_btn->poll(pnt) = TRUE Then 
			key = "x" 
			Return 
		EndIf
		key = ""
	End Sub
	Function main_loop() As boolean 
		'
		Dim As String key, pattern_keys="!@#$%^"
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
				ScaleBrowser_.set_root_note(Mid(key, 2))
				key = ""
			ElseIf Left(key, 1) = "-" Then 
				' remove note
				ScaleBrowser_.remove_note(Mid(key, 2)) 
				key = "" 
			EndIf
			Select Case key 
				Case "j"
					toggle_major() 
					key = ""
					'draw_status() 
				Case "r"
					ScaleBrowser_.clear_notes()
					key = ""
				Case "n"
					toggle_minor() 
					key = ""
				Case "o"
					toggle_harmonic()
					key = ""
				Case "l"
					toggle_melodic() 
					key = ""
				Case "!", "@", "#", "$", "%", "^"			' pattern buttons
					Dim As Integer n = InStr(pattern_keys, key) 
					key = "~" & PatternBar_.Flip_button(n)
 
				'Case "!"			' pattern button 1
				'Case "@"			' pattern button 2
				'Case "#"			' pattern button 3
				'Case "$"			' pattern button 4
				'Case "%"			' pattern button 5
				'Case "^"			' pattern button 6

				Case "x" 
					Exit Do 
				Case Chr(27)
					Exit Do 
				Case Else 
					key = ""
			End Select
			If Left(key, 1) = "~" Then 
				' change the scale pattern
				key = ""
			EndIf
		Loop While ok_to_exit = FALSE
		
		on_exit() 
		
		Return FALSE 
	End Function
	Sub show_scale_buttons()
		'
		For n As Integer = 0 To ScaleBrowser_.scale->count - 1
			Dim As String note = LCase(Trim(ScaleBrowser_.scale->notes(n)))  
			For i As Integer = 1 To 12 
				Dim As String s = LCase(Trim(NoteBar_.buttons(i)->Name)) 
				If note = s And note <> LCase(ScaleBrowser_.scale->root) Then 
					NoteBar_.buttons(i)->draw_passive() 
				EndIf
			Next
		Next
	End Sub
	Sub reset_scale_buttons()
		'
		For i As Integer = 1 To 12 
			If NoteBar_.buttons(i)->passive = TRUE Then
				NoteBar_.buttons(i)->draw_unselected()
			EndIf
		Next
	End Sub
	Sub toggle_melodic()
		'
		If scale->mode = smNone Then Return		' if there is no current scale the melodic button should do nothing 
		
		Dim As TScale Ptr pS = ScaleBrowser_.scale

		' clear everything since we are rebuilding everything anyway 
		Main_._pGuitar->revert()
		pS->clr_pattern()
		ScaleBrowser_.reset_scale_buttons()
		__MELODIC->toggle_selected()

		If __MELODIC->selected = TRUE Then
			' selecting the melodic button applies the melodic mode to the scale
			'If pS->mode = smHarmonic Then   
			If pS->mode = smMajor OrElse pS->mode = smHarmonicMajor Then 
				pS->mode = smMelodicMajor
				pS->pattern = MELODIC_MAJOR_PATTERN
				pS->name = "Melodic Major" 
			ElseIf pS->mode = smMinor OrElse pS->mode = smHarmonicMinor Then 
				pS->mode = smMelodicMinor 
				pS->pattern = MELODIC_MINOR_PATTERN
				pS->Name = "Melodic Minor"
			EndIf 
			ScaleBrowser_.show_scale_buttons() 
		Else
			' return the current scale to natural
			If pS->mode = smMelodicMajor Then 
				pS->pattern = MAJOR_PATTERN
				pS->mode = smMajor
				pS->Name = "Major"
			ElseIf scale->mode = smMelodicMinor Then 
				pS->pattern = MINOR_PATTERN
				pS->mode = smMinor
				pS->Name = "Minor"
			EndIf 
			ScaleBrowser_.show_scale_buttons() 
		EndIf

		PatternBar_.activate(pS->pattern)		' update the pattern bar   
		ScaleBrowser_.draw_notes()

	End Sub
	Sub toggle_harmonic()
		'
		If scale->mode = smNone Then Return		' if there is no current scale the harmonic button should do nothing 
		
		Dim As TScale Ptr pS = ScaleBrowser_.scale

		' clear everything since we are rebuilding everything anyway 
		Main_._pGuitar->revert()
		pS->clr_pattern()
		ScaleBrowser_.reset_scale_buttons()
		__HARMONIC->toggle_selected()

		If __HARMONIC->selected = TRUE Then
			' selecting the harmonic button applies the harmonic mode to the scale  
			If pS->mode = smMajor OrElse pS->mode = smMelodicMajor Then 
				pS->mode = smHarmonicMajor
				pS->pattern = HARMONIC_MAJOR_PATTERN
				pS->name = "Harmonic Major" 
			ElseIf pS->mode = smMinor OrElse pS->mode = smMelodicMinor Then 
				pS->mode = smHarmonicMinor 
				pS->pattern = HARMONIC_MINOR_PATTERN
				pS->Name = "Harmonic Minor"
			EndIf 

			ScaleBrowser_.show_scale_buttons() 
		Else
			' return the current scale to natural
			If pS->mode = smHarmonicMajor Then 
				pS->pattern = MAJOR_PATTERN
				pS->mode = smMajor
				pS->Name = "Major"
			ElseIf scale->mode = smHarmonicMinor Then 
				pS->pattern = MINOR_PATTERN
				pS->mode = smMinor
				pS->Name = "Minor"
			EndIf 
			ScaleBrowser_.show_scale_buttons() 
		EndIf

		PatternBar_.activate(pS->pattern)		' update the pattern bar   
		ScaleBrowser_.draw_notes()

	End Sub
	Sub toggle_major() 
		'
		Dim As Button_.TButton Ptr pB = ScaleBrowser_.major_btn
		Dim As TScale Ptr pS = ScaleBrowser_.scale

		' clear everything since we are rebuilding everything anyway 
		Main_._pGuitar->revert()
		pS->clr_pattern()
		ScaleBrowser_.reset_scale_buttons()
		pB->toggle_selected()

		If pB->selected = TRUE Then
			
			' selecting the major button applies the major scale formula to the root note to fill scale 
			pS->pattern = MAJOR_PATTERN
			pS->mode = smMajor
			pS->Name = "Major"
			ScaleBrowser_.show_scale_buttons()
			
			PatternBar_.activate(pS->pattern)		' update the pattern bar   
		EndIf
		ScaleBrowser_.draw_notes()
	End Sub
	Sub toggle_minor()
		'
		Dim As Button_.TButton Ptr pB = ScaleBrowser_.minor_btn
		Dim As TScale Ptr pS = ScaleBrowser_.scale

		' clear everything since we are rebuilding everything anyway 
		Main_._pGuitar->revert()
		pS->clr_pattern()
		ScaleBrowser_.reset_scale_buttons()
		pB->toggle_selected()

		If pB->selected = TRUE Then
			' selecting the minor button applies the minor scale formula to the root note to fill scale 
			pS->pattern = MINOR_PATTERN
			pS->mode = smMinor
			pS->Name = "Minor"
			ScaleBrowser_.show_scale_buttons() 

			PatternBar_.activate(pS->pattern)		' update the pattern bar   
		EndIf
		ScaleBrowser_.draw_notes() 
	End Sub
	Sub set_root_note(ByRef note As Const String)
		'
		' first check if there is already a root/scale
		If ScaleBrowser_.scale->root <> "" Then
			Main_._pGuitar->revert() 
			NoteBar_.set_selected(FALSE) 
			ScaleBrowser_.scale->clr_root()
			ScaleBrowser_.reset_scale_buttons()
			'NoteBar_.pGet_button_by_name(note).selected = TRUE
			(NoteBar_.pGet_button_by_name(note))->draw_selected()   
		EndIf
		ScaleBrowser_.scale->root = note
		If ScaleBrowser_.scale->pattern <> "" Then 
			ScaleBrowser_.show_scale_buttons() 
		EndIf
		ScaleBrowser_.draw_notes()

	End Sub
	Sub add_note(ByRef note As Const String) 
		'
		'If Notes_._get_note_index(note) <> 0 Then		' if this is a valid note  
		'	If is_value_in_array(note, ScaleBrowser_.notes()) = FALSE Then 	' if this note isn't already in the list
		'		 ScaleBrowser_.note_count += 1
		'		 ReDim Preserve ScaleBrowser_.notes(1 To ScaleBrowser_.note_count)
		'		 ScaleBrowser_.notes(ScaleBrowser_.note_count) = UCase(note)  
		'	EndIf 
		'EndIf
		'ScaleBrowser_.draw_notes()	
	End Sub
	Sub remove_note(ByRef note As Const String) 
		'
		ScaleBrowser_.clear_notes()
		ScaleBrowser_.scale->clr_root() 
		'If Notes_._get_note_index(note) <> 0 Then		' if this is a valid note  
		'	If is_value_in_array(note, ScaleBrowser_.notes()) = TRUE Then 	' if this note is in the list
		'		 ScaleBrowser_.note_count -= 1
		'		 remove_array_element(Cast(String, note), ScaleBrowser_.notes()) 
		'	EndIf 
		'EndIf
		'Main_._pGuitar->revert()
		'ScaleBrowser_.draw_notes()	
		
	End Sub
	Sub draw_notes() 
		'
		For i As Integer = 0 To ScaleBrowser_.scale->count-1	' .note_count
			If ScaleBrowser_.scale->notes(i) = ScaleBrowser_.scale->root Then 
				Main_._pGuitar->draw_note(ScaleBrowser_.scale->notes(i), pal.SAND)
			Else
				Main_._pGuitar->draw_note(ScaleBrowser_.scale->notes(i))
			EndIf
		Next
	End Sub
	Sub destroy() Destructor 
		If ScaleBrowser_.scale <> 0 Then Delete ScaleBrowser_.scale 
		ScaleBrowser_.scale = 0 

		If ScaleBrowser_.major_btn <> 0 Then 
			If ScaleBrowser_.major_btn->pGroup <> 0 Then 
				Delete ScaleBrowser_.major_btn->pGroup
			EndIf
			ScaleBrowser_.major_btn->pGroup = 0 
			Delete ScaleBrowser_.major_btn
		EndIf
		ScaleBrowser_.major_btn = 0  

		If ScaleBrowser_.minor_btn <> 0 Then
			' As yet, there is no provided method to delete the individual button group member.  
			' The only way minor_btn->pGroup memory still exists is if we somehow deleted the major button without freeing 
			' the pointer memory, since they share the same group pointer
			' That means we do not free .minor_btn->pGroup memory because it is already free 
			ScaleBrowser_.minor_btn->pGroup = 0	
			Delete ScaleBrowser_.minor_btn 
		EndIf 
		ScaleBrowser_.minor_btn = 0
		
		If __HARMONIC <> 0 Then
			Delete __HARMONIC 
			__HARMONIC = 0 
		EndIf
	End Sub
	Sub on_exit()
		'
		ScaleBrowser_.clear_notes()
		ScaleBrowser_.remove_buttons() 

		PrimaryMenu_.enable_menu()

		' remove the separater bar 
		Dim As Integer x = NoteBar_.buttons(1)->x1 - 4, y1 = NoteBar_.buttons(1)->y1, y2 = NoteBar_.buttons(1)->y2 
		Dim As TSeparaterBar sb 
		sb = Type<TRect>(x, y1, x+4, y2)
		sb.clr = pal.BLUEGRAY 
		sb.draw()   
		Line(x,y1)-Step(4,0), pal.BLACK
		Line(x,y2)-Step(4,0), pal.BLACK

		NoteBar_.remove()
		NoteBar_.destroy() 

		ScaleBrowser_.destroy() 
	End Sub
	Sub remove_buttons() 
		MenuBar_.remove_button_by_name("major") 
		MenuBar_.remove_button_by_name("minor") 
	End Sub 
	Sub clear_notes() 
		'
		Main_._pGuitar->revert()
		ScaleBrowser_.scale->clr()
	End Sub
	
End Namespace


