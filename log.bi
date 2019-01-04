#Define NULL 0
#Define CRLF Chr(13) & Chr(10)

Namespace _Log
	#Define __FL__ __Function__ & " " & __Line__  & " "
#Ifdef __fb_linux__ 
	Const Log_FILE = "/home/les/Downloads/Poseiden/projects/mem.txt"
#Else 
	Const LOG_FILE = "mem.txt"
#EndIf 
	Declare Sub clear_file()
	Declare Sub header_file() 
	Declare Function post(Byref txt As String) As Boolean
	Declare Function __lC(Byref var_name As string, Byref mod_name As String, Byval value As Integer ptr) As Boolean 
	Declare function __lD(Byref var_name As string, Byref mod_name As String, Byval value as Integer ptr) As Boolean 

	Sub header_file() 
		'
		clear_file()
		Dim As Ulong f
		f = Freefile()
		Open Log_FILE For Output As f
			Print #f, Date() & " " & Time() & " ----- logging -----" & CRLF 
			'Print #f, CRLF
		Close f
	End Sub
	Sub clear_file()
		'
		Dim As Ulong f
		f = Freefile()
		
		Open Log_FILE For Output As f
		Close f
	End Sub
	Function __lC(Byref var_name As string, Byref mod_name As String, Byval value As Integer Ptr) As boolean
		Return post("Create new in: " & mod_name & " " & __FL__ & " " & var_name & " = " & Chr(9) & Hex(value, 8))	
	End Function

	Function __lD(Byref var_name As string, Byref mod_name As String, Byval value As Integer ptr) As Boolean
		Return post("Delete in: " & mod_name & " " & __FL__ & " " & var_name & " = " & Chr(9) & Hex(value, 8))
	End Function

	Function post(Byref txt As String) As Boolean
		'
		Dim As Ulong f
		f = Freefile()
		If Open(Log_FILE , For Binary, As f)<>0 Then  Return False
			If Lof(f) > 1 Then 
				Seek f, Lof(f)
			Endif 
			Print #f, txt & CRLF
		Close f
		Return True 
	End Function 
	
End Namespace
