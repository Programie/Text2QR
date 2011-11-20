Enumeration
	#Window
	#TextInput
	#QRCode
EndEnumeration

Enumeration
	#QR_ECLEVEL_L
	#QR_ECLEVEL_M
	#QR_ECLEVEL_Q
	#QR_ECLEVEL_H
EndEnumeration

Structure eQRCode
	Version.l
	Width.l
	pSymbolData.l
EndStructure

#Title = "Text2QR"

Procedure Memory2File(sFile$, *pMemory, lSize)
	lFile = CreateFile(#PB_Any, sFile$)
	If IsFile(lFile)
		WriteData(lFile, *pMemory, lSize)
		CloseFile(lFile)
	EndIf
EndProcedure

Procedure CreateQRCode(sString$, lNewSize)
	bSuccess.b
	sFile$ = GetPathPart(ProgramFilename()) + "qrcodelib.dll"
	lFile = ReadFile(#PB_Any, sFile$)
	If IsFile(lFile)
		CloseFile(lFile)
	Else
		Memory2File(sFile$, ?Lib_QRCode, ?EOF - ?Lib_QRCode)
	EndIf
	lDll = OpenLibrary(#PB_Any, sFile$)
	If IsLibrary(lDll)
		*pQRCode.eQRCode = CallCFunction(lDll, "QRcode_encodeString8bit", @sString$, 0, #QR_ECLEVEL_H)
		If Not *pQRCode Or Not *pQRCode\Width
			CloseLibrary(lDll)
			ProcedureReturn #Null
		Else
			*pSymbolData = *pQRCode\pSymbolData
			lSize = *pQRCode\Width
		EndIf
		lImage = CreateImage(#PB_Any, lSize, lSize)
		If IsImage(lImage)
			If StartDrawing(ImageOutput(lImage))
				Box(0, 0, lSize, lSize, #White)
				For lY = 0 To lSize - 1
					For lX = 0 To lSize - 1
						If (PeekB(*pSymbolData) & $FF) & 1
							Plot( lX, lY, #Black)
						EndIf
						*pSymbolData + 1
					Next
				Next
				StopDrawing()
				If ResizeImage(lImage, lNewSize, lNewSize, #PB_Image_Raw)
					bSuccess = #True
				EndIf
			EndIf
			If Not bSuccess
				FreeImage(lImage)
			EndIf
		EndIf
		CallCFunction(lDll, "QRcode_free", *pQRCode)
		CloseLibrary(lDll)
		If bSuccess
			ProcedureReturn lImage
		EndIf
	EndIf
EndProcedure

Procedure GetParameter(sName$)
	For lIndex = 0 To CountProgramParameters() - 1
		If LCase(ProgramParameter(lIndex)) = "/" + LCase(sName$)
			ProcedureReturn #True
		EndIf
	Next
EndProcedure

UseJPEGImageEncoder()
UseJPEG2000ImageEncoder()
UsePNGImageEncoder()

If GetParameter("getbuild")
	MessageRequester(#Title, "Current build: " + Str(#PB_Editor_CompileCount), #MB_ICONINFORMATION)
	End
EndIf

lFileFormat = 3; Default is Portable Network Graphics
lWidth = 400
lSize = 200

If OpenWindow(#Window, 100, 100, lWidth + lSize + 30, lSize + 20, #Title, #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
	EditorGadget(#TextInput, 10, 10, lWidth, lSize)
	ButtonImageGadget(#QRCode, lWidth + 20, 10, lSize, lSize, 0)
	Repeat
		Select WaitWindowEvent()
			Case #PB_Event_CloseWindow
				bQuit.b = #True
			Case #PB_Event_Gadget
				Select EventGadget()
					Case #TextInput
						If lImage And IsImage(lImage)
							FreeImage(lImage)
						EndIf
						lImage = CreateQRCode(GetGadgetText(#TextInput), lSize - 20)
						If IsImage(lImage)
							SetGadgetAttribute(#QRCode, #PB_Button_Image, ImageID(lImage))
						EndIf
					Case #QRCode
						If lImage And IsImage(lImage)
							sFile$ = SaveFileRequester("Save QR Code as image", "QR Code", "Windows Bitmap|*.bmp|JPEG|*.jpg|JPEG 2000|*.jp2|Portable Network Graphics|*.png", lFileFormat)
							If sFile$
								lFileFormat = SelectedFilePattern()
								Select lFileFormat
									Case 0; Windows Bitmap
										lFormat = #PB_ImagePlugin_BMP
										sExtension$ = "bmp"
									Case 1; JPEG
										lFormat = #PB_ImagePlugin_JPEG
										sExtension$ = "jpg"
									Case 2; JPEG 2000
										lFormat = #PB_ImagePlugin_JPEG2000
										sExtension$ = "jp2"
									Case 3; Portable Network Graphics
										lFormat = #PB_ImagePlugin_PNG
										sExtension$ = "png"
								EndSelect
								If LCase(GetExtensionPart(sFile$)) <> sExtension$
									sFile$ = RTrim(sFile$, ".") + "." + sExtension$
								EndIf
								lFile = ReadFile(#PB_Any, sFile$)
								If IsFile(lFile)
									CloseFile(lFile)
									lWrite = MessageRequester(#Title, "The selected file already exists!" + Chr(13) + Chr(13) + sFile$ + Chr(13) + Chr(13) + "Do you want to replace it?", #MB_YESNO | #MB_ICONQUESTION)
								Else
									lWrite = #PB_MessageRequester_Yes
								EndIf
								If lWrite = #PB_MessageRequester_Yes
									SaveImage(lImage, sFile$, lFormat, 10)
								EndIf
							EndIf
						Else
							MessageRequester(#Title, "Nothing typed yet!", #MB_ICONERROR)
						EndIf
				EndSelect
		EndSelect
	Until bQuit
EndIf

DataSection
	Lib_QRCode:
	IncludeBinary "qrcodelib.dll"
	EOF:
EndDataSection
; IDE Options = PureBasic 4.60 RC 2 (Windows - x86)
; CursorPosition = 92
; FirstLine = 57
; Folding = -
; EnableXP
; UseIcon = Main.ico
; Executable = Text2QR.exe
; EnableCompileCount = 39
; EnableBuildCount = 8
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 1,0,0,0
; VersionField1 = 1,0,0,0
; VersionField2 = SelfCoders
; VersionField3 = Text2QR
; VersionField4 = 1.0
; VersionField5 = 1.0
; VersionField6 = Text2QR
; VersionField7 = Text2QR
; VersionField8 = %EXECUTABLE
; VersionField13 = text2qr@selfcoders.com
; VersionField14 = http://www.selfcoders.com
; VersionField15 = VOS_NT_WINDOWS32
; VersionField16 = VFT_APP
; VersionField17 = 0409 English (United States)
; VersionField18 = Build
; VersionField19 = Project Start
; VersionField20 = Compile Time
; VersionField21 = %COMPILECOUNT
; VersionField22 = 2011-10-27
; VersionField23 = %yyyy-%mm-%dd %hh:%ii:%ss