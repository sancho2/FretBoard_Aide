'----------------------------------------------------------------------------------------------------------------------------------------
' Guitar.bas
'----------------------------------------------------------------------------------------------------------------------------------------
#Ifndef __Sundry__
	#Include Once "Sundry.bi"
#EndIf 
#Include Once "Notes.bi" 
#Ifndef __PALETTE__	
	#Define __PURPLE			&HFF262144
	#Define __PURPLE_BROWN	&HFF5f4351
	#Define __CYAN 			&HFF91d9f3
	#Define __GRAY				&HFF898989
	#Define __CLAY				&HFFbfb588
	#Define __GREEN 			&HFF6ea92c
#Else 
	#Define __PURPLE			pal.PURPLE
	#Define __PURPLE_BROWN	pal.PURPLE_BROWN
	#Define __CYAN 			pal.CYAN
	#Define __GRAY				pal.GRAY
	#Define __CLAY				pal.CLAY
	#Define __GREEN 			pal.GREEN
#EndIf 
'----------------------------------------------------------------------------------------------------------------------------------------
#Define __FRET_RATIO 1.059463
#Define __RULE_OF_18 17.817153
'----------------------------------------------------------------------------------------------------------------------------------------
Type TString 
	'As TFretNote frets(0 To 21)
	As Notes_.TNoteSet notes
	Declare Sub init(ByRef note As String, ByVal fret_count As integer)
	
	Declare Property note(ByVal fret_number As Integer) As String  
	'Declare Sub copy_from_noteset(ByRef note_set As Notes_) 
End Type
	Property TString.note(ByVal fret_number As Integer) As String
		'
		'Dim As String * 2 s = "  "
		's = notes.notes(fret_number) 
		'Return s
		Return notes.notes(fret_number)   
	End Property

	Sub TString.init(ByRef open_note As String, ByVal fret_count As integer)
		'
		ReDim this.notes.notes(0 To fret_count)
		Notes_.create_noteset(open_note, this.notes)
	End Sub
'----------------------------------------------------------------------------------------------------------------------------------------
'----------------------------------------------------------------------------------------------------------------------------------------
Type TGuitar
	As Any Ptr guitar_img		' guitar image that will be shown and drawn on  
	As Any Ptr _guitar_img 		' guitar image that will be used to restore drawn image
	
	As ULong left_x 				' where the guitar is drawn on the screen 
	As ULong top_y 			
	As ULong Width 
	As ULong height 
	
	As ULong neck_width 
	As ULong fret_count 
	As ULong string_count = 6
	As ULong scale_length 
	As ULong neck_length
	As Integer nut_width 

	As ULong border_color = __PURPLE			''pal.PURPLE
	As ULong fill_color = __PURPLE_BROWN	'pal.PURPLE_BROWN
	As ULong dot_color = __PURPLE				'pal.PURPLE 
	As ULong string_color = __CYAN			'pal.CYAN
	As ULong nut_color = __CLAY				'pal.CLAY
	As ULong fret_color =__GRAY				' pal.GRAY	   
	'--------------------------------------------------
	Declare Constructor()
	Declare Destructor()  
	'-------------------------------------------------- 
	Declare Sub init( ByVal x As ULong, ByVal y As ULong, ByVal nw As ULong, ByVal fc As ULong, _
							ByVal sl As ULong, ByVal nl As ULong, ByVal nuw As ulong)
	Declare Sub Paint() 
	Declare Sub draw_note(ByRef note As Const String, ByVal clr As ULong = &hFFFFFFFF)
	Declare Sub draw_note(ByVal string_number As Integer, ByVal fret_number As Integer, ByVal clr As ULong = &HFFFFFFFF)
	Declare Function get_string_center_y(ByVal string_number As Integer) As Integer 
	Declare function get_fret_x(ByVal fret_number As Integer) As Integer 
	Declare function get_fret_center_x(ByVal fret_number As Integer) As Integer 
	Declare Function is_point_in_hotspot(ByVal pnt As TPoint, ByRef String_number As integer = 0, ByRef fret_number As Integer = 0) As boolean 
	Declare Function get_random_fret(ByVal min As Integer = 0, ByVal max As Integer = -1) As Integer 
	Declare Function get_random_string(ByVal min As Integer = 1, ByVal max As Integer = 6) As Integer
	Declare Function get_note(ByVal string_number As Integer, ByVal fret_number As Integer) As String 
	Declare Sub _draw_hotspots()
	Declare Sub revert(ByRef note As Const String)
	Declare Sub revert(ByVal string_number As Integer, ByVal fret_number As Integer)
	Declare Sub revert()  
	'-------------------------------------------------- 
	Declare Operator Cast() As Any Ptr		' returns guitar_img
	'-------------------------------------------------- 
	Private: 
		Declare Sub _init_image() 
		Declare Sub _init_hotspots()
		Declare Sub _init_strings()
		'-------------------------------------------------- 
		As TString _strings(1 To 6)
		As TRect _hotspots(Any, Any)  
