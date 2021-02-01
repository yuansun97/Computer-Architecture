# This is the only file that will be considered for grading

.data
# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1

# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024

TIMER                   = 0xffff001c
ARENA_MAP               = 0xffff00dc

REQUEST_PUZZLE          = 0xffff00d0  ## Puzzle
SUBMIT_SOLUTION         = 0xffff00d4  ## Puzzle

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000
TIMER_ACK               = 0xffff006c

REQUEST_PUZZLE_INT_MASK = 0x800       ## Puzzle
REQUEST_PUZZLE_ACK      = 0xffff00d8  ## Puzzle
ENABLE_PAINT_BRUSH      = 0xffff00f0

GET_PAINT_BUCKETS       = 0xffff00e4
SWITCH_MODE             = 0xffff00f0

POWERUP_MAP             = 0xffff00e0
GET_INVENTORY           = 0xffff00e8
GET_OPPONENT_POWERUP    = 0xffff00c4

PICKUP_POWERUP          = 0xffff00f4
USE_POWERUP             = 0xffff00ec

### Puzzle
GRIDSIZE = 8

### Put these in your data segment                       
puzzle:      .half 0:164              
heap:        .half 0:4160
got_puzzle:  .word 1

power_map:      .word 0:300
inventory:      .half 0:30

three:  .float  3.0
five:   .float  5.0
PI:     .float  3.141592
F180:   .float  180.0

power_direction:    .word 1

.text

main:
    # Construct interrupt mask
    li      $t4, 0
    or      $t4, $t4, BONK_INT_MASK # request bonk
    or      $t4, $t4, REQUEST_PUZZLE_INT_MASK           # puzzle interrupt bit
    or      $t4, $t4, 1 # global enable
    mtc0    $t4, $12
    
    #Fill in your code here
    ############################# Go Spurs! Go! ###########################
    
    # request_puzzle:
    #     li      $t0, 0                              # solved_flag = 0

    #     la      $t1, puzzle
    #     sw      $t1, REQUEST_PUZZLE($0)             # enable the request_puzzle

    #     sw      $0, got_puzzle($0)
    # wait_for_puzzle:
    #     lw      $t0, got_puzzle($0)
    #     bne     $t0, $0, solve_puzzle               # if $t0 != 0, solve_puzzle
    #     j		wait_for_puzzle 			        # jump to wait_for_puzzle

    # solve_puzzle:
    #     sub     $sp, $sp, 4                         # alloc stack
    #     sw      $t1, 0($sp)                         # store $t1 = puzzle

    #     la      $a0, puzzle                         # copy_board
    #     la      $a1, heap
    #     jal     copy_board

    #     la      $a0, heap
    #     move    $a1, $0
    #     move    $a2, $0
    #     la      $a3, puzzle
    #     jal     solve

    # submit_puzzle:
    #     lw      $t1, 0($sp)
    #     add     $sp, $sp, 4
    #     sw      $t1, SUBMIT_SOLUTION($0)            # submit $t1 solution



    #     li      $t2, 3
    # check_buckets:
    #     lw      $t3, GET_PAINT_BUCKETS($0)          # get # of paint buckets left
    #     blt     $t3, $t2, request_puzzle            # request new puzzle if paint backets less than __

    #     j		get_powerup_map				# jump to target
        

