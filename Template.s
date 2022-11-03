# Breakout game
# Fearghal Morgan
# Oct 2022

# ====== Register allocation START ======
# x0 always = 0
# x1 return address
# x2 stack pointer (when used)
# x3 IOIn(31:0) switches, address 0x00030008
# x4 program variable
# x5 memory address
# x6 dlyCount
# x7 counter variable
# x8 paddleNumDlyCount
# x9 ballNumDlyCount
# x10 X/YAdd ref             
# x11 Not used
# x12 Not used 
# x13 Not used
# x14 zone
# x15 dlyCountMax. 12.5MHz clock frequency. Two instructions per delay cycle => 6,250,000 delay cycles per second, 625,000 (0x98968) delay cycles per 100msec

# Wall
#  x16 wallVec value, default 0xffffffff
# Ball
#  x17 ballVec
#  x18 CSBallXAdd (4:0)
#  x19 NSBallXAdd (4:0)
#  x20 CSBallYAdd (4:0)
#  x21 NSBallYAdd (4:0)
#  x22 CSBallDir  (2:0)
#  x23 NSBallDir  (2:0)
#  x24 ballNumDlyMax (4:0)
# Paddle
#  x25 paddleVec
#  x26 paddleSize (5)
#  x27 paddleXAddLSB
#  x28 paddleNumDlyMax (4:0)
# Score and Lives 
#  x29 Score
#  x30 Lives
# x31  Not used
# ====== Register allocation END ======


main:
  #jal x1, clearArena 
  #jal x1, waitForGameGo    # wait for IOIn(2) input to toggle 0-1-0

  jal x1, setupDefaultArena # initialise arena values 
  #jal x1, setupArena1       
  
  jal x1, updateWallMem
  jal x1, updateBallVec
  jal x1, updateBallMem
  jal x1, updatePaddleMem
  jal x1, UpdateScoreMem
  jal x1, UpdateLivesMem
  add x8, x0, x28           # load paddleNumDlyCount start value
  add x9, x0, x24           # load ballNumDlyCount start value

  loop1:
   jal x1, delay
   processPaddle:
    bne x8, x0, processBall # paddleNumDlyCount = 0? => skip chkPaddle
    jal x1, chkPaddle # read left/right controls to move paddle between left and right boundaries
    jal x1, updatePaddleMem
    add x8,  x0, x28        # load paddleNumDlyCount start value
   processBall:
    bne x9, x0, loop1       # ballNumDlyCount = 0? => skip check ball functions 
    jal x1, chkBallZone     # find ball zone, update 1. ball, 2. wall, 3. score, 4. lives, loop or end game   *****Retuun x19 NSBallXAdd, x21 NSBallXAdd
    jal x1, updateBallVec   
    jal x1, updateBallMem   # clear CSBallYAdd row, write ballVec to NSBallYAdd, CSBallYAdd = NSBallYAdd (and for XAdd too) 
    jal x1, UpdateScoreMem
    jal x1, UpdateLivesMem
    add x9, x0, x24         # load ballNumDlyCount start value
    jal x0, loop1

   1b: jal x0, 1b           # loop until reset asserted
 

# ====== Wall functions START ======
updateWallMem:
 jalr x0,  0(x1)          # ret
# ====== Wall functions END ======


# ====== Ball functions START ======
updateBallVec:            # Generate new ballVec using x19 (NSBallXAdd)
 jalr x0, 0(x1)           # ret


updateBallMem: 		      # write to memory. Requires NSBallXAdd and NSBallYAdd. 
 ret_updateBallMem:
  jalr x0, 0(x1)          # ret


chkBallZone:
 ret_chkBallZone:
  jalr x0, 0(x1)          # ret
# ====== Ball functions END ======



# ====== Paddle functions START ======
updatePaddleMem:     # Generate new paddleVec and write to memory. Requires paddleSize and paddleXAddLSB 
 jalr x0, 0(x1)      # ret


chkPaddle:
 # read left/right paddle control switches, memory address 0x00030008
 # one clock delay is required in memory peripheral to register change in switch state
 lui  x4, 0x00030    # 0x00030000 
 addi x4, x4, 8      # 0x00030008 # IOIn(31:0) address 
 lw   x3, 0(x4)      # read IOIn(31:0) switches
 ret_chkPaddle:
  jalr x0, 0(x1)    # ret
# ====== Paddle functions END ======


# ====== Score and Lives functions START ======
UpdateScoreMem:  
 addi x5, x0, 0      # memory base address
 sw   x29, 0(x5)     # store score 
 jalr x0, 0(x1)      # ret

UpdateLivesMem:  
 addi x5, x0, 0      # memory base address
 sw   x30, 4(x5)     # store lives
 jalr x0, 0(x1)      # ret

# ====== Score and Lives functions END ======




