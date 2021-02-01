.text

# short count_odd_nodes(TreeNode* head) {
#     // Base case
#     if (head == NULL) {
#         return 0;
#     }
#     // Recurse once for each child
# 	short count_left = count_odd_nodes(head->left);
#     short count_right = count_odd_nodes(head->right);
#     short count = count_left + count_right;
#     // Determine if this current node is odd
#     if (head->value%2 != 0) {
#         count += 1;
#     }
#     return count;
# }

.globl count_odd_nodes
count_odd_nodes:
									# $a0 = head
	bne		$a0, $0, recursion		# if head != NULL, then to recursion
	li 		$v0, 0					# retVal = 0
	j		done					# return 0

recursion:
	sub		$sp, $sp, 32			# alloc stack
	sw		$ra, 0($sp)				# store $ra
	sw		$a0, 4($sp)				# store $a0 (head) to the stack
	sw		$s0, 8($sp)				# strore $s0 ~ $s5
	sw		$s1, 12($sp)
	sw		$s2, 16($sp)
	sw		$s3, 20($sp)
	sw		$s4, 24($sp)
	sw		$s5, 28($sp)

count_left:
	lw		$a0, 0($a0)				# $a0 = head->left
	jal		count_odd_nodes			# count_odd_nodes(head->left) and save position to $ra
	move	$s0, $v0				# $s0 = count_left

count_right:
	lw		$s1, 4($sp)				# $s1 = head	 load the original head before left recursion
	lw		$a0, 4($s1)				# $a0 = head->right
	jal		count_odd_nodes			# count_odd_nodes(head->right) and save position to $ra
	move	$s2, $v0				# $s2 = count_right

add_count:
	add		$s3, $s0, $s2			# $s3 = count = count_left + count_right

current_node:
	lhu		$s4, 8($s1)				# $s4 = head->value
						   			# CAUTION! Here might have BUG! 
									# Is $s1 still the original head in line 38?
	rem		$s5, $s4, 2				# $s5 = head->value % 2
	beq 	$s5, $0, return_count	# if (head->value % 2 != 0)
	add 	$s3, $s3, 1				# count += 1

return_count:
	move	$v0, $s3

	lw		$s5, 28($sp)			# restore the $s0 ~ $s5
	lw		$s4, 24($sp)
	lw		$s3, 20($sp)
	lw		$s2, 16($sp)
	lw		$s1, 12($sp)
	lw		$s0, 8($sp)
	lw		$a0, 4($sp)				# restore $a0
	lw		$ra, 0($sp)				# restore $ra
	add		$sp, $sp, 32			# recover stack

done:
	jr 		$ra