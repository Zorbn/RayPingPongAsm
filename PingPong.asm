bits 64
default rel

; Raylib constants.
KEY_W equ 87
KEY_S equ 83

; Game constants.
TargetFrameRate equ 60

ScreenWidth equ 800
ScreenHeight equ 450

PlayerWidth equ 16
PlayerHeight equ 64
PlayerSpeed equ 4

BallSize equ 16
BallSpeed equ 4

section .data
    LIGHT_GRAY db 200, 200, 200, 255
    RAYWHITE db 245, 245, 245, 255
    WHITE db 255, 255, 255, 255
    BLACK db 0, 0, 0, 255

    WindowTitle db "RayPingPong", 0
    ScoreLabel db "Score: %d", 0

    PlayerX dd 16
    PlayerY dd ScreenHeight / 2 - PlayerHeight / 2

    BallX dd ScreenWidth / 2
    BallY dd ScreenHeight / 2
    BallDirX dd -1
    BallDirY dd 1

section .bss
    Score resd 1
    IsBallResetting resq 1
    FormattedScoreLabel resq 1

section .text

global Main

; Raylib functions.
extern InitWindow
extern WindowShouldClose
extern BeginDrawing
extern EndDrawing
extern ClearBackground
extern DrawText
extern DrawRectangle
extern IsKeyDown
extern CloseWindow
extern SetTargetFPS

; System functions.
extern _CRT_INIT
extern ExitProcess

; C functions.
extern sprintf

Main:
    push rbp
    mov rbp, rsp

    sub rsp, 32
    call _CRT_INIT
    add rsp, 32

    ; Create window.
    sub rsp, 32
    mov rcx, ScreenWidth
    mov rdx, ScreenHeight
    lea r8, [WindowTitle]
    call InitWindow
    add rsp, 32

    sub rsp, 32
    mov rcx, TargetFrameRate
    call SetTargetFPS
    add rsp, 32

    jmp .ShouldClose
    .Loop:
    ;; Update:

    ; Get keyboard input.
    mov r8d, 0
    sub rsp, 32
    mov ecx, KEY_W
    call IsKeyDown
    add rsp, 32
    cmp eax, 1
    jne .NotUp
    sub r8d, 1
    .NotUp:

    sub rsp, 32
    mov ecx, KEY_S
    call IsKeyDown
    add rsp, 32
    cmp eax, 1
    jne .NotDown
    add r8d, 1
    .NotDown:

    ; Move player.
    mov eax, r8d
    mov ecx, PlayerSpeed
    mul ecx
    add dword [PlayerY], eax

    ; Move ball.
    mov eax, dword [BallDirX]
    mov ecx, BallSpeed
    mul ecx
    add dword [BallX], eax

    mov eax, dword [BallDirY]
    mov ecx, BallSpeed
    mul ecx
    add dword [BallY], eax

    ; Bounce ball against player.
    mov eax, dword [PlayerX]
    add eax, PlayerWidth
    cmp dword [BallX], eax
    jg .EndBounceOffPlayer

    mov eax, dword [BallY]
    add eax, BallSize
    cmp eax, dword [PlayerY]
    jl .EndBounceOffPlayer

    mov eax, dword [PlayerY]
    add eax, PlayerHeight
    cmp eax, dword [BallY]
    jl .EndBounceOffPlayer

    mov dword [BallDirX], 1

    mov eax, dword [PlayerY]
    add eax, PlayerHeight / 2
    mov ecx, dword [BallY]
    add ecx, BallSize / 2
    cmp eax, ecx
    jl .BounceDown

    .BounceUp:
    mov dword [BallDirY], -1
    jmp .EndBounceOffPlayer

    .BounceDown:
    mov dword [BallDirY], 1

    .EndBounceOffPlayer:

    ; Reset ball (and score) if it goes offscreen.
    mov eax, dword [BallX]
    add eax, BallSize
    cmp eax, 0
    jg .DontBounceLeft
    mov dword [BallX], ScreenWidth
    mov dword [BallY], ScreenHeight / 2
    mov dword [BallDirX], -1
    mov dword [Score], 0
    mov qword [IsBallResetting], 1
    .DontBounceLeft:

    ; Bounce ball against walls.
    mov eax, dword [BallX]
    add eax, BallSize
    cmp eax, ScreenWidth
    jl .DontBounceRight
    mov dword [BallDirX], -1

    ; Check if the ball is still resetting.
    cmp qword [IsBallResetting], 1
    je .EndBounceRight

    ; Player scores when the ball hits the right wall, as long as the ball isn't resetting.
    inc dword [Score]
    jmp .EndBounceRight

    .DontBounceRight:
    ; The ball resets to be behind the right wall. Once the ball is no longer
    ; colliding with the right wall, then it has finished resetting.
    mov qword [IsBallResetting], 0 
    .EndBounceRight:

    cmp dword [BallY], 0
    jg .DontBounceTop
    mov dword [BallDirY], 1
    .DontBounceTop:

    mov eax, dword [BallY]
    add eax, BallSize
    cmp eax, ScreenHeight
    jl .DontBounceBottom
    mov dword [BallDirY], -1
    .DontBounceBottom:

    ;; Draw:
    sub rsp, 32
    call BeginDrawing
    add rsp, 32

    sub rsp, 32
    mov ecx, dword [BLACK]
    call ClearBackground
    add rsp, 32

    ; Draw score label.
    sub rsp, 32
    lea rcx, qword [FormattedScoreLabel]
    lea rdx, qword [ScoreLabel]
    mov r8d, dword [Score]
    call sprintf
    add rsp, 32

    sub rsp, 32 + 16
    lea rcx, qword [FormattedScoreLabel]
    mov edx, 16
    mov r8d, 16
    mov r9d, 20
    mov eax, dword [LIGHT_GRAY]
    mov dword [rsp + 32], eax
    call DrawText
    add rsp, 32 + 16

    ; Draw ball.
    sub rsp, 32 + 16
    mov ecx, dword [BallX]
    mov edx, dword [BallY]
    mov r8d, BallSize
    mov r9d, BallSize
    mov eax, dword [WHITE]
    mov dword [rsp + 32], eax
    call DrawRectangle
    add rsp, 32 + 16

    ; Draw player.
    sub rsp, 32 + 16
    mov ecx, dword [PlayerX]
    mov edx, dword [PlayerY]
    mov r8d, PlayerWidth
    mov r9d, PlayerHeight
    mov eax, dword [WHITE]
    mov dword [rsp + 32], eax
    call DrawRectangle
    add rsp, 32 + 16

    sub rsp, 32
    call EndDrawing
    add rsp, 32

    .ShouldClose:
    sub rsp, 32
    call WindowShouldClose
    add rsp, 32
    cmp rax, 0
    je .Loop

    .Exit:
    sub rsp, 32
    call CloseWindow
    add rsp, 32

    xor rax, rax
    call ExitProcess