# ====== Setup arena variables START ======
setupDefaultArena: 
 # dlyCountMax 
					  # 12.5MHz clock frequency. Two instructions per delay cycle => 6,250,000 delay cycles per second, 625,000 (0x98968) delay cycles per 100msec
  lui  x15, 0x98968   # 0x98968000 
  srli x15, x15, 12   # 0x00098968 
  addi x15, x0, 2     # low count delay, for testing 
 # Wall
  xori x16, x0, -1    # wall x16 = 0xffffffff
 # Ball
  lui x17,  0x00010   # ballVec 0b0000 0000 0000 0001 0000 0000 0000 0000 = 0x0007c000
  addi x18, x0, 16    # CSBallXAdd (4:0)
  addi x19, x0, 16    # NSBallXAdd (4:0)
  addi x20, x0, 13    # CSBallYAdd (4:0)
  addi x21, x0, 13    # NSBallYAdd (4:0)
  addi x22, x0, 6     # CSBallDir  (2:0) N 
  addi x23, x0, 6	  # NSBallDir  (2:0) N
  addi x24, x0, 1     # ballNumDlyCount (4:0)
 # Paddle
  lui  x25, 0x0007c   # paddleVec 0b0000 0000 0000 0111 1100 0000 0000 0000 = 0x0007c000
  addi x26, x0, 5     # paddleSize
  addi x27, x0, 2     # paddleXAddLSB
  addi x28, x0, 1     # paddleNumDlyCount 
 # Score
  addi x29, x0, 0     # score
  addi x30, x0, 3     # lives 
 jalr x0, 0(x1)       # ret


setupArena1: 
 # dlyCountMax 
					  # 12.5MHz clock frequency. Two instructions per delay cycle => 6,250,000 delay cycles per second, 625,000 (0x98968) delay cycles per 100msec
  lui  x15, 0x98968   # 0x98968000 
  srli x15, x15, 12   # 0x00098968 
  #addi x15, x0, 2    # low count delay, for testing 
 # Wall
  lui  x16, 0xfedcb  
 # Ball
 # lui  x17, 0x00010  # ballVec 0b0000 0000 0000 0001 0000 0000 0000 0000 = 0x0007c000
  addi x18, x0, 6     # CSBallXAdd (4:0)
  addi x19, x0, 6     # NSBallXAdd (4:0)
  addi x20, x0, 8     # CSBallYAdd (4:0)
  addi x21, x0, 8     # NSBallYAdd (4:0)
  addi x22, x0, 6     # CSBallDir  (2:0)  NW
  addi x23, x0, 6	  # NSBallDir  (2:0)  NW
  addi x24, x0, 20    # ballNumDlyCount (4:0)
 # Paddle
  lui  x25, 0x007f8   # 0x007f8000 paddleVec = 0b0000 0000 0111 1111 1000 0000 0000 0000
  addi x26, x0, 8     # paddleSize
  addi x27, x0, 3     # paddleXAddLSB
  addi x28, x0, 10    # paddleNumDlyCount 
 # Score
  addi x29, x0, 3     # score
  addi x30, x0, 5     # lives 
  jalr x0, 0(x1)      # ret


clearArena: 
                      # initialise registers 
  addi x5, x0, 0      # base memory address
  addi x4, x0, 0      # loop counter
  addi x7, x0, 15     # max count value
  clearMemLoop:
    sw x0, 0(x5)      # clear memory word
	addi x5, x5, 4    # increment memory byte address
	addi x4, x4, 1    # increment loop counter 	
	ble  x4, x7, clearMemLoop  
  jalr x0, 0(x1)    # ret

# ====== Setup arena variables END ======


# ====== Other functions START ======
delay:
 add x6, x0, x15         # load dlyCount start value
 mainDlyLoop:
  addi x6, x6, -1        # decrement dlyCount
  bne  x6, x0, mainDlyLoop
  addi x8, x8, -1        # decrement paddleNumDlyCount
  addi x9, x9, -1        # decrement ballNumDlyCount
  jalr x0, 0(x1)         # ret
  

waitForGameGo:                    # wait 0-1-0 on input IOIn(2) control switches to start game	
                                  # one clock delay required in memory peripheral to register change in switch state
 lui  x4, 0x00030                 # 0x00030000 
 addi x4, x4, 8                   # 0x00030008 IOIn(31:0) address 
 addi x8, x0, 4                   # IOIn(2) = 1 compare value  

 waitUntilIOIn2Eq0: 
  lw   x3, 0(x4)                  # read IOIn(31:0) switches
  andi x7, x3, 4                  # mask to keep IOIn(2) 
  beq  x7, x0, waitUntilIOIn2Eq1  # chk / progress if IOIn(2) = 0
  beq  x0, x0, waitUntilIOIn2Eq0  # unconditional loop (else keep checking)
 
 waitUntilIOIn2Eq1: 
  lw   x3, 0(x4)                  # read IOIn(31:0) switches
  andi x7, x3, 4                  # mask to keep IOIn(2) 
  beq  x7, x8, waitUntilIOIn2Eq0b # chk / progress if IOIn(2) = 1
  beq  x0, x0, waitUntilIOIn2Eq1  # unconditional loop (else keep checking)

 waitUntilIOIn2Eq0b: 
  lw   x3, 0(x4)                  # read IOIn(31:0) switches
  andi x7, x3, 4                  # mask to keep IOIn(2) 
  beq  x7, x0, ret_waitForGameGo  # chk / progress if IOIn(2) = 0
  beq  x0, x0, waitUntilIOIn2Eq0b # unconditional loop (else keep checking)

 ret_waitForGameGo:
  jalr x0, 0(x1)                  # ret



endGame:                          # highlight game over in display 
  jalr x0, 0(x1)                  # ret
  
# ====== Other functions END ======
