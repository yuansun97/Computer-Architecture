.text

# bool rule1(unsigned short* board) {
#   bool changed = false;
#   for (int y = 0 ; y < GRIDSIZE ; y++) {
#     for (int x = 0 ; x < GRIDSIZE ; x++) {
#       unsigned value = board[y*GRIDSIZE + x];
#       if (has_single_bit_set(value)) {
#         for (int k = 0 ; k < GRIDSIZE ; k++) {
#           // eliminate from row
#           if (k != x) {
#             if (board[y*GRIDSIZE + k] & value) {
#               board[y*GRIDSIZE + k] &= ~value;
#               changed = true;
#             }
#           }
#           // eliminate from column
#           if (k != y) {
#             if (board[k*GRIDSIZE + x] & value) {
#               board[k*GRIDSIZE + x] &= ~value;
#               changed = true;
#             }
#           }
#         }
#       }
#     }
#   }
#   return changed;
# }
#a0: board

.globl rule1
rule1:

	sub		$sp, $sp, 44				# alloc stack
	sw		$ra, 0($sp)					# store return address
	sw		$a0, 4($sp)					# store &board --short  board[][]
	sw		$s0, 8($sp)				
	sw		$s1, 12($sp)				
	sw		$s2, 16($sp)					
	sw		$s3, 20($sp)					
	sw		$s4, 24($sp)					
	sw		$s5, 28($sp)					
	sw		$s6, 32($sp)					
	sw		$s7, 36($sp)
										# 40($sp) for $t0
		
	li		$t0, 4						# $t0 = 4
	sw		$t0, 40($sp)
	li		$s0, 0						# $s0 = changed = false
	li		$s1, 0						# $s1 = y = 0
for_loop_y:
	bge		$s1, $t0, restore_return	# if y >= 4 then return

	li		$s2, 0						# $s2 = x = 0
for_loop_x:
	bge		$s2, $t0, loop_y_pp			# if x >= 4 then loop_x is done, go to y++

	li		$s3, 4						# $s3 = GRIDSIZE = 4
	mul		$s3, $s3, $s1				# $s3 = y * GRIDSIZE
	add		$s3, $s3, $s2				# $s3 = y * GRIDSIZE + x
	sll		$s3, $s3, 1					# $s3 = offset for short
	add		$s3, $s3, $a0				# $s3 = & board[y * GRIDSIZE + x]
	lhu		$s3, 0($s3)					# $s3 = value     
										# NOTICE: Is $s3 short or int ????
	
	move	$a0, $s3					# $a0 = value 
	jal		has_single_bit_set			# call function
	lw		$t0, 40($sp)				# restore $t0 = GRIDSIZE = 4

	move	$s4, $v0					# $s4 = has_single_bit_set(value)

										# Reload !!!
	lw		$a0, 4($sp)					# $a0 = & board[][]  

	beq		$s4, $0, loop_x_pp			# if $s4 == false, then to loop_x_pp
	
	li		$s4, 0						# $s4 = k = 0
for_loop_k:
	bge		$s4, $t0, loop_x_pp			# if k >= 4, then loop_k is done, go to x++
	

eliminate_row:
	beq		$s4, $s2, eliminate_col		# if k == x, then go to eliminate_col

	li		$s5, 4						# $s5 = GRIDSIZE = 4
	mul		$s5, $s5, $s1				# $s5 = y * GRIDESIZE
	add		$s5, $s5, $s4				# $s5 = y * GRIDESIZE + k
	sll		$s5, $s5, 1					# $s5 = offset of short
	add		$s7, $s5, $a0				# $s7 = & board[y * GRIDESIZE + k]
	lhu		$s5, 0($s7)					# $s5 = board[y * GRIDESIZE + k]
	and		$s6, $s5, $s3				# $s6 = board[y * GRIDESIZE + k] & value

	beq		$s6, $0, eliminate_col		# if $s6 == false, then go to eliminate_col

	not		$s6, $s3					# $s6 = ~value
	and		$s5, $s5, $s6				# $s5 = board[y * GRIDESIZE + k] & ~value
	sh 		$s5, 0($s7)					
	li		$s0, 1						# changed = true

