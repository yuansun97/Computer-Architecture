## Conversion of the following C code to MIPS
## unsigned max(unsigned *array, unsigned size) {
##     unsigned currentMax = array[0];
##     for (unsigned i = 1; i < size; ++ i) {
##         if (array[i] > currentMax) {
##             currentMax = array[i];
##         }
##     }
##     return currentMax;
## }

.globl max
max:
	lw	$v0, 0($a0)		# currentMax = array[0]
	li	$t0, 1			# i = 1

max_for:
	bge		$t0, $a1, max_return	# !(i < size)
	sll		$t1, $t0, 2
	add		$t1, $a0, $t1			# $t1 = &array[i]
	lw		$t2, 0($t1)				# $t2 = array[i]
	sltu 	$t3, $v0, $t2			# (currMax < array[i]) ? 1 : 0
									# Notice: compare nums as
									# unsigned numbers
	beq		$t3, $zero, max_for_inc	# !(array[i] > currentMax)
	move	$v0, $t2				# currentMax = array[i]

max_for_inc:
	add	$t0, $t0, 1
	j	max_for

max_return:
	jr	$ra			# return currentMax
