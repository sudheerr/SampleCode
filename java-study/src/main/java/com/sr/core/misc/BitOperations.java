package com.sr.core.misc;

public class BitOperations {

	public static void main(String[] args) {
		int b=2;

		// result is -3 in binary it will be 1111 1101
		System.out.println(~b); 
		/**
		 * Negative Bits are saved in two's complement.
		 * 0000 0010 (b)
		 * 
		 * 1111 1101 (~b)
		 * 
		 *  (step 1) When the machine see a leading 1 it is treated as a negative number
		 *  (step 2)It then inverts the bits
		 * 			0000 0010
		 *   (step 3) Adds 1
		 *   		0000 0011
		 *   Result will be -3
		 */
	}
}
