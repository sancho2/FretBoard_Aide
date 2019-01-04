'========================================================================================================================================
' Notes.bi
'========================================================================================================================================
#Define __Notes__
'========================================================================================================================================
Namespace Notes_
	'========================================================================================================================================
	Type TNoteSet 
		As String * 2 notes(any)
		As Integer count
		Declare Sub add_note(ByRef note As Const String)
		Declare Constructor(ByVal note_count As Integer)
		Declare Constructor() 
		Declare Sub dump()  
	End Type
	'--------------------------------------------------------------------------------------------------------------------------------------
		Constructor TNoteSet():End Constructor 
		Constructor TNoteSet(ByVal note_count As Integer)
			'
			ReDim notes(1 To note_count) 
		End Constructor
		'--------------------------------------------------------------------------------------------------------------------------------------
		Sub TNoteSet.add_note(ByRef note As Const String)
			'
			With This
				ReDim Preserve .notes(0 To .count)
				.count += 1 
				.notes(count - 1) = note 
				'?"ccc "; .count, .notes(count-1)
			End With  
		End Sub
		Sub TNoteSet.dump() 
			For i As Integer = 0 To this.count-1 
				? i & "> " & this.notes(i) &  " <"
			Next
		End Sub
	'========================================================================================================================================
	Dim Shared As String * 2 notes(1 To 12) = {"A ", "A#", "B ", "C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#"}
	'========================================================================================================================================
	Declare Sub create_noteset(ByRef root_note As Const String, ByRef note_set As TNoteSet)
	Declare Sub get_n_notes_from_a(ByRef a As Const String, ByVal n As Integer, ret_val() As string)
	Declare Function _get_note_index(ByRef note As Const String) As integer   
	Declare Function is_valid_note(ByRef s As String) As boolean  
	'========================================================================================================================================
	sub create_noteset(ByRef root_note As Const String, ByRef note_set As TNoteSet)
		'
		Dim As Integer r = _get_note_index(root_note), n, count = UBound(note_set.notes) 
		If r = 0 Then 
			?"Error in "& __FUNCTION__ 
			? "Note > " & root_note & " < not found"
			Sleep 
			End   
		EndIf
			
		While n < count 
			note_set.add_note(notes(r))
			n += 1 
			r += 1 
			If r > 12 Then r = 1
		Wend
	End Sub  
	Sub get_n_notes_from_a(ByRef a As Const String, ByVal n As Integer, ret_val() As string)
		'
		
	End Sub
	Function _get_note_index(ByRef note As Const String) As Integer
		'
		For i As Integer = 1 To 12 
			Dim As String * 2 s  
			LSet s, note
			'? ">";LCase(notes(i));"<", ">";LCase(s);"<", LCase(notes(i)) = LCase(s) 			
			If LCase(notes(i)) = LCase(s) Then Return i 
		Next
		Return 0 
	End Function
 End Namespace 
