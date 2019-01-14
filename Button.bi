'========================================================================================================================================
' Button.bi
'========================================================================================================================================
#Define __Button__
'========================================================================================================================================
#Ifndef __PALETTE__	
	#Define __CYAN 			&HFF91d9f3
	#Define __GRAY				&HFF898989
	#Define __DARK_BLUEGRAY &HFF355278
	#Define __WHITE 			&HFFffffff
	#Define __DARK_CYAN		&HFF5aa8b2
	#Define __BROWN			&HFF9e5b47
#EndIf 
'========================================================================================================================================
Namespace Button_ 
	'========================================================================================================================================
	Enum TButtonClass 
		bcNone 
		bcCommand				' standard command button
		bcSelect					' toggle switch
		bcPassive				' active button that does not receive user input
		bcRadio 					' radio button uses bcSelect colors   
		'bcGroup					' radio button member of related button group 
	End Enum
	'========================================================================================================================================
	Type TButtonColorSet 
		As ULong text_color  
		As ULong hotkey_color  
		As ULong back_color 
		As ULong border_color
	End Type
	'========================================================================================================================================
	Type TButtonGroupFWD As TButtonGroup   
	'========================================================================================================================================
	Type TButton extends TGRect 
		As String Name  
		As Integer text_x 
		As Integer text_y
		As String txt 
		As Integer hotkey_index
		As Button_.TButtonGroupFWD Ptr pGroup  
		
		As Button_.TButtonColorSet enabled_colors
		As Button_.TButtonColorSet disabled_colors 
		As Button_.TButtonColorSet selected_colors
		As Button_.TButtonColorSet unselected_colors 
		As Button_.TButtonColorSet passive_colors  

		' button class 
		Declare Property genus() As Button_.TButtonClass
		Declare Property genus(ByVal value As Button_.TButtonClass) 		' TODO: probably deactivate this   

		' buttons that are not enabled do not accept user input 
		Declare Property enabled() As boolean
		Declare Property enabled(ByVal value As boolean)  

		' passive buttons are hilited with a special passive tone, do not take user input
		Declare Property passive() As boolean						
		Declare Property passive(ByVal value As boolean)  
		
		' selected buttons are pressed and remain selected until deselected 
		Declare Property selected() As boolean		
		Declare Property selected(ByVal value As boolean)  

		' allows the button location to be set via a TRect object  		
		Declare Operator Let(ByRef rhs As Const TRect)
		
		Declare Function poll(ByRef pnt As TPoint) As boolean 
		Declare Sub draw_passive() 				' draws passive button, sets passive to true
		Declare Sub draw_enabled()					' draws enabled button, sets enabled to true  
		Declare Sub draw_disabled()				' draws disabled button, set enabled to false 
		Declare Sub draw_unselected()				' draws enabled button, set is_passive = false, is_selected = false     
		Declare Sub draw_selected()				' draws selected button, sets selected to true 
		Declare Sub toggle_selected() 			' toggles selected state of button and draws it 
		Declare Sub toggle_passive() 
		Declare Sub toggle_enabled() 		
		Declare Sub draw(ByVal colors As Button_.TButtonColorSet Ptr = 0)  

		Declare Constructor(ByVal button_class As Button_.TButtonClass) 
		Declare Constructor(ByVal pGroup As Button_.TButtonGroupFWD ptr) 

		Private: 
			As boolean _is_enabled
			As boolean _is_selected 
			As boolean _is_passive
			As Button_.TButtonClass _class
			
			Declare Sub _init()
			Declare Function _get_pColors() As Button_.TButtonColorSet Ptr			
			Declare Sub _hilite()
			Declare Sub _unhilite() 
	End Type
	'-----------------------------------------------------------------------------------------------------------------------------------
		Constructor TButton(ByVal button_class As Button_.TButtonClass)
			'
			With This 
				._class = button_class
				._is_enabled = TRUE				' defaults 
				._is_selected = FALSE 
				._is_passive = FALSE
				._init() 
			End With
		End Constructor
		Constructor TButton(ByVal pGroup As Button_.TButtonGroupFWD ptr)
			'
			With This 
				.pGroup = pGroup
				._is_enabled = FALSE 
				._is_selected = FALSE 
				._is_passive = FALSE 
				._init()  
			End With
		End Constructor
		'-----------------------------------------------------------------------------------------------------------------------------------
		Property TButton.genus() As Button_.TButtonClass
			' 
			With This 
				Return ._class 
			End With
		End Property
		Property TButton.genus(ByVal value As Button_.TButtonClass) 		' TODO: probably deactivate this
			'
			With This 
				._class = value 
			End With
		End Property    
		Property TButton.enabled() As boolean
			'
			Return this._is_enabled 
		End Property
		Property TButton.enabled(ByVal value As boolean)
			'
			this._is_enabled = value 
		End Property
		Property TButton.passive() As boolean
			'
			Return this._is_passive 
		End Property
		Property TButton.passive(ByVal value As boolean)
			'
			this._is_passive = value 
		End Property
		Property TButton.selected() As boolean
			'
			Return this._is_selected 
		End Property
		Property TButton.selected(ByVal value As boolean)
			'
			this._is_selected = value 
		End Property
		'-------------------------------------------------------------------------------------------------------------------------------------
		Operator TButton.Let(ByRef rhs As Const TRect) 
			Cast(TRect, This) = rhs  
		End Operator
		'-----------------------------------------------------------------------------------------------------------------------------------
		Sub TButton._init()
			'
			With This 
				With .enabled_colors
					.text_color = __CYAN 
					.border_color = __BLACK
					.back_color = __BLUEGRAY
					.hotkey_color = __RED
				End With
				With .disabled_colors
					.text_color = __GRAY 
					.border_color = __BLACK
					.back_color = __BLUEGRAY
					.hotkey_color = __BROWN
				End With
				With .selected_colors 
					.text_color = __WHITE 
					.border_color = __BLACK
					.back_color = __DARK_CYAN
					.hotkey_color = __BROWN	 
				End With
				With .unselected_colors 
					.text_color = __CYAN 
					.border_color = __BLACK
					.back_color = __BLUEGRAY
					.hotkey_color = __BROWN	 
				End With
				With .passive_colors 
					.text_color = __WHITE 
					.border_color = __BLACK
					.back_color = __DARK_BLUEGRAY
					.hotkey_color = __WHITE			' this effectively shuts off the hotkey color 
				End With
			End With
		End Sub
		Function TButton._get_pColors() As Button_.TButtonColorSet Ptr 
			'
			With This 
				If ._class = bcSelect OrElse ._class = bcRadio Then 
					If ._is_selected = TRUE Then 
						Return @(.selected_colors)
					Else
						Return @(.unselected_colors)
					EndIf 
				ElseIf ._class = bcPassive Then 
					If ._is_passive = TRUE Then 
						Return @(.passive_colors)
					Else
						Return @(.enabled_colors) 
					EndIf 
				ElseIf  ._class = bcCommand Then
					If ._is_selected = TRUE Then 
						Return @(.selected_colors) 
					ElseIf ._is_passive = TRUE Then 
						Return @(.passive_colors) 
					ElseIf ._is_enabled = TRUE Then 
						Return @(.enabled_colors)
					Else 
						Return @(.disabled_colors)
					EndIf 
				EndIf 
			End With 
		End Function
		Sub TButton.draw(ByVal pColors As Button_.TButtonColorSet Ptr = 0)
			' 
			With This 
				If pColors = 0 Then
					pColors = ._get_pColors()
				EndIf
				.draw_filled(pColors->back_color)
				.draw_border(pColors->border_color)
			
				Dim As Integer hx = text_x + (8 * (.hotkey_index - 1))
				Dim As String c = Mid(txt, .hotkey_index, 1) 

				..Draw String (text_x, text_y), txt, pColors->text_color
				If .hotkey_index > 0 Then 
					..Draw String (hx, text_y), c, pColors->hotkey_color
				EndIf 
			End With
		End Sub
		Sub TButton.draw_disabled() 
			'
			With This
				._is_selected = FALSE 
				._is_enabled = FALSE 
				.draw()
			End With
		End Sub
		Sub TButton.draw_enabled() 
			'
			With This
				._is_enabled = TRUE  
				.draw()
			End With
		End Sub
		Sub TButton.draw_passive() 
			'
			With This 
				._is_passive = TRUE		' note that this is not how I handled selected or enabled
				.draw()     
			End With
		End Sub
		Sub TButton.draw_unselected() 
			'
			With This
				._is_passive = FALSE 
				._is_selected = FALSE 
				.draw() 
			End With
		End Sub
		Sub TButton.draw_selected()
			'
			With This 
				._is_selected = TRUE 
				.draw() 				
			End With
		End Sub
		Sub TButton.toggle_passive()
			'
			' remember that ._selected takes precedence in the _draw sub 
			With This
				If ._is_passive = TRUE Then 
					._is_passive = FALSE
				Else
					._is_passive = TRUE 
				EndIf
				.draw()
			End With
		End Sub
		Sub TButton.toggle_enabled() 
			' remember that ._selected and ._passive takes precedence in the _draw sub 
			With This
				If ._is_enabled = TRUE Then 
					._is_enabled = FALSE
				Else
					._is_enabled = TRUE 
				EndIf
				.draw()
			End With
		End Sub
		Function TButton.poll(ByRef pnt As TPoint) As boolean
			'
			With This
				If .is_point_in_rect(pnt) = TRUE Then
					If ._is_enabled = TRUE Then  
				 		Return TRUE 
					EndIf
				EndIf 

				Return FALSE 
				
			End With
		End Function

	'========================================================================================================================================
	'========================================================================================================================================
	Type TButtonGroup 
		As Button_.TButton Ptr pButtons(Any)
		As Integer count 
		Declare Sub toggle_button(ByVal pButton As Button_.TButton Ptr)
		Declare Sub Add(ByRef button As Button_.TButton)
		Declare Sub Add(Byval pButton As Button_.TButton Ptr)
	End Type
		'---------------------------------------------------------------------------------------------------------------------------------
		Sub TButtonGroup.toggle_button(ByVal pButton As Button_.TButton Ptr)
			'
			With This 
				For i As Integer = 1 To .count
					If .pButtons(i)->selected = TRUE Then
						If .pButtons(i) <> pButton Then 
							.pButtons(i)->draw_unselected()
						EndIf
					EndIf
				Next
			End With
		End Sub
		Sub TButtonGroup.Add(ByRef button As Button_.TButton)
			'
			With This 
				.count += 1 
				ReDim Preserve .pButtons(1 To .count) 
				.pButtons(count) = @button 
				button.pGroup = @This 
			End With
		End Sub
		Sub TButtonGroup.Add(Byval pButton As Button_.TButton Ptr)
			'
			With This 
				.count += 1 
				ReDim Preserve pButtons(1 To count) 
				pButtons(count) = pButton
				pButton->pGroup = @This  
			End With
		End Sub
		'========================================================================================================================================
		Sub TButton.toggle_selected()
			'
			With This 
				'If ._class = bcGroup Then
				If .pGroup <> 0 Then  
					'Locate 1,1:Print "moooo";timer
					' this radio button is a member of a group therefore only 1 button in the group may be selected at a time
					pGroup->toggle_button(@This)
					'Cls
					'Print "whoops "; __FUNCTION__
				EndIf  
				If ._is_selected = TRUE Then 
					._is_selected = FALSE
				Else
					._is_selected = TRUE 
				EndIf
				.draw()
			End With
		End Sub
		'========================================================================================================================================
	Function draw_separater_bar(ByVal pButton As Button_.TButton Ptr) As Integer 
		' draw separater bar and return the x2 
		'Dim As Button_.TButton Ptr pMb = @(MenuBar_.get_button_by_name("help"))
		Dim As Integer x
		x = pButton->x2 + 1
		Dim As TSeparaterBar sb 
		sb = Type<TRect>(x, pButton->y1,x + 4, pButton->y2)
		sb.clr =  __DARK_BLUEGRAY 
		sb.draw() 
		Return sb.x2 
	End Function 
End Namespace