End Type
'----------------------------------------------------------------------------------------------------------------------------------------
	Constructor TGuitar():End Constructor
	Destructor TGuitar() 
		'
		With This 
			If .guitar_img <> 0 Then 
				imagedestroy .guitar_img
				.guitar_img = 0
			EndIf 
			If ._guitar_img <> 0 Then 
				ImageDestroy ._guitar_img 
				._guitar_img = 0
			EndIf
		End With 
	End Destructor
	'-------------------------------------------------- 
	Sub TGuitar.draw_note(ByRef note As Const String, ByVal clr As ULong = &hFFFFFFFF)
		'
		With This 
			For _string As Integer = 1 To 6 
				For _fret As Integer = 0 To .fret_count - 1
					Dim As String s = Trim(.get_note(_string,_fret))
					
					If LCase(note) = lcase(s) Then
						.draw_note(_string, _fret)
					EndIf
				Next
			Next
		End With
	End Sub

	Function TGuitar.get_note(ByVal string_number As Integer, ByVal fret_number As Integer) As String
		'
		With This 
			Return ._strings(string_number).note(fret_number)
		End With
	End Function

	'------------------------------------------------
	Sub TGuitar.paint()
		'
		With This 
			Put (.left_x, .top_y), .guitar_img, PSet 
		End With
	End Sub
	Function TGuitar.is_point_in_hotspot(ByVal pnt As TPoint, ByRef String_number As integer = 0, ByRef fret_number As Integer = 0) As boolean
		'
		With This 
			Dim As Integer minY, maxY, minX, maxX
			minY = ._hotspots(1,0).y1 
			If pnt.y < minY Then Return FALSE 
			maxY = ._hotspots(6,0).y2 
			If pnt.y > maxY Then Return FALSE 
			
			minX = ._hotspots(1,0).x1 
			If pnt.x < minX Then Return FALSE 
			maxX = ._hotspots(1,.fret_count).x2
			If pnt.x > maxX Then Return FALSE  
			
			For i As Integer = 1 To 6
				Dim As Integer x, y 
				If TRange.is_value_in_range(pnt.y, ._hotspots(i,0).y1, ._hotspots(i,0).y2) = TRUE Then 
					For f As Integer = 0 To .fret_count 
						If TRange.is_value_in_range(pnt.x, ._hotspots(i,f).x1, ._hotspots(i,f).x2) = TRUE Then 
							string_number = i: fret_number = f 
							Return TRUE 
						EndIf
					Next
				EndIf
			Next
			Return FALSE 
		End With 
	End Function
	Sub TGuitar._init_strings() 
		'
		Dim As String * 1 s(1 To 6) = {"E", "B", "G", "D", "A", "E"}
		
		For i As Integer = 1 To 6 
			this._strings(i).init(s(i), this.fret_count)
		Next
		
	End Sub
	Sub TGuitar.revert() 
		'
		With This 
			Get ._guitar_img, (0, 0)-(.width-1, .height-1), .guitar_img 
			Paint() 
		End With
	
	End Sub
	Sub TGuitar.revert(ByRef note As Const String)
		'
		With This 
			For _string As Integer = 1 To 6 
				For _fret As Integer = 0 To .fret_count
					Dim As String s = Trim(.get_note(_string,_fret))
					If LCase(note) = lcase(s) Then
						.revert(_string, _fret)
					EndIf
				Next
			Next
		End With 
	End Sub 