eliminate_col:
	beq		$s4, $s1, loop_k_pp			# if k == y, then go to loop_k_pp

	li		$s5, 4						# $s5 = GRIDSIZE = 4
	mul		$s5, $s5, $s4				# $s5 = k * GRIDESIZE
	add		$s5, $s5, $s2				# $s5 = k * GRIDESIZE + x
	sll		$s5, $s5, 1					# $s5 = offset of short
	add		$s7, $s5, $a0				# $s7 = & board[k * GRIDESIZE + x]
	lhu		$s5, 0($s7)					# $s5 = board[k * GRIDESIZE + x]
	and		$s6, $s5, $s3				# $s6 = board[k * GRIDESIZE + x] & value

	beq		$s6, $0, loop_k_pp			# if $s6 == false, then go to loop_k_pp

	not		$s6, $s3					# $s6 = ~value
	and		$s5, $s5, $s6				# $s5 = board[k * GRIDESIZE + x] & ~value
	sh		$s5, 0($s7)					
	li		$s0, 1						# changed = true

loop_k_pp:
	add		$s4, $s4, 1					# k++
	j		for_loop_k					# jump to for_loop_k

loop_x_pp:
	add		$s2, $s2, 1					# x++
	j		for_loop_x					# jump to for_loop_x

loop_y_pp:
	add		$s1, $s1, 1					# y++
	j		for_loop_y					# jump to for_loop_y
	

restore_return:
	move	$v0, $s0

	lw		$t0, 40($sp)
	lw		$s7, 36($sp)
	lw		$s6, 32($sp)
	lw		$s5, 28($sp)
	lw		$s4, 24($sp)
	lw		$s3, 20($sp)
	lw		$s2, 16($sp)
	lw		$s1, 12($sp)
	lw		$s0, 8($sp)
	lw		$a0, 4($sp)					# restore $a0
	lw		$ra, 0($sp)					# restore return address 
	add		$sp, $sp, 44				# recover stack
	
	jr	$ra
	
	
	
# bool solve(unsigned short *current_board, unsigned row, unsigned col, Puzzle* puzzle) {
#     if (row >= GRIDSIZE || col >= GRIDSIZE) {
#         bool done = board_done(current_board, puzzle);
#         if (done) {
#             copy_board(current_board, puzzle->board);
#         }

#         return done;
#     }
#     current_board = increment_heap(current_board);

#     bool changed;
#     do {
#         changed = rule1(current_board);
#         changed |= rule2(current_board);
#     } while (changed);

#     short possibles = current_board[row*GRIDSIZE + col];
#     for(char number = 0; number < GRIDSIZE; ++number) {
#         // Remember & is a bitwise operator
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

.globl solve
solve:

# $a0 = & current_borad
# $a1 = row
# $a2 = col
# $a3 = & puzzle
	li		$t0, 4								# $t0 = GRIDSIZE = 4

	sub		$sp, $sp, 60						# alloc stack
	sw		$ra, 0($sp)					
	sw		$a0, 4($sp)							# $a0 = & current_borad
	sw		$a1, 8($sp)							# $a1 = row
	sw		$a2, 12($sp)						# $a2 = col
	sw		$a3, 16($sp)						# $a3 = & puzzle
	sw		$t0, 20($sp)						# store $t0, GRIDSIZE = 4
	sw		$s0, 24($sp)
	sw		$s1, 28($sp)
	sw		$s2, 32($sp)
	sw		$s3, 36($sp)
	sw		$s4, 40($sp)
	sw		$s5, 44($sp)
	sw		$s6, 48($sp)
	sw		$s7, 52($sp)
												# -4 for store $v0

check_row_col:
	blt		$a1, $t0, call_increment_heap		# if row < GRIDSIZE, then go to label
	blt		$a2, $t0, call_increment_heap		# if col < GRIDSIZE, then go to laebl

call_board_done:
	lw		$a0, 4($sp)							# $a0 = & current_board
	lw		$a1, 16($sp)						# $a1 = & puzzle
	jal		board_done							# board_done(current_board, puzzle)
												# $v0 = done
	sw		$v0, 56($sp)						# store $v0 = done
	beq		$v0, $0, return						# if done == false, then target

