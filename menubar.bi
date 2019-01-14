'========================================================================================================================================
' MenuBar.bi
'========================================================================================================================================
#Define __MenuBar__ 
'========================================================================================================================================
Namespace MenuBar_
	'========================================================================================================================================
	'Type TMenuButton As Button_.TButton 
	'========================================================================================================================================
	Declare Function create_button(	ByRef txt As Const String, ByVal x As Integer, _
												ByVal button_class As Button_.TButtonClass = Button_.TButtonClass.bcCommand, _ ' Integer = 1, _ 'Button_.TButtonClass = 1 ,_  'Button_.bcCommand, _
												ByRef id As const String="", ByVal hotkey_index As Integer = 1, _
												ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) ByRef As Button_.TButton 
	Declare Function pGet_button_by_name(ByRef id As Const String) ByRef As Button_.TButton
	Declare Sub remove_button_by_name(ByRef id As Const String)
	Declare Sub destroy()   
	Declare Sub draw_back() 
	'========================================================================================================================================
	'Static Shared As TMenuButton Ptr buttons(Any)
	Static Shared As Button_.TButton Ptr buttons(Any) 
	'========================================================================================================================================
	Function create_button(	ByRef txt As Const String, ByVal x As Integer, _
									ByVal button_class As Button_.TButtonClass = Button_.TButtonClass.bcCommand, _ ' Integer = 1, _ 'Button_.TButtonClass = 1 ,_  'Button_.bcCommand, _
									ByRef id As const String="", ByVal hotkey_index As Integer = 1, _
									ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) ByRef As Button_.TButton
		'
		' lets keep track of these buttons 
		Dim As Integer n = UBound(MenuBar_.buttons) 
		If n < 1 Then 
			n = 1
		Else 
			n += 1
		EndIf
		ReDim Preserve MenuBar_.buttons(1 To n) 
		MenuBar_.buttons(n) = New Button_.TButton(Button_.bcCommand)

		Dim As Button_.TButton Ptr pB = MenuBar_.buttons(n)  
		*pB = Type<TRect>(x-6, MENU_BAR_TOP, x + (8 * Len(txt)) + 4, MENU_BAR_BOTTOM)
		With *pB  
			.name = id 
			.text_x = x 
			.text_y = MENU_BAR_TOP + 6
			.txt = txt 
			.hotkey_index = hotkey_index 
			'.text_color = pal.CYAN 
			'.border_color = pal.BLACK
			'.back_color = pal.BLUEGRAY
			'.hotkey_color = pal.RED
			.enabled = enabled 
			If show_me = TRUE Then
				.draw()
			EndIf
		End With

		Return *(MenuBar_.buttons(n)) 
		
	End Function 
	Function pGet_button_by_name(ByRef id As Const String) ByRef As Button_.TButton
		'
		For i As Integer = 1 To UBound(MenuBar_.buttons) 
			If MenuBar_.buttons(i)->Name = id Then Return *(MenuBar_.buttons(i))  
		Next
		Return *Cast(Button_.TButton Ptr, 0) 
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
				Dim As Button_.TButton Ptr pB = MenuBar_.buttons(i) 
				pB->draw_filled(pB->enabled_colors.back_color)
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
			MenuBar_.buttons(i) = p(i)
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