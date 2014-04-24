tasm /zi /l tsr.asm
tlink /t tsr.obj
tasm /zi /l pong.asm
tlink /l pong.obj
tsr
pong
