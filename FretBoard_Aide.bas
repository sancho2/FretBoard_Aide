'=======================================================================================================================================
' Main.bas
'=======================================================================================================================================
#Define __main__ 
'=======================================================================================================================================
Const As ULong GUITAR_NECK_LENGTH = 900, GUITAR_LEFT_X = 50, GUITAR_TOP_Y = 84, GUITAR_FRET_COUNT = 22, GUITAR_NECK_WIDTH = 121, _
 					GUITAR_NUT_WIDTH = 5, SCALE_LENGTH = 1300, SKILL_COUNT = 28  
Const As ULong DEFAULT_SET_ROUND_COUNT = 5, DEFAULT_ROUND_COURSE_COUNT = 12, DEFAULT_MATCH_SET_COUNT = 3
Const As ULong GAME_BUTTON_LEFT = 220
Const As Double PHASE_1_TIME = 10, PHASE_2_TIME = 30, PHASE_3_TIME = 50
Const As ULong MENU_BAR_TOP = 27, MENU_BAR_BOTTOM = 53, MENU_BAR_LEFT = 220, MENU_BAR_RIGHT = 840
Const As ULong STATUS_BAR_LEFT = 58, STATUS_BAR_TOP = 233, STATUS_BAR_RIGHT = 914, STATUS_BAR_BOTTOM = 259  
'---------------------------------------------------------------------------------------------------------------------------------------
#Define __dim_guitar_ptr Dim As TGuitar Ptr pGtr = @Main_._guitar

#Macro __get_rand_string_fret(T)
	__string = T##_guitar.get_random_string()
	__fret = T##_guitar.get_random_fret() 
#EndMacro
#Macro  __dim_string_fret()
	Dim As Integer __string, __fret
#EndMacro
'=======================================================================================================================================
#Ifndef __data__
	#Include Once "data.bi"  
#EndIf 
#Ifndef __guitar__
	#Include Once "guitar.bas"  
#EndIf 
#Ifndef __sundry
	#Include Once "sundry.bi"
#EndIf 
'=======================================================================================================================================
Namespace Main_ 

	'========================================================================================================================================
	Type TGRect extends TRect
		Declare Sub draw_border(ByVal clr As ULong)
		Declare Sub draw_filled(ByVal clr As ULong)
		Declare Constructor()
		Declare Operator Let(ByRef rhs As TRect)   
	End Type
	'---------------------------------------------------------------------------------------------------------------------------------------
		Constructor TGRect():End Constructor
		'---------------------------------------------------------------------------------------------------------------------------------------
		Operator TGRect.Let(ByRef rhs As TRect)
			'
			Cast(TRect, This) = rhs '(rhs.x1, rhs.y1, rhs.x2, rhs.y2)
		End Operator
		'---------------------------------------------------------------------------------------------------------------------------------------
		Sub TGRect.draw_border(ByVal clr As ULong)
			'
			With This
				Line (.x1, .y1)-(.x2, .y2), clr, b
			End With
		End Sub
		Sub TGRect.draw_filled(ByVal clr As ULong)
			'
			With This
				Line (.x1, .y1)-(.x2, .y2), clr, bf
			End With
		End Sub
	'========================================================================================================================================
	Type TGMouse extends TMouse
		Declare Operator Cast() As TPoint 
	End Type
	'---------------------------------------------------------------------------------------------------------------------------------------
		Operator TGMouse.Cast() As TPoint 
			Return Type<TPoint>(this.x, this.y)
		End Operator
	'========================================================================================================================================
	Type TButton
		As TGRect hotspot
	End Type
	'========================================================================================================================================
	' graphics.bi declarations 
	Declare Sub init_exit_button()
	Declare Sub draw_guitar() 
	Declare Sub draw_info_bar() 
	Declare Sub update_info_bar()
	Declare Sub draw_shadow(	ByRef txt As Const String, ByVal x As Integer, ByVal y As Integer, _
							ByVal fore_clr As ULong, ByVal shadow_clr As ULong, ByVal depth As Integer = 1)
	Declare Sub draw_title() 
	Declare Sub show()
	'----------------------------------------------------------------------------------------------
	' game declarations 
	Declare Sub init() 
	Declare Sub main_loop()
	Declare Sub on_exit()
	'=======================================================================================================================================
	Dim Shared As TGuitar _guitar
	Static Shared As TButton exit_btn 
	'=======================================================================================================================================
	#Include Once "status.bi"
	#Include Once "menubar.bi" 
	#Include Once "notebar.bi"
	#Include Once "graphics.bi"
	#Include Once "NoteBrowser.bi"
	#Include Once "scalebrowser.bi"
	#Include Once "ModeMenu.bi"
	#Include Once "mainmenu.bi"
	'=======================================================================================================================================
	Sub init()
		'
		Cls 
		__dim_guitar_ptr
		
		pGtr->init(GUITAR_LEFT_X, GUITAR_TOP_Y, GUITAR_NECK_WIDTH, GUITAR_FRET_COUNT, SCALE_LENGTH, GUITAR_NECK_LENGTH, GUITAR_NUT_WIDTH)

		draw_title()
		Status_.init() 
		init_exit_button()
		draw_guitar()
	End Sub
	Sub init_exit_button()
		Dim As Integer x = 916, y = 234
		Line (x, y)-Step(50,24), pal.BLUEGRAY, bf   
		Status_.draw_text("Exit", 926, pal.CYAN)
		Status_.draw_text("x", 934, pal.RED)
	
		exit_btn.hotspot = Type<TRect>(x, y, x+50, y+24)
	End Sub
	Sub on_exit() Destructor
		? "destructor"
	End Sub

End Namespace 
'=======================================================================================================================================
'__graphics(s)
__graphics()  	
Main_.init()
Main_.MainMenu_.init() 
Main_.MainMenu_.show()
?"end" 

