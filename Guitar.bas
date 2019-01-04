'========================================================================================================================================
' Guitar.bas
'========================================================================================================================================
#Define __guitar__ 
'========================================================================================================================================
#Include Once "guitar.bi"
'========================================================================================================================================
Operator TGuitar.Cast() As Any Ptr 
	Return this.guitar_img 
End Operator
'========================================================================================================================================
Sub TGuitar.init(	ByVal x As ULong, ByVal y As ULong, ByVal nw As ULong, ByVal fc As ULong, _
						ByVal sl As ULong, ByVal nl As ULong, ByVal nuw As ulong)
	'
	With This 
		.left_x = x
		.top_y = y 
		.neck_width = nw 
		.fret_count = fc
		.scale_length = sl
		.neck_length = nl
		.nut_width = nuw   

		ReDim ._hotspots(1 To 6, 0 To .fret_count) 
		._init_image()
		._init_strings()
		._init_hotspots() 
	End With 
End Sub
Function TGuitar.get_fret_center_x(ByVal fret_number As Integer) As Integer
'
	If fret_number = 0 Then Return 18 
	Dim As Integer lf, rf
	lf = this.get_fret_x(fret_number - 1):rf = this.get_fret_x(fret_number)
	Return (rf - lf) \ 2 + lf
End Function 
Function TGuitar.get_string_center_y(ByVal string_number As Integer) As Integer
	'
	With This 
		Dim As Integer n = (.neck_width - (6 * 18)) \ 2, r = (.neck_width Mod 18) \ 2, gap, rem_space
		gap = .neck_width \ 6
		rem_space = (.neck_width Mod (gap * 5)) \ 2
		n = rem_space 
		n += (string_number - 1) * gap 
		Return n
	End With  
End Function
Function TGuitar.get_fret_x(ByVal fret_number As Integer) As Integer
	'
	With This 
		Dim As Integer fret_x = 18
		For i As Integer = 1 To fret_number
			fret_x = (.scale_length - fret_x) \ __RULE_OF_18 + fret_x
		Next
		Return fret_x
	End With 
End Function
Sub TGuitar._init_image() 
	'
	With This 
		Dim As Integer fret_x = 0, fret_count 
		Dim As Integer p = 0 ', w, h
		Dim As Any Ptr Ptr pGuitar = @.guitar_img 
		
		.width = .neck_length + 20
		.height = .neck_width   
	
		*pGuitar = ImageCreate(.width, .height,,32) 		    
		._guitar_img = ImageCreate(.width, .height,,32)

		' fretboard
		Line *pGuitar, (0, 0)-Step(.width-1, .height-1), .border_color, b 
	
		Line *pGuitar, (1,1)-Step(.width-2, .height-2), .fill_color, bf
	
		'dots  todo: the dots are fixed to the current neck width. they need to be sizeable 
		Dim As Integer x, lf, rf
	
		For i As Integer = 3 To 9 Step 2 
			x = get_fret_center_x(i)  
			Circle *pGuitar, (x, 60),12, .dot_color,,,,F
		Next
	
		x = get_fret_center_x(12) 
		Circle *pGuitar, (x, 28),10, .dot_color,,,,F
		Circle *pGuitar, (x, 92),10, .dot_color,,,,F
	
		For i As Integer = 15 To 21 Step 2 
			x = get_fret_center_x(i)  
			Circle *pGuitar, (x, 60),8, .dot_color,,,,F
		Next 
	
		' strings 
		For i As Integer = 1 To 6
			Dim As Integer y = get_string_center_y(i) 
			Line *pGuitar, (18, y)-Step(.neck_length - 1, 0), .string_color 
		Next

		'nut
		Line *pGuitar, (18, 0)-Step( -.nut_width, .neck_width), .nut_color, bf 

		'frets
		fret_x = 18 
		While fret_count < .fret_count
	
			Dim As Integer prev_fret = fret_x
			fret_x = (.scale_length - fret_x) \ __RULE_OF_18 + fret_x
	
			Line *pGuitar, (fret_x, 0)-Step(0, .neck_width), .fret_color ' .DARK_CYAN 
	
			fret_count += 1
		Wend
		
		' copy the image 
		Get *pGuitar, (0,0)-(.width-1, .height-1), ._guitar_img  
	End With 
End Sub
Sub TGuitar._draw_hotspots()
	' draws the hotspots green - adjust s and/or f in for next loop to test
	With This 
		For s As Integer = 1 To 6 Step 2 
			For f As integer = 4 To 4  '.fret_count Step 2
				Line .guitar_img, (_hotspots(s, f).x1, _hotspots(s,f).y1)-(_hotspots(s,f).x2, _hotspots(s,f).y2), pal.GREEN, bf 
			Next
		Next
	End With 
End Sub
Function TGuitar.get_random_fret(ByVal min As Integer = 0, ByVal max As Integer = -1) As Integer 
	'
	If max = -1 Then max = this.fret_count
	Return TRandom.get_rnd(min, max)
End Function
Function TGuitar.get_random_string(ByVal min As Integer = 1, ByVal max As Integer = 6) As Integer
	'
	Return TRandom.get_rnd(min, max) 
End Function
Sub TGuitar._init_hotspots()
	'
	With This 
		For i As Integer = 1 To 6
			Dim As Integer x1, y1, x2, y2 
			'x1 = .left_x - 30: x2 = .left_x -1
			x1 = 0: x2 = .get_fret_x(0) 				
			y1 = .get_string_center_y(i) - 8:y2 = y1 + 16
			._hotspots(i, 0) = Type<TRect>(x1,y1,x2,y2) 
			For f As Integer = 1 To .fret_count
				x1 = .get_fret_x(f - 1) + 1:x2 = .get_fret_x(f) - 1
				._hotspots(i, f) = Type<TRect>(x1,y1,x2,y2) 
			Next
		Next
	End With 
End Sub
Sub TGuitar.revert(ByVal string_number As Integer, ByVal fret_number As Integer) 
	'
	With This 
		Dim As TRect Ptr r = @._hotspots(string_number, fret_number)
		Dim As Integer w,h
		Dim As Any Ptr p  
		w = r->Width 
		h = r->height
		p = ImageCreate(w, h) 
		Get ._guitar_img, (r->x1, r->y1)-(r->x2, r->y2), p 
		Put .guitar_img, (r->x1, r->y1), p, PSet
		ImageDestroy p  
		Paint() 
	End With
End Sub
Sub TGuitar.draw_note(ByVal string_number As Integer, ByVal fret_number As Integer, ByVal clr As ULong = &HFFFFFFFF) 
	'
	With This 
		Dim As Integer x, y
		Dim As String * 2 note  
		x = .get_fret_center_x(fret_number) - 8 ' two chars per note
		If fret_number = 0 Then x -= 8
		y = .get_string_center_y(string_number) - 8 		
		note = ._strings(string_number).note(fret_number)  
		
		Draw String .guitar_img, (x,y), note, clr
		.paint() 
	End With   
End Sub
