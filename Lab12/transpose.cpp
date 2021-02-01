#include <algorithm>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "transpose.h"

// will be useful
// remember that you shouldn't go over SIZE
using std::min;

//#define tile_size 16

// modify this function to add tiling
void
transpose_tiled(int **src, int **dest) {
    int tile_size = 64;
    for (int i = 0; i < SIZE; i += tile_size) {
        for (int j = 0; j < SIZE; j += tile_size) {
            for (int x = i; x < min(i + tile_size, SIZE); x++) {
                for (int y = j; y < min(j + tile_size, SIZE); y++) {
                    dest[x][y] = src[y][x];
                }
            }
        }
    }
}
