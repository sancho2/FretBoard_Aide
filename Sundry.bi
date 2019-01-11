'--------------------------------------------------------------------------------
' RMapSundry.bi
'--------------------------------------------------------------------------------
#Define __Sundry__
Const As Long SC_LSHIFT = &H2A, _
				  SC_RSHIFT = &H36, _
				  SC_LEFT = &H4B, _
				  SC_RIGHT = &H4D, _ 
				  SC_HOME = &H47, _
				  SC_END = &H4F
'--------------------------------------------------------------------------------
#Define EXTCHAR  Chr(255)
#Define _CHAR_WIDTH 8 
#Define _CHAR_HEIGHT 16 
''--------------------------------------------------------------------------------
'#Include Once "SortedString.bi"
#Include once "Mouse.bi"
'#Include Once "multikey.bi"
'--------------------------------------------------------------------------------
#Ifndef GFX_FULLSCREEN 
	#Define GFX_FULLSCREEN 1 
#EndIf
'--------------------------------------------------------------------------------
#Define HiDWord(e)   ( CULng( ( CULngInt( (e) ) And &hFFFFFFFF00000000ull ) Shr 32 ) ) ' return Type=ULong
#Define LoDWord(e)   ( CULng( CULngInt( (e) ) And &h00000000FFFFFFFFull ) )  ' return Type=ULong
'--------------------------------------------------------------------------------
Type TRandom 
	Declare Static Function get_rnd(ByVal min As Integer, ByVal max As Integer) As Integer
	Declare Constructor()
	Declare Constructor(ByVal seed As Integer)
	Declare Property is_initialized() As boolean 
	Private:    
		As boolean _is_init
End Type
	Constructor TRandom()
		'
		Randomize Timer
		this._is_init = TRUE  
	End Constructor
	Constructor TRandom(ByVal seed As Integer)
		'
		Randomize seed
		this._is_init = TRUE  
	End Constructor
	Private Function TRandom.get_rnd(ByVal min As Integer, ByVal max As Integer) As Integer
		'
		Return Int(Rnd * (max - min + 1) + min) 
	End Function
'--------------------------
Union char_ref  
	As UByte n 
	As String * 1 c  
End Union
'--------------------------
Union color_ref 
	As Ulong value 
	Type 
		As Ubyte blue 
		As Ubyte green 
		As Ubyte red 
		As Ubyte a 
	End Type 
End Union 
'--------------------------
Type TVector2d
	As ulong x
	As Ulong y 
End Type
'--------------------------
Type TPoint extends TVector2D
	Declare Constructor()
	Declare Constructor (ByVal _X As ULong, ByVal _Y As ULong)
End Type
'--------------------------
	Constructor TPoint():End Constructor 
	Constructor TPoint(ByVal _X As ULong, ByVal _Y As ULong)
		'
		this.X = _X 
		this.Y = _Y
	End Constructor
'--------------------------
#Include Once "Range.bas"
'--------------------------
'-----------------------------------------------------------------------------------------------------------	
Type TRect 
	As Ulong x1 
	As Ulong y1
	As Ulong x2 
	As Ulong y2
	Declare Sub vert_shift(Byval amount As ulong)
	Declare Sub horiz_shift(Byval amount As Ulong) 
	Declare Function is_point_in_rect(Byref value As TVector2d) As Boolean 
	Declare Operator +=(Byref rhs As TVector2d) 
	Declare Property Width() as Ulong
	Declare Property height() as ULong
	Declare Operator Cast() As String
	Declare Constructor() 
	Declare Constructor(ByVal leftX As ULong, ByVal topY As ULong, ByVal rightX As ULong, ByVal bottomY As ULong)   
