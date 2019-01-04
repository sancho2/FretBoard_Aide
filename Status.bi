'========================================================================================================================================
' Status.bi
'========================================================================================================================================
#Define __Status__
'========================================================================================================================================
Namespace Status_ 
	'========================================================================================================================================
	Type TStatusText 
		As String txt 
		As Integer x 
		As ULong clr
		Declare Constructor 
		Declare Constructor(ByRef text As Const String, ByVal left_x As Integer, ByVal text_color As ULong)   
	End Type
	'---------------------------------------------------------------------------------------------------------------------------------------
	 	Constructor TStatusText():End Constructor
	 	Constructor TStatusText(ByRef text As Const String, ByVal left_x As Integer, ByVal text_color As ULong)
	 		'
	 		With This 
	 			.txt = text
	 			.x = left_x 
	 			.clr = text_color 
	 		End With
	 	End Constructor
	'========================================================================================================================================
	Type TStatusButton extends TGRect
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
		Declare Operator Let(ByRef rhs As Const TRect)
		Declare Sub Draw()
		Declare Sub draw_grey()   
		Private: 
			As boolean _is_enabled 
	End Type
		Property TStatusButton.enabled() As boolean
			'
			Return this._is_enabled 
		End Property
		Property TStatusButton.enabled(ByVal value As boolean)
			'
			this._is_enabled = value 
		End Property
		'-------------------------------------------------------------------------------------------------------------------------------------
		Operator TStatusButton.Let(ByRef rhs As Const TRect) 
			Cast(TRect, This) = rhs  
		End Operator
		'-------------------------------------------------------------------------------------------------------------------------------------
		Sub TStatusButton.unhilite() 
			'
			this.draw_border(this.border_color) 
		End Sub
		Sub TStatusButton.hilite() 
			'
			this.draw_border(pal.WHITE) 
		End Sub
		Sub TStatusButton.draw_grey() 
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
		Sub TStatusButton.Draw()
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
	Declare Sub draw_text overload(ByRef stxt As Const TStatusText, ByVal wipe As boolean = TRUE) 
	Declare Sub draw_text(ByRef txt As Const String, ByVal x As Integer = -1, ByVal clr As ULong = pal.CLAY, ByVal wipe As boolean = TRUE ) 
	Declare Sub draw_status_bar() 
	Declare Sub init()
	Declare Function create_status_button(ByRef txt As Const String, ByVal x As Integer, ByVal key_index As Integer) As TGRect
	Declare Sub teststatus()
	'========================================================================================================================================
	Static Shared As TStatusText status_text	
	Static Shared As TStatusButton Ptr buttons(Any)  
	'========================================================================================================================================
	Sub teststatus()
		Line (0, STATUS_BAR_top)-Step(1000, 0), pal.GREEN
		Line (0, STATUS_BAR_BOTTOM)-Step(1000, 0), pal.GREEN
		
	End Sub

	Sub init()
		' 
		draw_status_bar() 
	End Sub
	Sub draw_text(ByRef stxt As Const TStatusText, ByVal wipe As boolean = TRUE) 
		'
		draw_text(stxt.txt, stxt.x, stxt.clr, wipe) 
	End Sub
	Sub draw_text(ByRef txt As Const String, ByVal x As Integer = -1, ByVal clr As ULong = pal.CLAY, ByVal wipe As boolean = TRUE ) 
		'
		Dim As Integer y = 240
		If wipe = TRUE Then 
			Line(54, 233)-step(860, 26), pal.BLACK, bf
			status_text = Type<TStatusText>(txt, x, clr)  
		EndIf  
		If x = 0 Then x = STATUS_BAR_LEFT 
		If x < 0 Then 
			x = (870 - (Len(txt) * 8)) \ 2 
			x += _guitar.left_x 
		EndIf
		Draw String (x, y), txt, clr
	End Sub
	Sub draw_status_bar() 
		'
		Dim As Integer l = 230
		Color , pal.BLUEGRAY
		Line (50,l)-Step(920,32), pal.DARK_BLUEGRAY, b
		Line (51,l+1)-Step(918,30), pal.DARK_BLUEGRAY, b
		Line (52,l+2)-Step(916,28), pal.DARK_BLUEGRAY, b
		
		'draw_text("123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789", 54)		 
	End Sub

	Function create_status_button(ByRef txt As Const String, ByVal x As Integer, ByVal key_index As Integer) As TGRect
		'
		'Dim As TGRect gr 
		'gr = Type<TRect>(x-4, STATUS_BAR_TOP-6, x + (8 * Len(txt)) + 4, STATUS_BAR_TOP + 18)
		'gr.draw_filled(pal.BLUEGRAY)
	
		'Dim As Integer hx = x + (8 * (key_index - 1))
		'Dim As String c = Mid(txt, key_index, 1) 
		'Draw String (x, STATUS_BAR_TOP), txt, pal.CYAN
		'Draw String (hx, STATUS_BAR_TOP), c, pal.RED
	
		'Return gr
		Dim As TGRect gr 
		
		Return gr 
		
	End Function
	Function create_button(ByRef txt As Const String, ByVal x As Integer, _
													ByRef id As const String="", ByVal key_index As Integer = 1, _
													ByVal enabled As boolean = TRUE, ByVal show_me As boolean = TRUE) ByRef As Status_.TStatusButton
		'
		' lets keep track of these buttons 
		Dim As Integer n = UBound(Status_.buttons) 
		If n < 1 Then 
			n = 1
		Else 
			n += 1
		EndIf
		ReDim Preserve Status_.buttons(1 To n) 
		Status_.buttons(n) = New Status_.TStatusButton

		Dim As Status_.TStatusButton Ptr pB = Status_.buttons(n)  
		*pB = Type<TRect>(x-6, STATUS_BAR_TOP, x + (8 * Len(txt)) + 4, STATUS_BAR_BOTTOM)
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

		Return *(Status_.buttons(n)) 
		
	End Function 


End Namespace