######## loop below ########

    request_puzzle_loop:
        li      $t3, 1
        sw      $t3, PICKUP_POWERUP($0)

        la      $t0, inventory
        sw      $t0, GET_INVENTORY($0)
        lbu     $t0, 8($t0)                 # $t1 = invalid (char)
        beq     $t0, $0, no_power_request
        sw      $0,  USE_POWERUP($0)
    
    no_power_request:

        li      $t0, 0                              # solved_flag = 0

        la      $t1, puzzle
        sw      $t1, REQUEST_PUZZLE($0)             # enable the request_puzzle

        sw      $0, got_puzzle($0)
    wait_for_puzzle_loop:
        li      $t3, 1
        sw      $t3, PICKUP_POWERUP($0)

        lw      $t0, got_puzzle($0)
        bne     $t0, $0, solve_puzzle_loop               # if $t0 != 0, solve_puzzle
        j		wait_for_puzzle_loop				        # jump to wait_for_puzzle
    
    solve_puzzle_loop:
        li      $t3, 1
        sw      $t3, PICKUP_POWERUP($0)

        sub     $sp, $sp, 4                         # alloc stack
        sw      $t1, 0($sp)                         # store $t1 = puzzle

        la      $a0, puzzle                         # copy_board
        la      $a1, heap
        jal     copy_board

        la      $a0, heap
        move    $a1, $0
        move    $a2, $0
        la      $a3, puzzle
        jal     solve

        la      $t0, inventory
        sw      $t0, GET_INVENTORY($0)
        lbu     $t0, 8($t0)                 # $t1 = invalid (char)
        beq     $t0, $0, submit_puzzle_loop
        sw      $0,  USE_POWERUP($0)        

    submit_puzzle_loop:
        li      $t3, 1
        sw      $t3, PICKUP_POWERUP($0)

        lw      $t1, 0($sp)
        add     $sp, $sp, 4
        sw      $t1, SUBMIT_SOLUTION($0)            # submit $t1 solution





    get_powerup_map:
        li      $t3, 1
        sw      $t3, PICKUP_POWERUP($0)

        la      $t2, power_map
        sw      $t2, POWERUP_MAP($0)

        lw      $t3, 0($t2)                     # $t3 = power_map->length

        lhu     $t4, 4($t2)         # $t4 = power[0].x (stride)
        lhu     $t5, 6($t2)         # $t5 = power[0].y (stride)
        # lhu     $t6, 16($t2)        # $t6 = power[1].x
        # lhu     $t7, 18($t2)        # $t7 = power[1].y
    
    get_power_direction:
        li      $t3, 1
        sw      $t3, PICKUP_POWERUP($0)
        mul     $t4, $t4, 10        
        add     $t4, $t4, 5         # $t4 = power[0].x (pixel)
        mul 	$t5, $t5, 10        
        add     $t5, $t5, 5			# $t5 = power[0].y (pixel)

        lw      $t6, BOT_X($0)      # $t6 = current_x (pixel)
        lw      $t7, BOT_Y($0)      # $t7 = current_y (pixel)

        sub     $a0, $t4, $t6       # $a0 = delta_x
        sub     $a1, $t5, $t7       # $a1 = delta_y
        jal     sb_arctan



    start_moving:

        # li      $t3, 42000
        # sw      $t3, TIMER($0)

        # li      $t3, 0
        sw      $v0, ANGLE($0)                      # absolute angle = __

        li		$t3, 1		                        # $t3 = 1 
        sw      $t3, ENABLE_PAINT_BRUSH($0)         # brush is now ON
        sw      $t3, ANGLE_CONTROL($0)              # absolute angle
        sw      $t3, PICKUP_POWERUP($0)
        # sw      $0, ENABLE_PAINT_BRUSH($0)          # brush is now OFF
        la      $t0, inventory
        sw      $t0, GET_INVENTORY($0)
        lbu     $t0, 8($t0)                 # $t1 = invalid (char)
        beq     $t0, $0, no_power
        sw      $0,  USE_POWERUP($0)

    no_power:
        
        li      $t4, 10                             # $t4 = 10
        sw      $t4, VELOCITY($0)                   # v = 10

        j		request_puzzle_loop				# jump to request_puzzle


        

    #     li      $t1, 5
    # loop:
    #     li      $t0, 1
    #     sw      $t0, PICKUP_POWERUP($0)




    #     la      $t0, inventory
    #     sw      $t0, GET_INVENTORY($0)
    #     lbu     $t0, 8($t0)                 # $t1 = invalid (char)
    #     beq     $t0, $0, no_power
    #     sw      $0,  USE_POWERUP($0)

    # no_power:

    #     lw      $t0, GET_PAINT_BUCKETS($0)          # get # of paint buckets left
    #     blt     $t0, $t1, request_puzzle_loop       # request new puzzle if paint backets less than __
    #     li		$t3, 1		                        # $t3 = 1 
    #     sw      $t3, ENABLE_PAINT_BRUSH($0)         # brush is now ON
    #     j		loop				                # jump to target
 

    jr $ra



# -----------------------------------------------------------------------
# euclidean_dist - computes sqrt(x^2 + y^2)
# $a0 - x
# $a1 - y
# returns the distance
# -----------------------------------------------------------------------
euclidean_dist:
        mul	$a0, $a0, $a0	            # x^2
        mul	$a1, $a1, $a1	            # y^2
        add	$v0, $a0, $a1	            # x^2 + y^2
        mtc1	$v0, $f0
        cvt.s.w	$f0, $f0	            # float(x^2 + y^2)
        sqrt.s	$f0, $f0	            # sqrt(x^2 + y^2)
        cvt.w.s	$f0, $f0	            # int(sqrt(...))
        mfc1	$v0, $f0
        jr	$ra
# -----------------------------------------------------------------------
# sb_arctan - computes the arctangent of y / x
# $a0 - x
# $a1 - y
# returns the arctangent
# -----------------------------------------------------------------------
sb_arctan:
	li	$v0, 0		# angle = 0;
	abs	$t0, $a0	# get absolute values
	abs	$t1, $a1
	ble	$t1, $t0, no_TURN_90
	## if (abs(y) > abs(x)) { rotate 90 degrees }
	move	$t0, $a1	# int temp = y;
	neg	$a1, $a0	# y = -x;
	move	$a0, $t0	# x = temp;
	li	$v0, 90		# angle = 90;
no_TURN_90:
	bgez	$a0, pos_x 	# skip if (x >= 0)
	## if (x < 0)
	add	$v0, $v0, 180	# angle += 180;
pos_x:
	mtc1	$a0, $f0
	mtc1	$a1, $f1
	cvt.s.w $f0, $f0	# convert from ints to floats
	cvt.s.w $f1, $f1
	div.s	$f0, $f1, $f0	# float v = (float) y / (float) x;
	mul.s	$f1, $f0, $f0	# v^^2
	mul.s	$f2, $f1, $f0	# v^^3
	l.s	$f3, three	# load 3.0
	div.s 	$f3, $f2, $f3	# v^^3/3
	sub.s	$f6, $f0, $f3	# v - v^^3/3
	mul.s	$f4, $f1, $f2	# v^^5
	l.s	$f5, five	# load 5.0
	div.s 	$f5, $f4, $f5	# v^^5/5
	add.s	$f6, $f6, $f5	# value = v - v^^3/3 + v^^5/5
	l.s	$f8, PI		# load PI
	div.s	$f6, $f6, $f8	# value / PI
	l.s	$f7, F180	# load 180.0
	mul.s	$f6, $f6, $f7	# 180.0 * value / PI
	cvt.w.s $f6, $f6	# convert "delta" back to integer
	mfc1	$t0, $f6
	add	$v0, $v0, $t0	# angle += delta
	jr 	$ra


############### solve #################

