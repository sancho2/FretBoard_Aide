'========================================================================================================================================
' MainMenu.bi
'========================================================================================================================================
#Define __MainMenu__ 
'========================================================================================================================================
Namespace MainMenu_
'========================================================================================================================================
	'========================================================================================================================================
	Declare Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
	Declare Sub	show()
	Declare Sub init() 
	'========================================================================================================================================
'---------------------------------------------------------    
#Define __mode MainMenu_.buttons(1)
#Define __file MainMenu_.buttons(2)
#Define __help MainMenu_.buttons(3) 
'---------------------------------------------------------    
 
	Static Shared As MenuBar_.TMenuButton Ptr buttons(Any) 
	'Static Shared As MenuBar_.TMenuButton menu_btn(1 To 3)  
	'========================================================================================================================================
	Sub init()  
		'
		Dim As Integer x
	
		ReDim MainMenu_.buttons(1 To 3) 
		
		x = MENU_BAR_LEFT
		'x = mb.x2 + 6
		__mode = New MenuBar_.TMenuButton
		*(__mode) = MenuBar_.create_menu_button("Main", x,"mode")
		__mode->enabled = TRUE 

		'x = (MenuBar_.get_button_by_name("add")).x2 + 6
		x = (__mode)->x2 + 6
		__file = New MenuBar_.TMenuButton
		*(__file) = MenuBar_.create_menu_button("File", x,"file")
		__file->enabled = FALSE 

		x = (__file)->x2 + 6
		__help = New MenuBar_.TMenuButton
		*(__help) = MenuBar_.create_menu_button("Help", x,"help")
		__help->enabled = FALSE
	End Sub 

	Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
		'
		' exit button 
		If Main_.exit_btn.hotspot.is_point_in_rect(pnt) Then 
			key = "x"
			Return 
		EndIf
		' main button
		If __mode->is_point_in_rect(pnt) Then
			If __mode->enabled = TRUE Then  
				key = "m"
			EndIf 
			Return
		ElseIf __file->is_point_in_rect(pnt) Then 
			If __file->enabled = TRUE Then 
				key = "f"
			EndIf
		ElseIf __help->is_point_in_rect(pnt) Then 
			If __help->enabled = TRUE Then 
				key = "h"
			EndIf
		EndIf
	End Sub
	Sub show()
		'
		MenuBar_.draw_back()  
		__mode->draw() 
		__file->draw_grey() 
		__help->draw_grey() 

		Dim As String key
		Dim As TGMouse mouse 
		Status_.draw_text("Main Menu")
		Do
			mouse.poll()
			If mouse.is_button_released(mbLeft) Then 
				MainMenu_.poll_buttons(mouse, key)
			EndIf 
			If key = "" Then 
				key = InKey()
			EndIf
			Select Case key 
				Case "m"
					__mode->hilite() 
					If ModeMenu_.show(*(__mode)) = FALSE Then Exit Do 
					__mode->unhilite() 
					key=""
				Case "f"
					? "file menu not handled"
					Sleep
					key=""
				Case "h"
					?"help not handled"
					Sleep 
					key=""
				Case "x"
					Exit Do 
				Case Chr(27) 
				Case Else 
					key = ""
				'Case "x", Chr(27)
				'	Dim As TStatusText s = status_text 
				'	If double_check_exit() = TRUE Then Exit Do
				'	key = ""
				'	draw_status_text(s)  
			End Select
			
			Sleep 15, 1
		Loop While key<>Chr(27) 

	End Sub
	Sub destroy() Destructor 
		'
		If __mode <> 0 Then 
			Delete __mode
			__mode = 0 
		EndIf
		If __file <> 0 Then 
			Delete __file 
			__file = 0
		EndIf
		If __help <> 0 Then 
			Delete __help
			__help = 0 
		EndIf
	End Sub

	
End Namespace 