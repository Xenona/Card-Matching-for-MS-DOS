include "OPENGL_DEMO.inc"

        className       db      "OpenGLDemo", 0
        clientRect      RECT
        hdcBack         dd      ?
        time            dd      ?
        hdc             dd      ?
        angle           dd      0.0
        step            dd      3.14

        vertices        equ     cubeVertices
        colors          equ     cubeColors
        verticesCount   dd      CUBE_VERTICES_COUNT

proc WinMain

        locals
                hMainWindow     dd      ?
                msg             MSG
                aspect          dq      ?
        endl

        xor     ebx, ebx

        invoke  RegisterClass, wndClass
        invoke  CreateWindowEx, ebx, className, className, WINDOW_STYLE,\
                        ebx, ebx, ebx, ebx, ebx, ebx, ebx, ebx
        mov     [hMainWindow], eax

        invoke  GetClientRect, eax, clientRect
        invoke  ShowCursor, ebx
        invoke  GetTickCount
        mov     [time], eax

        invoke  GetDC, [hMainWindow]
        mov     [hdc], eax

        invoke  ChoosePixelFormat, [hdc], pfd
        invoke  SetPixelFormat, [hdc], eax, pfd

        invoke  wglCreateContext, [hdc]
        invoke  wglMakeCurrent, [hdc], eax

        invoke  glViewport, 0, 0, [clientRect.right], [clientRect.bottom]

        invoke  glMatrixMode, GL_PROJECTION
        invoke  glLoadIdentity

        fild    [clientRect.right]      ; width
        fidiv   [clientRect.bottom]     ; width / height
        fstp    [aspect]                ;
        invoke  gluPerspective, double FOV, double [aspect], double Z_NEAR, double Z_FAR

        invoke  glEnable, GL_DEPTH_TEST
        invoke  glShadeModel, GL_SMOOTH
        invoke  glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST

        lea     esi, [msg]

.cycle:
        invoke  GetMessage, esi, ebx, ebx, ebx
        invoke  DispatchMessage, esi
        jmp     .cycle

endp

proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        xor     ebx, ebx

        mov     eax, [uMsg]
        JumpIf  WM_PAINT,       .Paint
        JumpIf  WM_DESTROY,     .Destroy
        JumpIf  WM_KEYDOWN,     .KeyDown

        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

.Paint:
        stdcall Draw
        jmp     .ReturnZero
.KeyDown:
        cmp     [wParam], VK_ESCAPE
        jne     .ReturnZero

.Destroy:
        invoke  ExitProcess, ebx

.ReturnZero:
        xor     eax, eax

.Return:
        ret
endp

proc Draw

        locals
                currentTime     dd      ?
        endl

        invoke  GetTickCount
        mov     [currentTime], eax

        sub     eax, [time]
        cmp     eax, 10
        jle     .Skip

        mov     eax, [currentTime]
        mov     [time], eax

        fld     [angle]
        fsub    [step]
        fstp    [angle]

.Skip:

        invoke  glClearColor, 0.1, 0.1, 0.6, 1.0
        invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

        invoke  glMatrixMode, GL_MODELVIEW
        invoke  glLoadIdentity

        invoke  gluLookAt, double 3.0, double 3.0, double 3.0,\
                        double 0.0, double 0.0, double 0.0,\
                        double 0.0, double 1.0, double 0.0

        invoke  glRotatef, [angle], 0.0, 1.0, 0.0

        invoke  glEnableClientState, GL_VERTEX_ARRAY
        invoke  glEnableClientState, GL_COLOR_ARRAY

        invoke  glVertexPointer, 3, GL_FLOAT, 0, vertices
        invoke  glColorPointer, 3, GL_FLOAT, 0, colors
        invoke  glDrawArrays, GL_TRIANGLES, 0, [verticesCount]

        invoke  glDisableClientState, GL_VERTEX_ARRAY
        invoke  glDisableClientState, GL_COLOR_ARRAY

        invoke  SwapBuffers, [hdc]

        ret
endp