# Given Puzzle Code
# bool solve(unsigned short *current_board, unsigned row, unsigned col, Puzzle* puzzle) {
#     if (row >= GRIDSIZE || col >= GRIDSIZE) {
#         bool done = board_done(current_board, puzzle);
#         if (done) {
#             copy_board(current_board,puzzle->board);
#         }
#
#         return done;
#     }
#     current_board = increment_heap(current_board, puzzle);
#
#     bool changed;
#     do {
#         changed = rule1(current_board);
#         changed |= rule2(current_board);
#         //changed |= rule3(board); //rule3 not done
#     } while (changed);

#     //added:
#     bool done = board_done(current_board, puzzle);
#     if (done) {
#         copy_board(current_board,puzzle->board);
#     }
#
#
#     short possibles = current_board[row*GRIDSIZE + col];
#     for(char number = 0; number < GRIDSIZE; ++number) {
#         if ((1 << number) & possibles) {
#             current_board[row*GRIDSIZE + col] = 1 << number;
#             unsigned next_row = ((col == GRIDSIZE-1) ? row + 1 : row);
#             if (solve(current_board, next_row, (col + 1) % GRIDSIZE, puzzle)) {
#                 return true;
#             }
#             current_board[row*GRIDSIZE + col] = possibles;
#         }
#     }
#     return false;
# }

# solve

solve:
    sub     $sp, $sp, 36
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s2, 12($sp)
    sw      $s3, 16($sp)
    sw      $s4, 20($sp)
    sw      $s5, 24($sp)
    sw      $s6, 28($sp)
    sw      $s7, 32($sp)
    li   $s7, GRIDSIZE
    move $s0, $a1     # row
    move $s1, $a2     # col

    move $s2, $a0     # current_board
    move $s3, $a3     # puzzle

    li      $t3, 1
    sw      $t3, PICKUP_POWERUP($0)

        la      $t0, inventory
        sw      $t0, GET_INVENTORY($0)
        lbu     $t0, 8($t0)                 # $t1 = invalid (char)
        beq     $t0, $0, no_power_solve
        sw      $0,  USE_POWERUP($0)
    
no_power_solve:

    bge  $s0, $s7, solve_done_check  # row >= GRIDSIZE
    bge  $s1, $s7, solve_done_check  # col >= GRIDSIZE
    j solve_not_done
solve_done_check:
    move $a0, $s2     # current_board
    move $a1, $s3     # puzzle
    jal board_done

    beq $v0, $0, solve_done_false  # if (done)
    move $s7, $v0     # save done
    move $a0, $s2     # current_board
    move $a1, $s3     # puzzle // same as puzzle->board
    jal copy_board

    move $v0, $s7     # $v0: done

    j solve_done

solve_not_done:

    move $a0, $s2 # current_board
    jal increment_heap
    move $s2, $v0 # update current_board

    li  $v0, 0 # changed = false
solve_start_do:

    move $a0, $s2


    jal rule1          # changed = rule1(current_board);
    move $s6, $v0      # done

    move $a0, $s2      # current_board
    jal rule2

    or   $v0, $v0, $s6 # changed |= rule2(current_board);

    bne $v0, $0, solve_start_do # while (changed)

    move $a0, $s2     # current_board
    move $a1, $s3     # puzzle
    jal board_done

    beq $v0, $0, solve_board_not_done_after_dowhile  # if (done)
    move $s7, $v0     # save done
    move $a0, $s2     # current_board
    move $a1, $s3     # puzzle // same as puzzle->board
    jal copy_board

    move $v0, $s7     # $v0: done
    j   solve_done

    li      $t3, 1
    sw      $t3, PICKUP_POWERUP($0)


solve_board_not_done_after_dowhile:


        la      $t0, inventory
        sw      $t0, GET_INVENTORY($0)
        lbu     $t0, 8($t0)                 # $t1 = invalid (char)
        beq     $t0, $0, no_power_solve2
        sw      $0,  USE_POWERUP($0)

no_power_solve2:

    mul $t0, $s0, $s7  # row*GRIDSIZE
    add $t0, $t0, $s1  # row*GRIDSIZE + col
    mul $t0, $t0, 2    # sizeof(unsigned short) * (row*GRIDSIZE + col)
    add $s4, $t0, $s2  # &current_board[row*GRIDSIZE + col]
    lhu $s6, 0($s4)    # possibles = current_board[row*GRIDSIZE + col]

    li $s5, 0 # char number = 0
solve_start_guess:
    bge $s5, $s7, solve_start_guess_end # number < GRIDSIZE
    li $t0, 1
    sll $t1, $t0, $s5 # (1 << number)
    and $t0, $t1, $s6 # (1 << number) & possibles
    beq $t0, $0, solve_start_guess_else
    sh  $t1, 0($s4)   # current_board[row*GRIDSIZE + col] = 1 << number;
    
    move $a0, $s2     # current_board
    move $a1, $s0     # next_row = row
    sub  $t0, $s7, 1  # GRIDSIZE-1
    bne  $s1, $t0, solve_start_guess_same_row # col < GRIDSIZE // col==GRIDSIZE-1
    addi $a1, $a1, 1  # row + 1
solve_start_guess_same_row:
    move $a2, $s1     # col
    addu $a2, $a2, 1  # col + 1
    divu $a2, $s7
    mfhi $a2          # (col + 1) % GRIDSIZE
    move $a3, $s3     # puzzle
    jal solve         # solve(current_board, next_row, (col + 1) % GRIDSIZE, puzzle)
    
    bne  $v0, $0, solve_done_true # if done {return true}
    sh   $s6, 0($s4)  # current_board[row*GRIDSIZE + col] = possibles;
