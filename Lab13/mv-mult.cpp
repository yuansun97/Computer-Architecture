#include "mv-mult.h"
#include <xmmintrin.h>

// Matrix-Vector multiplication
// mat is a SIZE by SIZE matrix, that is arranged in row-column, format,
// That is, you first select a particular row, and then a particular column.
// Each row is laid out as a one-dimensional, array, so if you wanted
// to select a particular row, you would use mat[row].  You can
// also select smaller intervals, by using &mat[row][col].
// The vector is also laid out as a one-dimensional arrow, similar to a row.
// M-V multiplication proceeds by taking the dot product of a matrix row
// with the vector, and doing this for each row in the matrix

// vectorize the below code using SIMD intrinsics
float *
mv_mult_vector(float mat[SIZE][SIZE], float vec[SIZE]) {
    static float ret[SIZE];

    for (int i = 0; i < SIZE; i ++) {
        ret[i] = 0;

        float inner_product = 0.0, tmp[4];
        __m128 acc, vec_mult, X, Y;
        acc = _mm_set1_ps(0.0);

        int j = 0;
        for (; j < (SIZE - 3); j += 4) {
            // ret[i] += mat[i][j] * vec[j];
            X = _mm_loadu_ps(&mat[i][j]);
            Y = _mm_loadu_ps(&vec[j]);
            vec_mult = _mm_mul_ps(X, Y);
            acc = _mm_add_ps(acc, vec_mult);
        }

        _mm_storeu_ps(tmp, acc);
        inner_product = tmp[0] + tmp[1] + tmp[2] + tmp[3];

        for (; j < SIZE; j++) {
            inner_product += mat[i][j] * vec[j];
        }

        ret[i] = inner_product;
    }

    return ret;
}
