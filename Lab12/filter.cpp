#include <stdio.h>
#include <stdlib.h>
#include "filter.h"

// modify this code by fusing loops together
void
filter_fusion(pixel_t **image1, pixel_t **image2) {
    //----------- Fusion f1 and f2 -----------
    // filter1(image1, image2, 1);
    // for (int i = 2; i < SIZE - 2; i++) {
    //     filter1(image1, image2, i);
    //     filter2(image1, image2, i);
    // }
    // filter1(image1, image2, SIZE - 2);
    // for (int i = 1; i < SIZE - 5; i ++) {
    //     filter3(image2, i);
    // }

    //------------- Fusion ALL ---------------
    filter1(image1, image2, 1);
    for (int i = 2; i < 6; i++) {
        filter1(image1, image2, i);
        filter2(image1, image2, i);
    }
    filter1(image1, image2, SIZE - 2);
    for (int i = 6; i < SIZE - 2; i++) {
        filter1(image1, image2, i);
        filter2(image1, image2, i);
        filter3(image2, i - 5);
    }
    filter3(image2, SIZE - 7);
    filter3(image2, SIZE - 6);

    //-------------- No fusion----------------
    // for (int i = 1; i < SIZE - 1; i ++) {
    //     filter1(image1, image2, i);
    // }

    // for (int i = 2; i < SIZE - 2; i ++) {
    //     filter2(image1, image2, i);
    // }

    // for (int i = 1; i < SIZE - 5; i ++) {
    //     filter3(image2, i);
    // }
}


//----------- Prefetch -------------
void prefetch_1(pixel_t **image, int idx, const int PREFETCH_STEP) {
    __builtin_prefetch(image[idx + PREFETCH_STEP], 1, 2);
}

void prefetch_2(pixel_t **image1, pixel_t **image2, int idx, const int PREFETCH_STEP) {
    __builtin_prefetch(image1[idx + PREFETCH_STEP], 0, 2);
    __builtin_prefetch(image2[idx + PREFETCH_STEP], 1, 0);
}
//----------------------------------

// modify this code by adding software prefetching
void
filter_prefetch(pixel_t **image1, pixel_t **image2) {

    const int PREFETCH_STEP = 48;

    for (int i = 1; i < SIZE - 1; i ++) {
        prefetch_2(image1, image2, i, PREFETCH_STEP);
        filter1(image1, image2, i);
    }

    for (int i = 2; i < SIZE - 2; i ++) {
        prefetch_2(image1, image2, i, PREFETCH_STEP);
        filter2(image1, image2, i);
    }

    for (int i = 1; i < SIZE - 5; i ++) {
        prefetch_1(image2, i, PREFETCH_STEP);
        filter3(image2, i);
    }
}

// modify this code by adding software prefetching and fusing loops together
void
filter_all(pixel_t **image1, pixel_t **image2) {

    const int PREFETCH_STEP = 48;

    prefetch_2(image1, image2, 1, PREFETCH_STEP);
    filter1(image1, image2, 1);
    for (int i = 2; i < 6; i++) {
        prefetch_2(image1, image2, i, PREFETCH_STEP);
        filter1(image1, image2, i);
        filter2(image1, image2, i);
    }
    filter1(image1, image2, SIZE - 2);
    for (int i = 6; i < SIZE - 2; i++) {
        prefetch_2(image1, image2, i, PREFETCH_STEP);
        prefetch_1(image2, i, PREFETCH_STEP);
        filter1(image1, image2, i);
        filter2(image1, image2, i);
        filter3(image2, i - 5);
    }
    filter3(image2, SIZE - 7);
    filter3(image2, SIZE - 6);
}