solve_start_guess_else:
    addi $s5, $s5, 1
    j solve_start_guess

solve_done_false:
solve_start_guess_end:
    li  $v0, 0        # done = false

solve_done:
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    lw  $s2, 12($sp)
    lw  $s3, 16($sp)
    lw  $s4, 20($sp)
    lw  $s5, 24($sp)
    lw  $s6, 28($sp)
    lw  $s7, 32($sp)
    add $sp, $sp, 36
    jr      $ra

solve_done_true:
    li $v0, 1
    j solve_done

# // bool rule1(unsigned short* board) {
# //   bool changed = false;
# //   for (int y = 0 ; y < GRIDSIZE ; y++) {
# //     for (int x = 0 ; x < GRIDSIZE ; x++) {
# //       unsigned value = board[y*GRIDSIZE + x];
# //       if (has_single_bit_set(value)) {
# //         for (int k = 0 ; k < GRIDSIZE ; k++) {
# //           // eliminate from row
# //           if (k != x) {
# //             if (board[y*GRIDSIZE + k] & value) {
# //               board[y*GRIDSIZE + k] &= ~value;
# //               changed = true;
# //             }
# //           }
# //           // eliminate from column
# //           if (k != y) {
# //             if (board[k*GRIDSIZE + x] & value) {
# //               board[k*GRIDSIZE + x] &= ~value;
# //               changed = true;
# //             }
# //           }
# //         }
# //       }
# //     }
# //   }
# //   return changed;
# // }
#a0: board
rule1:
        sub     $sp, $sp, 36
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        sw      $s5, 24($sp)
        sw      $s6, 28($sp)
        sw      $s7, 32($sp)
        li      $s0, GRIDSIZE                  # $s0: GRIDSIZE = 4
        move    $s1, $a0                # $s1: board
        li      $s2, 0                  # $s2: changed = false
        li      $s3, 0                  # $s3: y = 0
r1_for_y_start:
        bge     $s3, $s0, r1_for_y_end  # for: y < GRIDSIZE
        li      $s4, 0                  # $s4: x = 0
r1_for_x_start:
        bge     $s4, $s0, r1_for_x_end  # for: x < GRIDSIZE
        mul     $a0, $s3, $s0           # $a0: y*GRIDSIZE
        add     $a0, $a0, $s4           # $a0: y*GRIDSIZE + x
        sll     $a0, $a0, 1             # $a0: 2*(y*GRIDSIZE + x)
        add     $a0, $a0, $s1           # $a0: &board[y*GRIDSIZE+x]
        lhu     $a0, 0($a0)             # $a0: value = board[y*GRIDSIZE+x]
        move    $s6, $a0                # $s6: value
        jal     has_single_bit_set
        beq     $v0, 0, r1_for_x_inc    # if(has_single_bit_set(value))
        li      $s5, 0                  # $s5: k = 0
r1_for_k_start:
        li      $t3, 1
        sw      $t3, PICKUP_POWERUP($0)

        la      $t3, inventory
        sw      $t3, GET_INVENTORY($0)
        lbu     $t3, 8($t3)                 # $t1 = invalid (char)
        beq     $t3, $0, no_power_rule1
        sw      $0,  USE_POWERUP($0)

    no_power_rule1:

        bge     $s5, $s0, r1_for_k_end  # for: k < GRIDSIZE
        beq     $s5, $s4, r1_if_kx_end  # if (k != x)
        mul     $t0, $s3, $s0           # $t0: y*GRIDSIZE
        add     $t0, $t0, $s5           # $t0: y*GRIDSIZE + k
        sll     $t0, $t0, 1             # $t0: 2*(y*GRIDSIZE + k)
        add     $t0, $t0, $s1           # $t0: &board[y*GRIDSIZE+k]
        lhu     $t1, 0($t0)             # $t1: board[y*GRIDSIZE + k]
        and     $t2, $t1, $s6           # $t2: board[y*GRIDSIZE + k] & value
        beq     $t2, 0, r1_if_kx_end    # if (board[y*GRIDSIZE + k] & value)
        not     $t3, $s6                # $t3: ~value
        and     $t1, $t1, $t3           # $t1:  board[y*GRIDSIZE + k] & ~value
        sh      $t1, 0($t0)             # board[y*GRIDSIZE + k] &= ~value
        li      $s2, 1                  # changed = true
r1_if_kx_end:   
        beq     $s5, $s3, r1_if_ky_end  # if (k != y)
        mul     $t0, $s5, $s0           # $t0: k*GRIDSIZE
        add     $t0, $t0, $s4           # $t0: k*GRIDSIZE + x
        sll     $t0, $t0, 1             # $t0: 2*(k*GRIDSIZE + x)
        add     $t0, $t0, $s1           # $t0: &board[k*GRIDSIZE+x]
        lhu     $t1, 0($t0)             # $t1: board[k*GRIDSIZE + x]
        and     $t2, $t1, $s6           # $t2: board[k*GRIDSIZE + x] & value
        beq     $t2, 0, r1_if_ky_end    # if (board[k*GRIDSIZE + x] & value)
        not     $t3, $s6                # $t3: ~value
        and     $t1, $t1, $t3           # $t1:  board[k*GRIDSIZE + x] & ~value
        sh      $t1, 0($t0)             # board[k*GRIDSIZE + x] &= ~value
        li      $s2, 1                  # changed = true
r1_if_ky_end:
        add     $s5, $s5, 1             # for: k++
        j       r1_for_k_start