call_copy_board:
	lw		$a0, 4($sp)							# a0 = & current_board
	lw		$a1, 16($sp)						# a1 = & puzzle = & puzzle->board
	jal		copy_board							# copy_board(current_board, puzzle->board)
	lw		$v0, 56($sp)						# reload $v0 = done
	j		return								# jump to return







call_increment_heap:
	lw		$a0, 4($sp)							# $a0 = & current_board
	jal		increment_heap						# increment_heap(current_board)
	sw		$v0, 4($sp)							# store the new current_board
	li		$s0, 0								# $s0 = changed = false

do:
	lw		$a0, 4($sp)							# $a0 = current_board
	jal		rule1								
	move	$s0, $v0							# changed = rule1(current_board)
	lw		$a0, 4($sp)							# $a0 = current_board
	jal		rule2
												# $v0 = rule2(current_board)
	or 		$s0, $s0, $v0						# changed = changed | rule2(current_board)

while:
	li		$s1, 1								# $s1 = true
	beq		$s0, $s1, do						# if changed == true, do

	lw		$a0, 4($sp)							# $a0 = current_board
	lw		$s1, 8($sp)							# $s1 = row
	lw		$s2, 12($sp)						# $s2 = col
	lw		$t0, 20($sp)						# $t0 = GRIDSIZE = 4
	mul		$s3, $s1, $t0						# $s3 = row * GRIDSIZE
	add		$s3, $s3, $s2						# $s3 = row * GRIDSIZE + col
	sll		$s3, $s3, 1							# $s3 = offset (short)
	add		$s3, $s3, $a0						# $s3 = & current_board[row * GRIDSIZE + col]
	lh		$s5, 0($s3)							# $s5 = possibles = current_board[row * GRIDSIZE + col]

	li		$s6, 0								# $s6 = (char) number = 0
for_loop:
	lw		$t0, 20($sp)						# $t0 = GRIDSIZE = 4
	li		$v0, 0								# out of loop, and return false
	bge		$s6, $t0, return					# if number >= GRIDSIZE

	li		$s7, 1
	sll		$s7, $s7, $s6						# $s7 = 1 << number
	and		$t1, $s7, $s5						# $t1 = (1 << number) & possibles
	beq		$t1, $0, next_loop					# if $t1 == false, then next loop
	

	sh		$s7, 0($s3)							# current_board[row * GRID + col] = 1 << number

	li		$s7, 3								# $s7 = GRIDSIZE - 1
	beq		$s2, $s7, row_plus					
	move	$a1, $s1							# $a1 = next_row = row
	j		recursion							
row_plus:
	add		$a1, $s1, 1							# $a1 = next_row = row + 1

recursion:
	lw		$a0, 4($sp)							# $a0 = current_board
												# $a1 = next_row
	lw		$t0, 20($sp)
	add		$a2, $s2, 1							
	rem		$a2, $a2, $t0						# $a2 = (col + 1) % GRIDSIZE
	lw		$a3, 16($sp)						# $a3 = puzzle

	jal		solve								# recursion 

	li		$s7, 1
	beq		$v0, $s7, return					# if solve() == true, then return true
	
	sh 		$s5, 0($s3)


next_loop:
	add		$s6, $s6, 1
	j		for_loop							# jump to for_loop

return:

	# sw		$a0, 4($sp)							# $a0 = & current_borad
	# sw		$a1, 8($sp)							# $a1 = row
	# sw		$a2, 12($sp)						# $a2 = col
	# sw		$a3, 16($sp)						# $a3 = & puzzle


	lw		$s7, 52($sp)
	lw		$s6, 48($sp)
	lw		$s5, 44($sp)
	lw		$s4, 40($sp)
	lw		$s3, 36($sp)
	lw		$s2, 32($sp)
	lw		$s1, 28($sp)
	lw		$s0, 24($sp)

	lw		$a3, 16($sp)
	lw		$a2, 12($sp)		 
	lw		$a1, 8($sp)
	lw		$a0, 4($sp)

	
	lw		$ra, 0($sp)
	add		$sp, $sp, 60				# recover stack

	jr 		$ra