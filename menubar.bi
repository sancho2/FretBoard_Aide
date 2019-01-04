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