r1_for_k_end:
r1_for_x_inc:
        add     $s4, $s4, 1             # for: x++
        j       r1_for_x_start  
r1_for_x_end:           
r1_for_y_inc:  
        add     $s3, $s3, 1             # for: y++
        j       r1_for_y_start
r1_for_y_end:
        move    $v0, $s2                # return changed
r1_return:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        lw      $s5, 24($sp)
        lw      $s6, 28($sp)
        lw      $s7, 32($sp)
        add     $sp, $sp, 36
        jr      $ra

# rule2 #####################################################
#
# argument $a0: pointer to current board
rule2:
    sub $sp, $sp, 4                       #Store ra onto stack and initialize GRIDSIZE
    sw $ra, 0($sp)
    li $t0, GRIDSIZE                               # GRIDSIZE
    li $t1, 1

        sw      $t1, PICKUP_POWERUP($0)

    sll $t1, $t1, $t0
    subu $t1, $t1, 1                         #int ALL_VALUES = (1 << GRIDSIZE) - 1;
    li $v0, 0                               #bool changed = false
    li $t2, 0                               #i = 0
rule2iloopstart:
    bge $t2, $t0, rule2iloopend
    li $t3, 0                               #j = 0
    rule2jloopstart:
        bge $t3, $t0, rule2jloopend
        
        mul $t4, $t2, $t0
        add $t4, $t4, $t3
        mul $t4, $t4, 2                     #sizeof(unsigned short)*(i*GRIDSIZE + j)
        add $t4, $a0, $t4                   #address of board[i*GRIDSIZE+j]
        lhu $t4, 0($t4)                     #board[i*GRIDSIZE + j]
        
        sub $sp, $sp, 24                    # Allocate stack 
        sw $a0, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        sw $t2, 12($sp)
        sw $t3, 16($sp)
        sw $v0, 20($sp)                     #Store all necessary variables on stack
        move $a0, $t4
        jal has_single_bit_set
        lw $a0, 0($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        lw $t2, 12($sp)
        lw $t3, 16($sp)
        move $t4, $v0                       # Save $v0 into $t4
        lw $v0, 20($sp)                     # Restore variables
        add $sp, $sp, 24                    # Deallocate stack

        bne $t4, $0, rule2continuestatement #if (has_single_bit_set(value)) continue;
        
        li $t5, 0                           #isum = 0
        li $t6, 0                           #jsum = 0
        li $t4, 0                           #k = 0, t2 = i, t3 = j, t4 = k
        rule2kloopstart:
            bge $t4, $t0, rule2kloopend
            beq $t4, $t3, rule2kequalsj
                mul $t7, $t2, $t0           #i*GRIDSIZE
                add $t7, $t7, $t4           #i*GRIDSIZE+k
                mul $t7, $t7, 2
                add $t7, $a0, $t7           #&board[i*GRIDSIZE + k]
                lhu $t7, 0($t7)
                or $t6, $t6, $t7            #jsum |= board[i*GRIDSIZE + k];
        rule2kequalsj:
            beq $t4, $t2, rule2kequalsi     
                mul $t7, $t4, $t0           #k*GRIDSIZE
                add $t7, $t7, $t3           #k*GRIDSIZE+j
                mul $t7, $t7, 2
                add $t7, $a0, $t7           #&board[k*GRIDSIZE + j]
                lhu $t7, 0($t7)
                or $t5, $t5, $t7            #isum |= board[k*GRIDSIZE + j];
        rule2kequalsi:
            add $t4, $t4, 1
            j rule2kloopstart
        rule2kloopend:
        beq $t1, $t6, rule2allvalequalsjsum
            not $t6, $t6                    # ~jsum
            and $t6, $t1, $t6               #ALL_VALUES & ~jsum
            mul $t7, $t0, $t2               # i*GRIDSIZE
            add $t7, $t7, $t3               #[i*GRIDSIZE+j]
            mul $t7, $t7, 2                 #(i*GRIDSIZE+j)*sizeof(unsigned short)
            add $t7, $a0, $t7
            sh $t6, 0($t7)                  #board[i*GRIDSIZE + j] = ALL_VALUES & ~jsum;
            li $v0, 1
            j rule2continuestatement
        rule2allvalequalsjsum:
        beq $t1, $t5, rule2continuestatement
            not $t5, $t5                    # ~isum
            and $t5, $t1, $t5               #ALL_VALUES & ~isum;
            mul $t7, $t0, $t2               # i*GRIDSIZE
            add $t7, $t7, $t3               #[i*GRIDSIZE+j]
            mul $t7, $t7, 2                 #(i*GRIDSIZE+j)*sizeof(unsigned short)
            add $t7, $a0, $t7
            sh $t5, 0($t7)                  #board[i*GRIDSIZE + j] = ALL_VALUES & ~isum;
            li $v0, 1
    rule2continuestatement:
        add $t3, $t3, 1
        j rule2jloopstart                   #continue; iterates to next index of jloop
    rule2jloopend:
    add $t2, $t2, 1
    j rule2iloopstart
rule2iloopend:

    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra


# board done ##################################################
#
# argument $a0: pointer to current board to check
# argument $a1: pointer to puzzle struct
board_done:
    sub $sp, $sp, 36
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)
    sw  $s2, 12($sp)
    sw  $s3, 16($sp)
    sw  $s4, 20($sp)
    sw  $s5, 24($sp)
    sw  $s6, 28($sp)
    sw  $s7, 32($sp)
    
    move    $s0, $a0        # s0 = current_board
    move    $s1, $a1        # s1 = puzzle

        la      $t0, inventory
        sw      $t0, GET_INVENTORY($0)
        lbu     $t0, 8($t0)                 # $t1 = invalid (char)
        beq     $t0, $0, no_power_board_done
        sw      $0,  USE_POWERUP($0)

