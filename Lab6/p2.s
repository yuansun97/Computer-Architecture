.text

# int count_painted(int *wall, int width, int radius, int coord) {
# 	int row = (coord & 0xffff0000) >> 16;
# 	int col = coord & 0x0000ffff;
# 	int value = 0;
# 	for (int row_offset = -radius; row_offset <= radius; row_offset++) {
# 		int temp_row = row + row_offset;
# 		if (width <= temp_row || temp_row < 0) {
# 			continue;
# 		}
# 		for (int col_offset = -radius; col_offset <= radius; col_offset++) {
# 			int temp_col = col + col_offset;
# 			if (width <= temp_col || temp_col < 0) {
# 				continue;
# 			}
# 			value += wall[temp_row*width + temp_col];
# 		}
# 	}
# 	return value;
# }
#
# // a0: int *wall
# // a1: int width
# // a2: int radius
# // a3: int coord

.globl count_painted
count_painted:

		sub 	$sp, $sp, 36			# alloc stack
		sw		$s0, 0($sp)				# save $s0
		sw		$s1, 4($sp)				# save $s1
		sw		$s2, 8($sp)				# save $s2
		sw		$s3, 12($sp)			# save $s3
		sw		$s4, 16($sp)			# save $s4
		sw		$s5, 20($sp)			# save $s5
		sw		$s6, 24($sp)			# save $s6
		sw		$s7, 28($sp)
		sw		$ra, 32($sp)

										# $a0 = &wall[]
										# $a1 = width
										# $a2 = radius
										# $a3 = coord

		and		$s0, $a3, 0xffff0000	# $s0 
		srl		$s0, $s0, 16			# $s0 = row 
		and		$s1, $a3, 0x0000ffff	# $s1 = col 
		add		$v0, $0, $0				# $v0 = value = 0
	
		sub		$s2, $0, $a2			# $s2 = row_offset


	for_loop_1:
		bgt 	$s2, $a2, done_loop_1	# row_offset <= radius
		add		$s3, $s0, $s2			# $s3 = temp_row = row + row_offset
		ble		$a1, $s3, done_loop_2	# if (width <= temp_row)
		blt		$s3, $0, done_loop_2	# if (remp_row < 0)

		sub		$s4, $0, $a2			# $s4 = col_offset

	for_loop_2:
		bgt		$s4, $a2, done_loop_2	# col_offset <= radius
		add		$s5, $s1, $s4			# $s5 = temp_col = col + col_offset
		ble		$a1, $s5, continue_2	# if (width <= temp_col)
		blt		$s5, $0, continue_2		# if (temp_col < 0)

		mul		$s6, $s3, $a1			# $s6 = temp_row * width
		
		add		$s6, $s6, $s5			# $s6 = index
		sll		$s6, $s6, 2				# $s6 = index * 4
		add		$s6, $s6, $a0			# $s6 = & wall[temp_row*width + temp_col]
		lw		$s7, 0($s6)				# $s6 = wall[temp_row*width + teno_col]
		add		$v0, $v0, $s7			# value += 


	continue_2:
		add		$s4, $s4, 1				# col_offset++
		j		for_loop_2				# next loop_2

	done_loop_2:
		add		$s2, $s2, 1				# row_offset++
		j		for_loop_1				# next loop_1



	done_loop_1:

		lw		$ra, 32($sp)
		lw		$s7, 28($sp)
		lw		$s6, 24($sp)			# restore $s6
		lw		$s5, 20($sp)			# restore $s5
		lw		$s4, 16($sp)			# restore $s4
		lw		$s3, 12($sp)			# restore $s3
		lw		$s2, 8($sp)				# restore $s2
		lw		$s1, 4($sp)				# restore $s1
		lw		$s0, 0($sp)				# restore $s0
		add		$sp, $sp, 36			# recover stack

		jr	$ra

	
# int* get_heat_map(int *wall, int width, int radius) {
# 	int value = 0;
# 	for (int col = 0; col < width; col++) {
# 		for (int row = 0; row < width; row++) {
# 			int coord = (row << 16) | (col & 0x0000ffff);
# 			output_map[row*width + col] = count_painted(wall, width, radius, coord);
# 		}
# 	}
# 	return output_map;
# }
#
# // a0: int *wall
# // a1: int width
# // a2: int radius


# # .globl get_heat_map
 get_heat_map:
 	# Can access output_wall from p2.s

 		sub 	$sp, $sp, 36			# alloc stack
 		sw		$s0, 0($sp)				# save $s0
		sw		$s1, 4($sp)				# save $s1
		sw		$s2, 8($sp)				# save $s2
		sw		$s3, 12($sp)			# save $s3
		sw		$s4, 16($sp)			# save $s4
		sw		$s5, 20($sp)			# save $s5
		sw		$s6, 24($sp)			# save $s6
		sw		$s7, 28($sp)	
		sw		$ra, 32($sp)	
											# $a0 = & wall[]
											# $a1 = width
											# $a2 = radius

		add		$s0, $0, $0					# $s0 = value = 0
		add		$s1, $0, $0					# $s1 = col = 0
	
	ghm_for_loop_1:
		bge		$s1, $a1, ghm_done_loop_1	# col < width
		add		$s2, $0, $0					# $s2 = row = 0
	ghm_for_loop_2:
		bge		$s2, $a1, ghm_done_loop_2	# row < width
		sll		$s3, $s2, 16				# row << 16
		and		$s4, $s1, 0x0000ffff		# col & 0xffff
		or		$s5, $s3, $s4				# $s5 = coord

		add		$a3, $s5, $0				# pass param coord
		jal		count_painted				# call count_painted() 
		add		$s6, $v0, $0				# $s6 = count_painted()
#
		mul		$s7, $s2, $a1				# row * width
		add		$s7, $s7, $s1				# $s7 = index
		mul		$s7, $s7, 4					# $s7 = int offset
		la		$s3, output_wall
		add		$s7, $s7, $s3				# $s7 = &out_map[index]

		sw		$s6, 0($s7)					# output_map[] = count_painted()

		add		$s2, $s2, 1					# row++
        j		ghm_for_loop_2

	ghm_done_loop_2:
		add		$s1, $s1, 1					# col++
		j		ghm_for_loop_1

	ghm_done_loop_1:

		lw		$ra, 32($sp)
		lw		$s7, 28($sp)
		lw		$s6, 24($sp)			# restore $s6
		lw		$s5, 20($sp)			# restore $s5
		lw		$s4, 16($sp)			# restore $s4
		lw		$s3, 12($sp)			# restore $s3
		lw		$s2, 8($sp)				# restore $s2
		lw		$s1, 4($sp)				# restore $s1
		lw		$s0, 0($sp)				# restore $s0
		add		$sp, $sp, 36			# recover stack
 		la 	$v0, output_wall
		jr	$ra
	