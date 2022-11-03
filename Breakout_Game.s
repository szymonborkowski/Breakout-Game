
# v================ GAME SETUP ================v
setup:
  jal x1, initPaddle
  jal x1, initBall
  jal x1, initWall
  jal x1, clearArena

initPaddle: # init 5-bit paddle in row 2 
  addi x26, x0,  0x1f  # load paddle length
  add  x25, x0,  x26   # add paddle into paddle vec
  slli x25, x25, 14    # move paddle to middle
  addi x5, x0,  0x8    # 
  sw   x10, 0(x11)
  jalr x0,  0(x1) 

initBall: # 1-bit ball row 3 
  addi x10, x0,  0x1
  slli x10, x10, 16
  addi x12, x0,  0xC
  sw   x10, 0(x12)
  jalr x0,  0(x1)
  
initWall: # 32-bit wall row 15
  addi x10, x0, -1
  addi x13, x0, 0x3C
  sw   x10, 0(x13)

clearArena: # clear entire memory
  addi x5, x0, 0      # base memory address
  addi x4, x0, 0      # loop counter
  addi x7, x0, 15     # max count value ? is this max value of memory ?
  clearMemLoop:
    sw x0, 0(x5)      # clear memory word (store row of 0's)
	addi x5, x5, 4      # increment memory byte address
	addi x4, x4, 1      # increment loop counter 	
	ble  x4, x7, clearMemLoop  
  jalr x0, 0(x1)      # ret

# ^============================================^


main:

  jal x1, setup
  jal x0, move_up_ball  # enter the up-down loop
  jal x1, main



move_up_ball:
  jal  x3, read_ball
  sw   x0, 0(x12)
  addi x12, x12, 4
  sw   x10, 0(x12)
  jal x5, check_wall_and_mask
  bne x8, x0, move_down_ball  # x8 = 1 -> hits wall
  jal x4, move_up_ball
  
move_down_ball:
  jal  x3, read_ball
  sw   x0, 0(x12)
  addi x12, x12, -4
  sw   x10, 0(x12)
  jal x5, check_paddle_and_mask
  bne x8, x0, move_up_ball    # x8 = 1 -> hits paddle
  jal x4, move_down_ball
  
read_ball:
  lw x10,  0(x12)
  jalr x0, 0(x3)
  
# check if ball hit wall
check_wall_and_mask:
  lw x6, 0(x13)      # load what is left of the wall
  addi x10, x0, 0x38 
  lw x7, 0(x10)      # load row 14
  and x8, x6, x7
  jalr x0, 0(x5)

# check if ball hit paddle
check_paddle_and_mask:
  lw x6, 0(x11)      # load the paddle location
  addi x10, x0, 0xC 
  lw x7, 0(x10)      # load row 3
  and x8, x6, x7
  jalr x0, 0(x5)  