no_power_board_done:

    li  $s2, GRIDSIZE              # s2 = GRIDSIZE
    li  $t0, 1

    sw      $t0, PICKUP_POWERUP($0)

    sll $t0, $t0, $s2       # 1 << GRIDSIZE
    sub $s3, $t0, 1     # s3 = ALL_VALUES = (1 << GRIDSIZE) - 1
    
    li  $s4, 0          # s4 = i = 0
bd_i1_loop_start:
    bge $s4, $s2, bd_i1_loop_end    # !(i < GRIDSIZE)
bd_i1_loop_body:
    li  $s5, 0          # s5 = acc = 0
    li  $s6, 0          # s6 = j = 0
bd_j1_loop_start:
    bge $s6, $s2, bd_j1_loop_end    # !(j < GRIDSIZE)
bd_j1_loop_body:
    mul $t0, $s4, $s2       # i*GRIDSIZE
    add $t0, $t0, $s6       # i*GRIDSIZE + j
    mul $t0, $t0, 2         # sizeof(unsigned short)*(i*GRIDSIZE + j)
    add $t0, $s0, $t0       # &current_board[i*GRIDSIZE + j]
    lhu $s7, 0($t0)         # s7 = value = current_board[i*GRIDSIZE + j]
    
    move    $a0, $s7
    jal has_single_bit_set
    beq $v0, $0, bd_j1_loop_increment   # if (!hsbs(value)) continue
    xor $s5, $s5, $s7
    
bd_j1_loop_increment:
    add $s6, $s6, 1     # ++ j
    j   bd_j1_loop_start
bd_j1_loop_end:
    bne $s5, $s3, bd_return_false   # if (acc != ALL_VALUES) return false
    
    li  $s5, 0          # s5 = acc = 0
    li  $s6, 0          # s6 = j = 0
bd_j2_loop_start:
    bge $s6, $s2, bd_j2_loop_end    # !(j < GRIDSIZE)
bd_j2_loop_body:
    mul $t0, $s6, $s2       # j*GRIDSIZE
    add $t0, $t0, $s4       # j*GRIDSIZE + i
    mul $t0, $t0, 2
    add $t0, $s0, $t0       # &current_board[j*GRIDSIZE + i]
    lhu $s7, 0($t0)     # s7 = value = current_board[j*GRIDSIZE + i]
    
    move    $a0, $s7
    jal has_single_bit_set
    beq $v0, $0, bd_j2_loop_increment   # if (!hsbs(value)) continue
    xor $s5, $s5, $s7
    
bd_j2_loop_increment:
    add $s6, $s6, 1     # ++ j
    j   bd_j2_loop_start
bd_j2_loop_end:
    bne $s5, $s3, bd_return_false   # if (acc != ALL_VALUES) return false
    
bd_i1_loop_increment:
    add $s4, $s4, 1     # ++ i
    j   bd_i1_loop_start
bd_i1_loop_end:
    li  $s4, 0          # s4 = i = 0
bd_i2_loop_start:
    bge $s4, $s2, bd_i2_loop_end    # !(i < GRIDSIZE)
bd_i2_loop_body:
    li  $t0, 2          # sizeof(short)
    mul $t0, $t0, $s2
    mul $t0, $t0, $s2       # sizeof(unsigned short board[GRIDSIZE*GRIDSIZE])
    add $s3, $s1, $t0       # s3 = &(puzzle->constraints)
    
    add $t0, $s4, 1     # i+1
    add $t1, $s2, 2     # GRIDSIZE+2
    mul $t0, $t0, $t1       # (i+1)*(GRIDSIZE+2)
    mul $t0, $t0, 2
    add $t0, $t0, $s3       # &puzzle->constraints[(i+1)*(GRIDSIZE+2) + 0]
    lhu $t9, 0($t0)     # t9 = left_constraint = puzzle->constraints[(i+1)*(GRIDSIZE+2) + 0]
    li  $s5, 0          # s5 = count = 0
    li  $s6, 0          # s6 = last = 0
    
    li  $s7, 0          # s7 = j = 0
bd_j3_loop_start:
    bge $s7, $s2, bd_j3_loop_end    # !(j < GRIDSIZE)
bd_j3_loop_body:
    mul $t0, $s4, $s2       # i*GRIDSIZE
    add $t0, $t0, $s7       # i*GRIDSIZE + j
    mul $t0, $t0, 2
    add $t0, $s0, $t0       # &current_board[i*GRIDSIZE + j]
    lhu $t0, 0($t0)     # t0 = current = current_board[i*GRIDSIZE + j]
    ble $t0, $s6, bd_j3_loop_increment  # !(current > last)
    add $s5, $s5, 1     # count += 1
    move    $s6, $t0        # last = current
bd_j3_loop_increment:
    add $s7, $s7, 1     # ++ j
    j   bd_j3_loop_start
