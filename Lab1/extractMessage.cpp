/**
 * @file
 * Contains an implementation of the extractMessage function.
 */

#include <iostream> // might be useful for debugging
#include <assert.h>
#include "extractMessage.h"

using namespace std;

char *extractMessage(const char *message_in, int length) {
   // Length must be a multiple of 8
   assert((length % 8) == 0);

   // allocates an array for the output
   char *message_out = new char[length];
   for (int i=0; i<length; i++) {
   		message_out[i] = 0;    // Initialize all elements to zero.
	}


   unsigned long masks[] = {
      0x0102040810204080,    // stay                         

      0x0001020408102040,     // << 8 * 1 + 1 = << (9 * 1)   
      0x0000010204081020,     // << 8 * 2 + 2 = << (9 * 2)   
      0x0000000102040810,     // << 8 * 3 + 3 = << (9 * 3)   
      0x0000000001020408,     // << 8 * 4 + 4 = << (9 * 4)   
      0x0000000000010204,     // << 8 * 5 + 5 = << (9 * 5)   
      0x0000000000000102,     // << 8 * 6 + 6 = << (9 * 6)   
      0x0000000000000001,     // << 8 * 7 + 7 = << (9 * 7)   
      
      0x0204081020408000,    // >> 8 * 1 + 1  = >> (9 * 1)   
      0x0408102040800000,    // >> 8 * 2 + 2
      0x0810204080000000,    // >> 8 * 3 + 3
      0x1020408000000000,    // >> 8 * 4 + 4
      0x2040800000000000,    // >> 8 * 5 + 5
      0x4080000000000000,    // >> 8 * 6 + 6   
      0x8000000000000000,    // >> 8 * 7 + 7    
   };

   unsigned long oneGroupCharsInLong = 0;
   unsigned long resInLong = 0;
   int groups = length / 8;

   for (int i = 0; i < groups; i++) {
      oneGroupCharsInLong = 0;
      resInLong = 0;

      // Start in the first group
      // Convert 8 chars(8 bits each) into one group into one long(64 bits).
      for (int j = 7; j >= 0; j--) {
         unsigned char currentChar = message_in[i * 8 + j];
         unsigned long bitMask = 0x0;
         bitMask |= currentChar;
         oneGroupCharsInLong |= bitMask << (((7 - j) * 8));
      }

      // Mask and shift.
      for (int k = 7; k > 0; k--) {
         resInLong |= (oneGroupCharsInLong & masks[k]) << (9 * k);
         resInLong |= (oneGroupCharsInLong & masks[k + 7]) >> (9 * k); 
      }
      resInLong |= oneGroupCharsInLong & masks[0];

      // Convert resInlong(64 bits) that containing decoded message into 8 chars and store them in the *message_out.
      for (int n = 7; n >= 0; n--) {
         message_out[i * 8 + n] = (resInLong >> ((7 - n) * 8)) & 0xff;
      }
   }


	return message_out;
}
