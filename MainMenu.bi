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
 
	Static Shared As Button_.TButton Ptr buttons(Any) 
	'========================================================================================================================================
	Sub init()  
		'
		Dim As Integer x
	
		ReDim MainMenu_.buttons(1 To 3) 
		
		x = MENU_BAR_LEFT
		__mode = New Button_.TButton(Button_.TButtonClass.bcCommand)
		*(__mode) = MenuBar_.create_button("Main", x,,"mode",,,FALSE)

		x = (__mode)->x2 + 6
		__file = New Button_.TButton(Button_.TButtonClass.bcCommand)
		*(__file) = MenuBar_.create_button("File", x,,"file",,FALSE, FALSE)

		x = (__file)->x2 + 6
		__help = New Button_.TButton(Button_.TButtonClass.bcCommand)
		*(__help) = MenuBar_.create_button("Help", x,,"help",,FALSE, FALSE)

	End Sub 

	Sub poll_buttons(ByRef pnt As TPoint, ByRef key As String)
		'
		' exit button 
		If Main_.pExit_btn->is_point_in_rect(pnt) Then 
			key = "x"
			Return 
		EndIf
		' main button
		If __mode->poll(pnt) = TRUE Then 
			key = "m"
			Return 
		ElseIf __file->poll(pnt) = TRUE Then 
			key = "f"
			Return 
		ElseIf __help->poll(pnt) = TRUE Then 
			key = "h"
			Return 
		EndIf
	End Sub
	Sub show()
		'
		MenuBar_.draw_back()  
		__mode->draw()
		__file->Draw()
		__help->Draw() 

		Dim As String key
		Dim As TGMouse mouse 
		StatusBar_.draw_text("Main Menu")
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
					'__mode ->hilite()
					__mode->draw_selected() 
					If ModeMenu_.show(*(__mode)) = FALSE Then Exit Do 
					'__mode->unhilite()
					__mode->draw_unselected()  
					key=""
				Case "f"
					If __file->enabled = TRUE Then 
						? "file menu not handled"
						Sleep
					EndIf 
					key=""
				Case "h"
					If __help->enabled = TRUE Then 
						?"help not handled"
						Sleep
					End If  
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