bd_j3_loop_end:
    bne $s5, $t9, bd_return_false   # if (count != left_constraint) return false
    
    add $t0, $s4, 1     # i+1
    add $t1, $s2, 2     # GRIDSIZE+2
    mul $t0, $t0, $t1       # (i+1)*(GRIDSIZE+2)
    add $t0, $t0, $s2       # (i+1)*(GRIDSIZE+2) + GRIDSIZE
    add $t0, $t0, 1     # (i+1)*(GRIDSIZE+2) + GRIDSIZE + 1
    mul $t0, $t0, 2
    add $t0, $t0, $s3       # &puzzle->constraints[(i+1)*(GRIDSIZE+2) + GRIDSIZE + 1]
    lhu $t9, 0($t0)     # t9 = right_constraint = puzzle->constraints[(i+1)*(GRIDSIZE+2) + GRIDSIZE + 1]
    li  $s5, 0          # s5 = count = 0
    li  $s6, 0          # s6 = last = 0
    
    sub $s7, $s2, 1     # s7 = j = GRIDSIZE - 1
bd_j4_loop_start:
    blt $s7, $0, bd_j4_loop_end # !(j >= 0)
bd_j4_loop_body:
    mul $t0, $s4, $s2       # i*GRIDSIZE
    add $t0, $t0, $s7       # i*GRIDSIZE + j
    mul $t0, $t0, 2
    add $t0, $s0, $t0       # &current_board[i*GRIDSIZE + j]
    lhu $t0, 0($t0)     # t0 = current = current_board[i*GRIDSIZE + j]
    ble $t0, $s6, bd_j4_loop_increment  # !(current > last)
    add $s5, $s5, 1     # count += 1
    move    $s6, $t0        # last = current
bd_j4_loop_increment:
    sub $s7, $s7, 1     # -- j
    j   bd_j4_loop_start
bd_j4_loop_end:
    bne $s5, $t9, bd_return_false   # if (count != right_constraint) return false
    add $t0, $s4, 1     # i+1
    mul $t0, $t0, 2
    add $t0, $t0, $s3       # &puzzle->constraints[i + 1]
    lhu $t9, 0($t0)     # t9 = top_constraint = puzzle->constraints[i + 1]
    li  $s5, 0          # s5 = count = 0
    li  $s6, 0          # s6 = last = 0
    
    li  $s7, 0          # s7 = j = 0
bd_j5_loop_start:
    bge $s7, $s2, bd_j5_loop_end    # !(j < GRIDSIZE)
bd_j5_loop_body:
    mul $t0, $s7, $s2       # j*GRIDSIZE
    add $t0, $t0, $s4       # j*GRIDSIZE + i
    mul $t0, $t0, 2
    add $t0, $s0, $t0       # &current_board[j*GRIDSIZE + i]
    lhu $t0, 0($t0)     # t0 = current = current_board[j*GRIDSIZE + i]
    ble $t0, $s6, bd_j5_loop_increment  # !(current > last)
    add $s5, $s5, 1     # count += 1
    move    $s6, $t0        # last = current
bd_j5_loop_increment:
    add $s7, $s7, 1     # ++ j
    j   bd_j5_loop_start
bd_j5_loop_end:
    bne $s5, $t9, bd_return_false   # if (count != top_constraint) return false
    
    add $t0, $s2, 1     # GRIDSIZE+1
    add $t1, $s2, 2     # GRIDSIZE+2
    mul $t0, $t0, $t1       # (GRIDSIZE+1)*(GRIDSIZE+2)
    add $t0, $t0, $s4       # (GRIDSIZE+1)*(GRIDSIZE+2) + i
    add $t0, $t0, 1     # (GRIDSIZE+1)*(GRIDSIZE+2) + i + 1
    mul $t0, $t0, 2
    add $t0, $t0, $s3       # &puzzle->constraints[(GRIDSIZE+1)*(GRIDSIZE+2) + i + 1]
    lhu $t9, 0($t0)     # t9 = bottom_constraint = puzzle->constraints[(GRIDSIZE+1)*(GRIDSIZE+2) + i + 1]
    li  $s5, 0          # s5 = count = 0
    li  $s6, 0          # s6 = last = 0
    
    sub $s7, $s2, 1     # s7 = j = GRIDSIZE - 1
bd_j6_loop_start:
    blt $s7, $0, bd_j6_loop_end # !(j >= 0)
bd_j6_loop_body:
    mul $t0, $s7, $s2       # j*GRIDSIZE
    add $t0, $t0, $s4       # j*GRIDSIZE + i
    mul $t0, $t0, 2
    add $t0, $s0, $t0       # &current_board[j*GRIDSIZE + i]
    lhu $t0, 0($t0)     # t0 = current = current_board[j*GRIDSIZE + i]
    ble $t0, $s6, bd_j6_loop_increment  # !(current > last)
    add $s5, $s5, 1     # count += 1
    move    $s6, $t0        # last = current
bd_j6_loop_increment:
    sub $s7, $s7, 1     # -- j
    j   bd_j6_loop_start
bd_j6_loop_end:
    bne $s5, $t9, bd_return_false   # if (count != bottom_constraint) return false
bd_i2_loop_increment:
    add $s4, $s4, 1
    j   bd_i2_loop_start
bd_i2_loop_end:
    li  $v0, 1          # return true
    j   bd_return
bd_return_false:
    li  $v0, 0          # return false
bd_return:
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    lw  $s2, 12($sp)
    lw  $s3, 16($sp)
    lw  $s4, 20($sp)
    lw  $s5, 24($sp)
    lw  $s6, 28($sp)
    lw  $s7, 32($sp)
    add $sp, $sp, 36
    jr $ra

# has single bit set ###########################################
#
# argument $a0: bit mask
has_single_bit_set:

    li      $t3, 1
    sw      $t3, PICKUP_POWERUP($0)

    beq     $a0, $0, has_single_bit_set_iszero
    sub     $v0, $a0, 1             # $v0: b-1
    and     $v0, $a0, $v0           # $v0: b & (b-1)
    not     $v0, $v0                # $v0: !(b & (b-1))
    # if $v0 is zero, return zero
    bne     $v0, -1, has_single_bit_set_iszero
    li      $v0, 1
    j       has_single_bit_set_done
