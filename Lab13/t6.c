#include "declarations.h"

void
t6(float *restrict A, float *restrict D) {
    for (int nl = 0; nl < ntimes; nl ++) {
        A[0] = 0;
        #pragma clang loop vectorize_width(8) interleave(disable) distribute(disable) vectorize(enable)
        for (int i = 0; i < (LEN6 - 3); i ++) {
            A[i] = D[i] + (float) 1.0;
        }
        #pragma clang loop vectorize_width(8) interleave(disable) distribute(disable) vectorize(enable)
        for (int i = 0; i < (LEN6 - 3); i ++) {
            D[i + 3] = A[i] + (float) 2.0;
        }
    }
}