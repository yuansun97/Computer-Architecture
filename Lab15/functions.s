three:  .float  3.0
five:   .float  5.0
PI:     .float  3.141592
F180:   .float  180.0
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