# createPaddle_readPaddle_readLeftRightInputs.s
# Szymon Borkowski
# Oct 2022
# Using a main program and functions / loop

main:
  jal x1, initPaddle
  jal x1, initBall
  jal x1, move_up_ball

initPaddle: # init 5-bit paddle in row 2 (mem addr 8)
  addi x10, x0, 0x1f
  slli x10, x10, 14
  addi x11, x0, 0x8 
  sw   x10, 0(x11)
  jalr x0, 0(x1) 

initBall: # 1-bit ball row 3 
  addi x10, x0, 0x1
  slli x10, x10, 16
  addi x11, x0, 0xC
  sw   x10, 0(x11)
  jalr x0, 0(x1)

move_up_ball:
  addi x0, x0, 10
  jal, x3, read_ball
  addi x10, x10, 4
  jalr x0, 0(x1)
  
read_ball:
  lw, x10, 0(x11)
  jalr x0, 0(x3)

readPaddle:
 lw,   x10, 0(x11)
 jalr  x0, 0(x1) 


readLeftRight:
# read left/right control switches, memory address 0x00030008
# one clock delay in memory peripheral to register change in switch state
 lui  x10, 0x00030 # 0x00030000
 addi x10, x10, 8  # 0x00030008
 lw  x11, 0(x10)
 jalr  x0, 0(x1) 
