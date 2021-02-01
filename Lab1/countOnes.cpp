/**
 * @file
 * Contains an implementation of the countOnes function.
 */
#include <iostream>
using namespace std;

unsigned countOnes(unsigned input) {
	// TODO: write your code here
	unsigned mask1Right  = 0x55555555;
	unsigned mask1Left   = 0xAAAAAAAA;
	unsigned mask2Right  = 0x33333333;
	unsigned mask2Left   = 0xCCCCCCCC;
	unsigned mask4Right  = 0x0F0F0F0F;
	unsigned mask4Left   = 0xF0F0F0F0;
	unsigned mask8Right  = 0x00FF00FF;
	unsigned mask8Left   = 0xFF00FF00;
	unsigned mask16Right = 0x0000FFFF;
	unsigned mask16Left  = 0xFFFF0000;

	input = (input & mask1Right) + ((input & mask1Left) >> 1);
	input = (input & mask2Right) + ((input & mask2Left) >> 2);
	input = (input & mask4Right) + ((input & mask4Left) >> 4);
	input = (input & mask8Right) + ((input & mask8Left) >> 8);
	input = (input & mask16Right) + ((input & mask16Left) >> 16);

	return input;
}