has_single_bit_set_iszero:
    li      $v0, 0
has_single_bit_set_done:
    jr      $ra



# increment heap ###############################################
#
# argument $a0: pointer to current board to check
increment_heap:
    sub $sp, $sp, 4
    sw  $ra, 0($sp) # save $ra on stack

    li      $t3, 1
    sw      $t3, PICKUP_POWERUP($0)

        la      $t3, inventory
        sw      $t3, GET_INVENTORY($0)
        lbu     $t3, 8($t3)                 # $t1 = invalid (char)
        beq     $t3, $0, no_power_increment
        sw      $0,  USE_POWERUP($0)

no_power_increment:

    li  $t0, GRIDSIZE
    mul $t0, $t0, $t0               # GRIDSIZE * GRIDSIZE
    mul $a1, $t0, 2
    add $a1, $a0, $a1               # new_board = old_board + GRIDSIZE*GRIDSIZE

    jal copy_board

    move $v0, $v0                   # // output the output of copy_board
    lw  $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra


# copy board ###################################################
#
# argument $a0: pointer to old board
# argument $a1: pointer to new board
copy_board:

    li      $t3, 1
    sw      $t3, PICKUP_POWERUP($0)

        la      $t3, inventory
        sw      $t3, GET_INVENTORY($0)
        lbu     $t3, 8($t3)                 # $t1 = invalid (char)
        beq     $t3, $0, no_power_copy
        sw      $0,  USE_POWERUP($0)

no_power_copy:

    li  $t0, GRIDSIZE
    mul $t0, $t0, $t0               # GRIDSIZE * GRIDSIZE
    li  $t1, 0                      # i = 0
ih_loop:
    bge $t1, $t0, ih_done           # i < GRIDSIZE*GRIDSIZE

    mul $t2, $t1, 2                 # i * sizeof(unsigned short)
    add $t3, $a0, $t2               # &old_board[i]
    lhu $t3, 0($t3)                 # old_board[i]

    add $t4, $a1, $t2               # &new_board[i]
    sh  $t3, 0($t4)                 # new_board[i] = old_board[i]

    addi $t1, $t1, 1                # i++
    j    ih_loop
ih_done:
    move $v0, $a1
    jr $ra




######################## kernel ########################

.kdata
chunkIH:    .space 32
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
        move      $k1, $at        # Save $at
.set at
        la        $k0, chunkIH
        sw        $a0, 0($k0)        # Get some free registers
        sw        $v0, 4($k0)        # by storing them to a global variable
        sw        $t0, 8($k0)
        sw        $t1, 12($k0)
        sw        $t2, 16($k0)
        sw        $t3, 20($k0)
        sw $t4, 24($k0)
        sw $t5, 28($k0)

        mfc0      $k0, $13             # Get Cause register
        srl       $a0, $k0, 2
        and       $a0, $a0, 0xf        # ExcCode field
        bne       $a0, 0, non_intrpt



interrupt_dispatch:            # Interrupt:
    mfc0       $k0, $13        # Get Cause register, again
    beq        $k0, 0, done        # handled all outstanding interrupts

    and        $a0, $k0, BONK_INT_MASK    # is there a bonk interrupt?
    bne        $a0, 0, bonk_interrupt

    and        $a0, $k0, TIMER_INT_MASK    # is there a timer interrupt?
    bne        $a0, 0, timer_interrupt

    and     $a0, $k0, REQUEST_PUZZLE_INT_MASK
    bne     $a0, 0, request_puzzle_interrupt

    li        $v0, PRINT_STRING    # Unhandled interrupt types
    la        $a0, unhandled_str
    syscall
    j    done

bonk_interrupt:
    sw      $0, BONK_ACK
    #Fill in your code here
    sw      $0, ANGLE_CONTROL($0)           # relative angle
    li      $t2, 230                        # $t2 = 230
    sw      $t2, ANGLE($0)                  # relative angle = 230 
    li      $t2, 10                         # $t2 = 10
    sw      $t2, VELOCITY($0)               # v = 10
    li      $t2, 1
    sw      $t2, PICKUP_POWERUP($0)
                                            
    j       interrupt_dispatch    # see if other interrupts are waiting

request_puzzle_interrupt:
    sw      $0, REQUEST_PUZZLE_ACK
    #Fill in your code here
    li      $t0, 1                          # solved_flag = 1
    sw      $t0, got_puzzle($0)

    # sw      $0,  USE_POWERUP($0)
    # sw      $t0, USE_POWERUP($0)

    j   interrupt_dispatch

timer_interrupt:
    sw      $0, TIMER_ACK
    #Fill in your code here
    # sw      $0, VELOCITY($0)
    # dead_loop:
    # j		dead_loop				# jump to loop

    j        interrupt_dispatch    # see if other interrupts are waiting

non_intrpt:                # was some non-interrupt
    li        $v0, PRINT_STRING
    la        $a0, non_intrpt_str
    syscall                # print out an error message
    # fall through to done

done:
    la      $k0, chunkIH
    lw      $a0, 0($k0)        # Restore saved registers
    lw      $v0, 4($k0)
    lw      $t0, 8($k0)
    lw      $t1, 12($k0)
    lw      $t2, 16($k0)
    lw      $t3, 20($k0)
    lw $t4, 24($k0)
    lw $t5, 28($k0)
.set noat
    move    $at, $k1        # Restore $at
.set at
    eret