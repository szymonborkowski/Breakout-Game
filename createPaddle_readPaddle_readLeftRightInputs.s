# createPaddle_readPaddle_readLeftRisghInputs.s
# Fearghal Morgan
# Oct 2022

# Define register usage 
# To be done 

# Could use a main program
# functions: setup, assigning constants, allocated to specific registers
# e.g, setup, initPaddle, readPaddle, readLeftRight

# init 5-bit paddle in row 2 (mem addr 8)
addi x10, x0, 0x1f
slli x10, x10, 14
addi x11, x0, 0x8 
sw   x10, 0(x11)

# initialise x10 = 0xffffffff and read paddle to x10
xori x10, x0, -1 # 0xffffffff
lw,   x10, 0(x11)

# read left/right control switches, memory address 0x00030008
# one clock delay in memory peripheral to register change in switch state
lui  x10, 0x00030 # 0x00030000
addi x10, x10, 8  # 0x00030008
loop1:
 lw  x11, 0(x10)
 beq x0,x0,loop1  # unconditional loop, reading L/R switches

1b: jal x0, 1b # loop until reset