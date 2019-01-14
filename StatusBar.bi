'========================================================================================================================================
' Status.bi
'========================================================================================================================================
#Define __Status__
'========================================================================================================================================
#Define __BLACK 			&HFF000000
#Define __BLUEGRAY 		&HFF60748A 
#Define __CYAN 			&HFF91d9f3
#Define __RED 				&HFFdc392d
#Define __GREEN 			&HFF6ea92c
'========================================================================================================================================
Namespace StatusBar_ 
	'========================================================================================================================================
	'Type TStatusText 
	'	As String txt 
	'	As Integer x 
	'	As ULong clr
	'	Declare Constructor 
	'	Declare Constructor(ByRef text As Const String, ByVal left_x As Integer, ByVal text_color As ULong)   
	'End Type
	'---------------------------------------------------------------------------------------------------------------------------------------
	 	'Constructor TStatusText():End Constructor
	 	'Constructor TStatusText(ByRef text As Const String, ByVal left_x As Integer, ByVal text_color As ULong)
	 	'	'
	 	'	With This 
	 	'		.txt = text
	 	'		.x = left_x 
	 	'		.clr = text_color 
	 	'	End With
	 	'End Constructor
	'========================================================================================================================================
	Type TStatusButton As Button_.TButton 
	'========================================================================================================================================
	'Declare Sub draw_text overload(ByRef stxt As Const TStatusText, ByVal wipe As boolean = TRUE) 
	Declare Sub draw_text(ByRef txt As Const String, ByVal x As Integer = -1, ByVal clr As ULong = pal.CLAY, ByVal wipe As boolean = TRUE ) 
	Declare Sub draw_status_bar() 
	Declare Sub init(ByRef rect As TRect, ByRef client As TRect)

	Declare Function create_button(	ByRef txt As Const String, ByVal x As Integer, _
												ByVal button_class As Button_.TButtonClass = Button_.TButtonClass.bcCommand, _ 'Integer = 1, _ '_Button_.TButtonClass = 1 ,_  'Button_.bcCommand, _
												ByRef id As const String="", ByVal hotkey_index As Integer = 1, _
												ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) As Button_.TButton ptr

	Declare Sub teststatus()
	Declare Sub destroy()
	'========================================================================================================================================
	'Static Shared As TStatusText status_text
	Static Shared As TRect Ptr _pRect
	Static Shared As TRect Ptr _pClient 	

	Static Shared As TStatusButton Ptr buttons(Any)  
	'========================================================================================================================================
	Private Sub teststatus()
		Line (0, STATUS_CLIENT_top)-Step(1000, 0), __GREEN
		Line (0, STATUS_CLIENT_BOTTOM)-Step(1000, 0), __GREEN
		
	End Sub
	Sub destroy() 
		If StatusBar_._pRect <> 0 Then Delete StatusBar_._pRect 
		StatusBar_._pRect = 0 
		If StatusBar_._pClient <> 0 Then Delete StatusBar_._pClient 
		StatusBar_._pClient = 0 
		For i As Integer = 1 To UBound(StatusBar_.buttons) 
			If StatusBar_.buttons(i) <> 0 Then 
				Delete StatusBar_.buttons(i)
				StatusBar_.buttons(i) = 0 
			EndIf
		Next
		ReDim StatusBar_.buttons(0 To 0)
		
	End Sub
	Sub init(ByRef rect As TRect, ByRef client As TRect)
		'
		StatusBar_._pRect = New TRect
		*(StatusBar_._pRect) = rect 
		StatusBar_._pClient = New TRect 
		*(StatusBar_._pClient) = client 		  
		draw_status_bar() 
	End Sub
	Sub Clear_status_bar(ByVal x1 As Integer = -1, ByVal x2 As Integer = STATUS_CLIENT_RIGHT + 1)
		If x1 < 0 Then x1 = STATUS_CLIENT_LEFT - 4  
		Line (x1, STATUS_CLIENT_TOP)-(x2, 259), pal.BLACK, bf
	End Sub
	
	'Private Sub draw_text(ByRef stxt As Const TStatusText, ByVal wipe As boolean = TRUE) 
	'	'
	'	draw_text(stxt.txt, stxt.x, stxt.clr, wipe) 
	'End Sub
	Private Sub draw_text(ByRef txt As Const String, ByVal x As Integer = -1, ByVal clr As ULong = pal.CLAY, ByVal wipe As boolean = TRUE ) 
		'
		Dim As Integer y = 240
		If wipe = TRUE Then 
			Line(54, 233)-step(860, 26), __BLACK, bf
			'status_text = Type<TStatusText>(txt, x, clr)  
		EndIf  
		If x = 0 Then x = (StatusBar_._pClient)->x1 
		If x < 0 Then 
			x = (870 - (Len(txt) * 8)) \ 2 
			x += (StatusBar_._pClient)->x1		' STATUS_CLIENT_LEFT	 'Main_._pGuitar->left_x 
		EndIf
		Draw String (x, y), txt, clr
	End Sub
	Sub draw_status_bar() 
		'
		'Dim As ULong l = 230
		Dim As TRect Ptr pR = StatusBar_._pRect

		'Line (50,l)-(920,32), pal.DARK_BLUEGRAY, b
		Line (pR->x1,pR->y1)-(pR->x2,pR->y2), __DARK_BLUEGRAY, b
		'Line (51,l+1)-Step(918,30), pal.DARK_BLUEGRAY, b
		Line (pR->x1+1,pR->y1+1)-(pR->x2-1,pR->y2-1), __DARK_BLUEGRAY, b
		'Line (52,l+2)-Step(916,28), pal.DARK_BLUEGRAY, b
		Line (pR->x1+2,pR->y1+2)-(pR->x2-2,pR->y2-2), __DARK_BLUEGRAY, b
		
	End Sub

	'Private Function create_status_button(ByRef txt As Const String, ByVal x As Integer, _
	'												ByRef id As const String="", ByVal hotkey_index As Integer = 1, _
	'												ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) ByRef As Button_.TButton()
	'	'
	'	'Dim As TGRect gr 
	'	'gr = Type<TRect>(x-4, STATUS_CLIENT_TOP-6, x + (8 * Len(txt)) + 4, STATUS_CLIENT_TOP + 18)
	'	'gr.draw_filled(pal.BLUEGRAY)
	'
	'	'Dim As Integer hx = x + (8 * (hotkey_index - 1))
	'	'Dim As String c = Mid(txt, hotkey_index, 1) 
	'	'Draw String (x, STATUS_CLIENT_TOP), txt, pal.CYAN
	'	'Draw String (hx, STATUS_CLIENT_TOP), c, pal.RED
	'
	'	'Return gr
	'	Dim As TGRect gr 
	'	
	'	Return gr 
	'	
	'End Function
	Private Function create_button(	ByRef txt As Const String, ByVal x As Integer, _
												ByVal button_class As Button_.TButtonClass = Button_.TButtonClass.bcCommand, _ ' Integer = 1, _ 'Button_.TButtonClass = 1 ,_  'Button_.bcCommand, _
												ByRef id As const String="", ByVal hotkey_index As Integer = 1, _
												ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) As Button_.TButton Ptr 
		'
		' lets keep track of these buttons 
		Dim As Integer n = UBound(StatusBar_.buttons) 
		If n < 1 Then 
			n = 1
		Else 
			n += 1
		EndIf
		ReDim Preserve StatusBar_.buttons(1 To n) 
		StatusBar_.buttons(n) = New Button_.TButton(button_class) 
		Dim As Button_.TButton Ptr pB = StatusBar_.buttons(n)  
		*pB = Type<TRect>(x-6, STATUS_CLIENT_TOP, x + (8 * Len(txt)) + 4, (StatusBar_._pClient)->y2) 'STATUS_CLIENT_BOTTOM)
		With *pB  
			.name = id 
			.text_x = x 
			'.text_y = MENU_BAR_TOP + 6
			.text_y = STATUS_CLIENT_TOP + 6
			.txt = txt 
			.hotkey_index = hotkey_index

			'With .enabled_colors 
			'	.text_color = __CYAN	'pal.CYAN 
			'	.border_color = __BLACK
			'	.back_color = __BLUEGRAY	'pal.BLUEGRAY
			'	.hotkey_color = __RED		'pal.RED
			'End With 
			'With .selected_colors 
			'	.text_color = __CYAN	'pal.CYAN 
			'	.border_color = __BLACK
			'	.back_color = __BLUEGRAY	'pal.BLUEGRAY
			'	.hotkey_color = __RED		'pal.RED
			'End With 
			
			.enabled = enabled 
'Locate 2,1: ?"[[[[[[[[[[[[[[}"; id:Sleep 
			If show_me = TRUE Then
				.draw()
			EndIf
		End With
		Return StatusBar_.buttons(n) 
		
	End Function 


End Namespace

