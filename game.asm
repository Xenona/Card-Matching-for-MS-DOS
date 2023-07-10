format PE GUI 5.0
entry WinMain
    
include '.\INCLUDE\win32a.inc'

        
        
ImageBase = $ - rva $
nil       = 0
        
proc Window.WindowProc uses ebx esi edi,\
     hWnd, uMsg, wParam, lParam
     cmp     [uMsg], WM_DESTROY
     je      .WMDestroy
.Default:
     invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
     jmp     .EndProc
.WMDestroy:
     invoke  PostQuitMessage, 0
     jmp     .Default
.EndProc:
     ret
endp
        
proc WinMain
    locals
    Msg     MSG
    endl
    
    xor     ebx, ebx
    invoke  RegisterClassEx, Window.wcexClass
    invoke  CreateWindowEx, ebx, Window.szClassName, ebx, WINDOW_STYLE,\
                            ebx, ebx, ebx, ebx, ebx, ebx, ebx, ebx
    invoke  ShowCursor, ebx
    lea     edi, [Msg]
.MsgLoop:
    invoke  GetMessage, edi, ebx, ebx, ebx
    test    eax, eax
    jz      .EndMsgLoop
    invoke  DispatchMessage, edi
    jmp     .MsgLoop
.EndMsgLoop:
    invoke  ExitProcess, ebx
endp
        
data import
    library kernel32, 'kernel32.dll',\
            gdi32,    'gdi32.dll',\
            user32,   'user32.dll'
    
    include '.\INCLUDE\api\kernel32.inc'
    include '.\INCLUDE\api\gdi32.inc'
    include '.\INCLUDE\api\user32.inc'
    include '.\INCLUDE\api\opengl.inc'
end data
     
Window.wcexClass      WNDCLASSEX      sizeof.WNDCLASSEX, CS_GLOBALCLASS,\
                                          Window.WindowProc, 0, 0, ImageBase,\
                                          0, 0, 0, nil, Window.szClassName, 0

Window.szClassName    du              'Demo', 0


COLOR_DEPTH     =       24
PFD_FLAGS       =       PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW
WINDOW_STYLE    =       WS_VISIBLE or WS_MAXIMIZE or WS_POPUP
FOV             =       60.0
Z_NEAR          =       0.001
Z_FAR           =       10000.0


pfd             PIXELFORMATDESCRIPTOR   sizeof.PIXELFORMATDESCRIPTOR, 1, PFD_FLAGS, PFD_TYPE_RGBA, COLOR_DEPTH,\
                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
                                        COLOR_DEPTH, 0, 0, PFD_MAIN_PLANE, 0, PFD_MAIN_PLANE