End Type
'---------------------------------------------------------------------------------------------------
	Constructor TRect()
		'
	End Constructor
	Constructor TRect(ByVal leftX As ULong, ByVal topY As ULong, ByVal rightX As ULong, ByVal bottomY As ULong)
		'
		this.x1 = leftX 
		this.x2 = rightX 
		this.y1 = topY 
		this.y2 = bottomY 
	End Constructor
	   
	Property TRect.height() as Ulong 
		Return Abs(this.y2-this.y1 + 1) 	
	End Property
	Property TRect.Width() As Ulong 
		Return Abs(this.x2-this.x1 + 1)	
	End Property
	Operator TRect.cast() As String 
		'
		Return this.x1 & " " & this.y1 & " " & this.x2 & " " & this.y2
	End Operator
	Operator TRect.+=(Byref rhs As TVector2d) 
		this.x1 += rhs.x
		this.x2 += rhs.x
		this.y1 += rhs.y
		this.y2 += rhs.y
	End Operator
	Private Function TRect.is_point_in_rect(Byref value As TVector2d) As Boolean
		'
		Dim As TRange r
		r.x1 = this.x1
		r.x2 = this.x2
		
		If r.value_in_range(value.x) = false Then Return False 
		
		r.x1 = this.y1
		r.x2 = this.y2

		If r.value_in_range(value.y) = false Then Return False 
		Return True 
	End Function
	Private Sub TRect.horiz_shift(Byval amount As Ulong) 
		'
		this.x1 += amount 
		this.x2 += amount 	
	End Sub
	Private Sub TRect.vert_shift(Byval amount As ulong)
		this.y1 += amount
		this.y2 += amount 	
	End Sub
'--------------------------------------------------------------------------
Type TGraphicsRect extends TRect
		As ULong back_color = RGB(255,255,255) 
		As ULong border_color = RGB(255,255,255) 
		Declare Sub Draw(ByVal pTarget As Any Ptr = 0)
		Declare Constructor
		Declare Constructor (ByVal rect As TRect, ByVal backcolor As ULong, ByVal bordercolor As ULong)
End Type
	Constructor TGraphicsRect()
		'
	End Constructor
	Constructor TGraphicsRect(ByVal rect As TRect, ByVal backcolor As ULong, ByVal bordercolor As ULong)
		'
		With This 
			.x1 = rect.x1
			.x2 = rect.x2
			.y1 = rect.y1 
			.y2 = rect.y2
			.back_color = backcolor 
			.border_color = bordercolor
		End With
	End Constructor
	'---------------------------------------------------------
	Private Sub TGraphicsRect.draw(ByVal pTarget As Any Ptr = 0)
		With This		
			If pTarget = 0 Then 
				Line (.x1,.y1)-(.x2,.y2), back_color, bf 
				Line (.x1,.y1)-(.x2,.y2), border_color, b
			Else 
				Line pTarget, (0, 0) - Step(this.width-1, this.height-1), back_color, bf 
				Line pTarget, (0, 0) - Step(this.width-1, this.height-1), border_color, b
			EndIf  
		End With 
	End Sub
'--------------------------------------------------------------------------
#Macro _wait()
	Scope 
		While Inkey = ""
			Dim As TMouse mouse 
			mouse.res = Getmouse(mouse.x, mouse.y, mouse.wheel, mouse.buttons) 
			If mouse.res = 0 Then 
				If mouse.buttons <>0 Then 
					Exit While
				End If			
			End If		
		Wend
	End Scope 
#Endmacro
#macro _sleep( args... )
    While InKey() <> "" : Wend
    Sleep args
#endmacro				
#Macro __graphics(t)		
	Scope 
		If #t="off" Then 
			Screen 0 
		Elseif #t="f" Then 
			If Screenptr() = 0 Then 
				Screenres  1024,768, 32,, GFX_FULLSCREEN
				Width 1024\_CHAR_WIDTH, 768\_CHAR_HEIGHT
			End If
		ElseIf #t="2" Then 
			If Screenptr() = 0 Then 
				Screenres  1024,768, 32,2, GFX_FULLSCREEN
				Width 1024\_CHAR_WIDTH, 768\_CHAR_HEIGHT
			End If
		ElseIf #t="s" Then 
			If Screenptr() = 0 Then 
				Screenres  1024,288, 32
				Width 1024\_CHAR_WIDTH, 288\_CHAR_HEIGHT 
			End If
		Else 
			If Screenptr() = 0 Then 
				ScreenRes  1024,768, 32
				Width 1024\_CHAR_WIDTH, 768\_CHAR_HEIGHT 
			End If
		Endif 
	End Scope 
#EndMacro
#Macro __CLEAR_KEY_BUFFER()
	While InKey<>"":Wend
#EndMacro 
'--------------------------------------------------------------------------
Private Sub draw_centered_string(Byref s As string, Byval y As Integer, Byval c As Ulong)
	'
	dim As Integer w = Len(s) * _CHAR_WIDTH, x
	x = (1024 - w) \ 2
	Draw String (x, y), s, c
