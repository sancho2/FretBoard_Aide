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
Const As ULong STATUS_CLIENT_LEFT = 58, STATUS_CLIENT_TOP = 233, STATUS_CLIENT_RIGHT = 914, STATUS_CLIENT_BOTTOM = 260
Const As ULong STATUS_BAR_LEFT = 50, STATUS_BAR_TOP = 230, STATUS_BAR_RIGHT = 971, STATUS_BAR_BOTTOM = 263   
'---------------------------------------------------------------------------------------------------------------------------------------
'#Define __dim_guitar_ptr Dim As TGuitar Ptr pGtr = @Main_._guitar
#Define __dim_guitar_ptr Dim As TGuitar Ptr pGtr = Main_._pGuitar
'---------------------------------------------------------------------------------------------------------------------------------------
#Define __NBCLEAR 	NoteBrowser_.pClear_btn
'---------------------------------------------------------------------------------------------------------------------------------------
#Define __SBCLEAR 	ScaleBrowser_.pClear_btn
#Define __MAJOR 		ScaleBrowser_.major_btn
#Define __MINOR 		ScaleBrowser_.minor_btn
#Define __HARMONIC 	ScaleBrowser_.harmonic_btn
#Define __MELODIC		ScaleBrowser_.melodic_btn
'---------------------------------------------------------------------------------------------------------------------------------------


#Macro  __dim_string_fret()
	Dim As Integer __string, __fret
#EndMacro
'=======================================================================================================================================
#Include Once "Sundry.bi"
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
		Private Sub TGRect.draw_border(ByVal clr As ULong)
			'
			With This
				Line (.x1, .y1)-(.x2, .y2), clr, b
			End With
		End Sub
		Private Sub TGRect.draw_filled(ByVal clr As ULong)
			'
			With This
				Line (.x1, .y1)-(.x2, .y2), clr, bf
			End With
		End Sub
'========================================================================================================================================
	Type TSeparaterBar extends TRect 
		As ULong clr 
		Declare Sub Draw() 
		Declare Operator Let(ByRef rhs As TRect)   
	End Type
		Sub TSeparaterBar.draw()
			With This 
				Line(.x1, .y1)-(.x2,.y2), .clr, bf 
			End With 
		End Sub
		Operator TSeparaterBar.Let(ByRef rhs As TRect)
			'
			Cast(TRect, This) = rhs '(rhs.x1, rhs.y1, rhs.x2, rhs.y2)
		End Operator
'========================================================================================================================================
#Include Once "Palette.bi"
#Include Once "Button.bi"
'#Include Once "Data.bi"  
#Include Once "Guitar.bas"  
'=======================================================================================================================================
Namespace Main_ 

	'=======================================================================================================================================
	Static Shared As TGuitar Ptr _pGuitar
	'Static Shared As TGRect Ptr pExit_btn
	Static Shared As Button_.TButton Ptr pExit_btn 
	'========================================================================================================================================
	
	'========================================================================================================================================
	Type TGMouse extends TMouse
		Declare Operator Cast() As TPoint 
	End Type
	'---------------------------------------------------------------------------------------------------------------------------------------
		Operator TGMouse.Cast() As TPoint 
			Return Type<TPoint>(this.x, this.y)
		End Operator
	'========================================================================================================================================
	'Type TButton
	'	As TGRect hotspot
	'End Type
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
	'----------------------------------------------------------------------------------------------
	' forward declarations 
	'----------------------------------------------------------------------------------------------
	Namespace PrimaryMenu_
		Declare Sub enable_menu() 
		Declare Sub disable_menu()
	End Namespace
	'----------------------------------------------------------------------------------------------
	'=======================================================================================================================================
	#Include Once "StatusBar.bi"
	#Include Once "MenuBar.bi" 
	#Include Once "NoteBar.bi"
	#Include Once "PatternBar.bi"
	#Include Once "NoteBrowser.bi"
	#Include Once "ScaleBrowser.bi"
	#Include Once "MainMenu.bi"
	#Include Once "PrimaryMenu.bi"
	'=======================================================================================================================================
	'=======================================================================================================================================
	#Include Once "Graphics.bi"
	'=======================================================================================================================================
	Private Sub init()
		'
		Cls 
		Main_._pGuitar = New TGuitar 
		__dim_guitar_ptr
		
		pGtr->init(GUITAR_LEFT_X, GUITAR_TOP_Y, GUITAR_NECK_WIDTH, GUITAR_FRET_COUNT, SCALE_LENGTH, GUITAR_NECK_LENGTH, GUITAR_NUT_WIDTH)

		draw_title()
		Dim As TRect _ 
		r = Type<Trect>(STATUS_BAR_LEFT, STATUS_BAR_TOP, STATUS_BAR_RIGHT, STATUS_BAR_BOTTOM), _ 
		c = Type<Trect>(STATUS_CLIENT_LEFT, STATUS_CLIENT_TOP, STATUS_CLIENT_RIGHT, STATUS_CLIENT_BOTTOM) 
		StatusBar_.init(r, c) 
		init_exit_button()
		draw_guitar()
	End Sub
	Private Sub init_exit_button()
		Dim As Integer x = 932
		Main_.pExit_btn = StatusBar_.create_button("Exit", x, Button_.TButtonClass.bcCommand, "exit", 2)
	End Sub
	Private Sub on_exit() Destructor
		If Main_.pExit_btn <> 0 Then
			Delete Main_.pExit_btn 
			Main_.pExit_btn = 0
		EndIf
		? "destructor"
	End Sub

End Namespace 
'=======================================================================================================================================
'__graphics(s)
__graphics()  	
Main_.init()
Main_.PrimaryMenu_.init() 
Main_.PrimaryMenu_.show()
cls
?"end" 
'Sleep 

