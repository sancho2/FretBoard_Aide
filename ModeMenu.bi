'========================================================================================================================================
' ModeMenu.bi
'========================================================================================================================================
#Define __ModeMenu__
'========================================================================================================================================
Namespace ModeMenu_
	'========================================================================================================================================
	Declare Function show(ByRef parent_menu As TGrect) As boolean 
	'Declare Function create_status_button(ByRef txt As Const String, ByVal x As Integer, ByVal key_index As Integer) As TGRect
	Declare Function note_browser() As boolean
 	Declare Function scale_browser() As boolean 
	Declare Sub destroy() 
	Declare Function create_hotspot(ByRef txt As Const String, ByVal x As Integer, ByVal y As Integer, _
									ByVal bounds As TRect, ByVal key_index As Integer = 1, ByVal clr As ULong = pal.RED) As TGRect
	'========================================================================================================================================
	Private Function show(ByRef parent_menu As TGrect) As boolean 
		'
	#Macro __HIDE_ACTION_MENU__()
		' remove menu and replace background
		Put (xx,yy), restore_img, PSet 
		parent_menu.draw_border(pal.BLACK)
	#EndMacro
		' 
		Dim As boolean ret_val 
		Dim As Integer x, y 
		Dim As Integer yy, xx 
		Dim As TGRect hotspots(1 To 5)
		Dim As Any Ptr restore_img  
	
		' 
		x = parent_menu.x1 
		y = parent_menu.y2 + 2 
		'draw menu
		yy = y:xx=x
	
		restore_img = ImageCreate(129, 55,,32)
		Get  (xx,yy)-Step(128, 54), restore_img 
	
		Line (x,y)-Step(128, 54), pal.BLUEGRAY, bf
	
		x+=8: y+=4
		hotspots(1) = create_hotspot("Note Browser", x, y, Type<TRect>(x-8, y-4, x+88, y+13))  
	
		y += 16
		hotspots(2) = create_hotspot("Scale Browser", x, y, Type<TRect>(x-8, y-4, x+88, y+13), 5)  
	
		y += 16  
		hotspots(3) = create_hotspot("Exit", x, y, Type<TRect>(x-8, y-1, x+88, y+13))  
		
		ret_val = TRUE 	
		Dim As String key 
		Dim As TGMouse mouse 
		Do 
			mouse.poll() 
			If mouse.is_button_released(mbLeft) Then 
				' button click
				Dim As TPoint p = Cast(TPoint, mouse) 
				If hotspots(1).is_point_in_rect(p) = TRUE Then				' note browser  
					key = "n"
				ElseIf hotspots(2).is_point_in_rect(p) = TRUE Then 		' scale browser 
					key = "s" 
				ElseIf hotspots(3).is_point_in_rect(p) = TRUE Then 		' scale browser 
					key = "x" 
				Else
					key = ""
				EndIf
			EndIf
			If key="" Then 
				key = InKey()
			EndIf
			Sleep 15, 1
		Loop While key = ""
		Select Case key
			Case "n" 			' show note browser
				__HIDE_ACTION_MENU__()
				note_browser()
				'key = ""
			Case "s" 			' scale browser 
				__HIDE_ACTION_MENU__()
				scale_browser()
			Case "x"
				ret_val = FALSE 
				'key = ""
		End Select
		
		__HIDE_ACTION_MENU__()
		Status_.draw_text("Main Menu") 
	
		ImageDestroy(restore_img) 
		restore_img = 0
		Return ret_val 
	End Function
	
	Private Function create_hotspot(ByRef txt As Const String, ByVal x As Integer, ByVal y As Integer, _
									ByVal bounds As TRect, ByVal key_index As Integer = 1, ByVal clr As ULong = pal.RED) As TGRect
		'
		Dim As TGRect gr 
		gr = Type<TRect>(bounds.x1, bounds.y1, bounds.x2, bounds.y2)
		'gr.draw_filled(pal.BLUEGRAY)
	
		Dim As Integer hx = x + (8 * (key_index - 1))
		Dim As String c = Mid(txt, key_index, 1) 
		Draw String (x, y), txt, pal.CYAN
		Draw String (hx, y), c, pal.RED
	
		Return gr
		'Dim As TRect r = TRect(x-2, STATUS_BAR_TOP, x + 8, STATUS_BAR_TOP + 16)
		'Dim As TRect r = TRect(x-2, y, x + 8, STATUS_BAR_TOP + 16)
		'Draw String (x, STATUS_BAR_TOP), txt, clr
		'Draw String (x, y), txt, clr   
		'Return r 
	End Function
	Private Function note_browser() As boolean
		'
		NoteBrowser_.init()
		NoteBrowser_.main_loop()
		Return FALSE  
	End Function
	Private Function scale_browser() As boolean 
		ScaleBrowser_.init() 
		ScaleBrowser_.main_loop()
		Return FALSE 
	End Function
	Private Sub destroy() Destructor
		'
	End Sub
End Namespace 