'========================================================================================================================================
' Graphics.bi
'========================================================================================================================================
'========================================================================================================================================
Sub draw_guitar() 
	' 
	__dim_guitar_ptr 
	Put(GUITAR_LEFT_X, GUITAR_TOP_Y), *pGtr, PSet 
End Sub
Sub Clear_status_bar(ByVal x1 As Integer = -1, ByVal x2 As Integer = STATUS_BAR_RIGHT + 1)
	If x1 < 0 Then x1 = STATUS_BAR_LEFT - 4  
	Line (x1, STATUS_BAR_TOP)-(x2, 259), pal.BLACK, bf
End Sub
Sub draw_info_bar() 
	' 
	Dim As Integer l = 42 
	Dim As Integer x = 328,y = 32
	
	'set  
	Color pal.SAND
	Draw String (x+1, y+1), "Set:", pal.DARK_BLUEGRAY
	Draw String (x, y), "Set:", pal.CLAY

	'round 
	l += 8: x += 64 
	Draw String (x, y), "Round:", pal.CLAY  

	'course 
	l += 10: x += 80 
	Draw String (x,y), "Course: ", pal.CLAY

	'score
	l += 12: x += 88 
	Draw String (x,y), "Score:", pal.CLAY

	'skill 
	l += 14: x += 120
	Draw String (x,y), "Skill:", pal.CLAY
	Locate 3, l + 7:Print "Accomplished"
	
End Sub
Sub update_info_bar()
	' todo: update this
	'Dim As Integer l = 42
	'
	'' set
	'Locate 3, l + 5:Print Str(pGame->set_number)
	'' round
	'l += 8 
	'Locate 3, l + 7:Print Str(pGame->round_number)
	''course
	'l += 10 
	'Locate 3, l + 8:Print str(pGame->course_number)
	''score
	'l += 12 
	'Locate 3, l + 6:Print Using "\     \"; zero_prefix_number(pGame->player.score)
	''skill 
	'l += 14
	'Locate 3, l + 7:Print Using "\          \";get_skill_level() 
	'
	'draw_status_text(pGame->state) 		
End Sub
Sub draw_shadow(	ByRef txt As Const String, ByVal x As Integer, ByVal y As Integer, _
						ByVal fore_clr As ULong, ByVal shadow_clr As ULong, ByVal depth As Integer = 1)
	'
	For i As Integer = depth To 1 Step -1 
		Draw String (x + i, y + i), txt, shadow_clr 
	Next
	Draw String (x, y), txt, fore_clr
End Sub
Sub draw_title() 
	'
	Dim As Integer l = _guitar.left_x, y = 32
	draw_shadow("FretBoard-Aide", l +14, y, pal.CYAN, pal.DARK_BLUEGRAY, 2) 

	'Draw String (l + 808, y+2),"Sancho 0.01a", pal.DARK_BLUEGRAY  
	'Draw String (l + 807, y+1),"Sancho 0.01a", pal.DARK_BLUEGRAY
	'Draw String (l + 806, y),"Sancho 0.01a", pal.CYAN
	draw_shadow("Sancho 0.01", l +806, y, pal.CYAN, pal.DARK_BLUEGRAY, 2)   
	Line (50,y - 8) -Step(920,32), pal.DARK_BLUEGRAY, b
	Line (51,y - 7)-Step(918,30), pal.DARK_BLUEGRAY, b
	Line (52,y - 6)-Step(916,28), pal.DARK_BLUEGRAY, b
End Sub
'-------------------------------------------------------------------------------------------------------------------------------------------