End Sub
'--------------------------------------------------------------------------
'#include Once "log.bi"

'#include Once "Button.bi"
'--------------------------------------------------------------------------
Private Function zero_prefix_number(ByVal number As Integer, ByVal count As Integer = 6) As String
	'
	Dim As String s = Str(number) 
	While Len(s) < count  
		s = "0" & s 
	Wend
	Return s 
End Function
Private Function string_array_to_string(s() As String, ByRef delim As String = " ") As String 
	'
	Dim As String ret_val 
	For i As Integer = LBound(s) To UBound(s) 
		ret_val &= s(i)
		If i < UBound(s) Then ret_val &= delim 
	Next
	Return ret_val 
End Function
'------------------------------------------------------------------------------------
' marpons split function - requires two functions 
#Include "crt/string.bi"   'needed for memchr function
'helper function for String_tok_r
Private Function h_tok_r(byref ps1 as byte ptr, byref ps2 as byte ptr, byval i as long )as byte ptr
   dim p as byte ptr
   if i > 1 THEN
      while memchr(ps2, *ps1 ,  i) <> 0
         ps1 += 1
      wend
   else
      while *ps1 = *ps2
         ps1 += 1
      wend   
   END IF   
   if *ps1 = 0 THEN
      ps1 = 0
      return 0
   END IF
   p = ps1
   if i > 1 THEN
      while memchr(ps2, *ps1 , i) = 0  
         ps1 += 1
         if *ps1 = 0 then exit while
      wend
   else
      while *ps1 <> *ps2 
         ps1 += 1
         if *ps1 = 0 then exit while
      wend   
   end if      
   if *ps1 <> 0 THEN
      *ps1 = 0
      ps1 += 1
   end if
   return p
end function  
'thread-safe alternative to Split_tok
'splits TEXT using every char of DELIMIT as delimiter,  
'works as Split_any but only the non-empty elements will be on the RET array  
Private Function Split_tok_r(byref TEXT As String , byref DELIMIT As String ,  RET() As String) As Long
   Dim ptemp As Zstring Ptr
   Dim ctr As Long
   Dim size1 As uLong 
   
   dim as long ilen = len(DELIMIT)
   if(len(TEXT) = 0 or ilen = 0) then
      Redim RET(1 To 1) 
      RET(1) = TEXT
      return 1
   end if
   dim as string s1 = TEXT            'copy TEXT to avoid alteration of the input
   dim As byte Ptr p = strptr(s1)   'get pointers
   dim As byte Ptr d = strptr(DELIMIT)
   ptemp = p 
   while ptemp <> 0
      ptemp = h_tok_r(p, d, ilen)  ' p is sent byref and it will be modified on the f_strtok_r function 
      if ptemp <> 0 THEN
         ctr += 1
         if ctr = 1  THEN
            size1 = 1
            Redim RET(1 To size1)     'redim the array
         elseif ctr > size1 then
            size1 *= 2
            redim preserve RET(1 To size1)     'redim the array
         END IF
         RET(ctr)= *ptemp
      end if
   WEND
   If ctr = 0 Then Return 0
   if size1 > ctr then Redim preserve RET(1 To ctr)     'redim the array
   Return ctr
end Function
Private Function is_value_in_array(ByRef s As Const String, array() As String) As boolean
	'
	For i As Integer = LBound(array) To UBound(array) 
		If s = array(i) Then Return TRUE 
	Next
	Return FALSE 
End Function
Private Sub remove_array_element OverLoad (ByVal index As Integer, array() As Any Ptr) 
	'
	' remove element from a pointer array via index 
	Dim As Integer l, u, n  
	l = LBound(array): u =  UBound(array)
	For i As Integer = l To u
		If i <> index Then
			u -= 1 
			n += 1
			array(n) = array(i) 
		EndIf
	Next
	ReDim Preserve array(l To n) 
			
End Sub
Private Sub remove_array_element(ByRef element As String, array() As String) 
	'
	' remove element from string array via string matching 
	Dim As Integer l, u, n  
	l = LBound(array): u =  UBound(array)
	If l = u Then
		' this is the best we can do with a single element array 
		ReDim array(0 To 0)
		Return  
	EndIf
	For i As Integer = l To u
		If element <> array(i) Then
			u -= 1 
			n += 1
			array(n) = array(i) 
		EndIf
	Next
	ReDim Preserve array(l To n) 
End Sub
