nasm -f win64 -o PingPong.obj PingPong.asm && link PingPong.obj -subsystem:windows -libpath:c:\lib64 -libpath:lib -out:RayPingPong.exe -entry:Main raylib.lib opengl32.lib kernel32.lib user32.lib gdi32.lib winmm.lib shell32.lib msvcrt.lib