.text

# // Finds the dot product between two different arrays of size n
# // Ignore integer overflow for the multiplication

# int paint_cost(unsigned int n, unsigned int* paint, unsigned int* cost) {
# 	int total = 0;
# 	for (int i = 0; i < n; i++) {
# 		total += paint[i] * cost[i];
# 	}
# 	return total; 
# }

.globl paint_cost
paint_cost:
		sub		$sp, $sp, 20		# alloc stack
		sw		$s0, 0($sp)			# store $s0
		sw		$s1, 4($sp)			# store $s1
		sw		$s2, 8($sp)
		sw		$s3, 12($sp)
		sw		$s4, 16($sp)

		add		$v0, $zero, 0		# $v0 = total = 0
		add		$s0, $zero, 0		# $s0 = i = 0

	for_loop:	
		bgeu	$s0, $a0, done_loop	# branch if (i >= n)
		sll		$s1, $s0, 2			# $s1 = i * 4 = [i]
		add		$s2, $a1, $s1		# $s2 = &paint[i]
		add		$s3, $a2, $s1		# $s3 = &cost[i]
		lw		$s2, 0($s2)			# $s2 = paint[i]
		lw		$s3, 0($s3)			# $s3 = cost[i]
		mulou	$s4, $s2, $s3		# $s4 = paint[i] * cost[i]
		add		$v0, $v0, $s4		# total += 
		add		$s0, $s0, 1			# i++
		j	for_loop

	done_loop:
		lw		$s4, 16($sp)
		lw		$s3, 12($sp)
		lw		$s2, 8($sp)
		lw		$s1, 4($sp)
		lw		$s0, 0($sp)			# restore $s0
		add 	$sp, $sp, 20		# recover stack

		jr	$ra