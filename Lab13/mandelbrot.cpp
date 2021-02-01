#include "mandelbrot.h"
#include <xmmintrin.h>

// cubic_mandelbrot() takes an array of SIZE (x,y) coordinates --- these are
// actually complex numbers x + yi, but we can view them as points on a plane.
// It then executes 200 iterations of f, using the <x,y> point, and checks
// the magnitude of the result; if the magnitude is over 2.0, it assumes
// that the function will diverge to infinity.

// vectorize the code below using SIMD intrinsics
int *
cubic_mandelbrot_vector(float x[SIZE], float y[SIZE]) {
    static int ret[SIZE];
    float temp[4];
    __m128 x_1, y_1, x_2, y_2, xi, yi, x1_square, y1_square;

    int i = 0;
    for (; i < SIZE ; i += 4) {
        x_1 = _mm_set1_ps(0);
        y_1 = _mm_set1_ps(0);
        // Run M_ITER iterations
        for (int j = 0; j < M_ITER; j ++) {
            // Calculate x1^2 and y1^2
            x1_square = _mm_mul_ps(x_1, x_1);
            y1_square = _mm_mul_ps(y_1, y_1);

            // Calculate the real piece of (x1 + (y1*i))^3 + (x + (y*i))
            xi = _mm_loadu_ps(&x[i]);
            x_2 = _mm_add_ps(_mm_mul_ps(x_1, _mm_sub_ps(x1_square, _mm_mul_ps(_mm_set1_ps(3), y1_square))), xi);
            
            // Calculate the imaginary portion of (x1 + (y1*i))^3 + (x + (y*i))
            yi = _mm_loadu_ps(&y[i]);
            y_2 = _mm_add_ps(_mm_mul_ps(y_1, _mm_sub_ps(_mm_mul_ps(_mm_set1_ps(3), x1_square), y1_square)), yi);
            // Use the resulting complex number as the input for the next
            // iteration
            
            x_1 = x_2;
            y_1 = y_2;
        }

        // caculate the magnitude of the result;
        // we could take the square root, but we instead just
        // compare squares
        __m128 x_2_2 = _mm_mul_ps(x_2, x_2);
        __m128 y_2_2 = _mm_mul_ps(y_2, y_2);
        __m128 result = _mm_add_ps(x_2_2, y_2_2);
        _mm_storeu_ps(temp, result);
        int q = 0;
        while(q < 4){
            ret[i + q] = temp[q] < (M_MAG * M_MAG);
            q++;
        }
    }
    return ret;
}