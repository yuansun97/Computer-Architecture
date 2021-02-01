#ifndef MV_MULT
#define MV_MULT

#define SIZE 37     // SIZE may not be divisable by 4
#define ITER 1000000

float *mv_mult_vector(float mat[SIZE][SIZE], float vec[SIZE]);

#endif
