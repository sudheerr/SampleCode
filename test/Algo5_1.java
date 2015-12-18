package test;

/**
 * Created by sr73948 on 11/30/2015.
 * You are given two 32-bit numbers, N and M, and two bit positions, i and j.
 * Write a method to set all bits between i and j in N equal to M
 * (e.g., M becomes a substring of N located at i and starting at j).
 * EXAMPLE:
 * Input: N = 10000000000, M = 10101, i = 2, j = 6
 * Output: N =10001010100
 */
public class Algo5_1 {

    public static void main(String[] args) {
        int n = 1024;
        int m = 21;
        int i = 2;
        int j = 6;
        //System.out.println(N);
        System.out.println(updateBits2(n,m,i,j));
        System.out.println(updateBits(n,m,i,j));
        System.out.println();
        //printBinaryform(104);
        System.out.println(isPowerof2(64));
        System.out.println(bitSwapRequired(31,14));
    }

    public static int bitSwapRequired(int a, int b) {
        int count = 0;
        for (int c = a ^ b; c != 0; c = c >> 1) {
            count += c & 1;
            //count ++;
        }
        return count;
    }

    public static int updateBits2(int n, int m, int i, int j) {
        int temp = (1 << j) - 1;
        m = m & temp;
        m = m << i;
        n = n | m;
       return n;
    }

    public static int updateBits(int n, int m, int i, int j) {
        int max = ~0; /* All 1’s */
        // 1’s through position j, then 0’s
        int left = max - ((1 << j) - 1);
        // 1’s after position i
        int right = ((1 << i) - 1);
        // 1’s, with 0s between i and j
        int mask = left | right;
        // Clear i through j, then put m in there
        return (n & mask) | (m << i);
    }

    private static void printBinaryform(int number) {
        int remainder;

        if (number <= 1) {
            System.out.print(number);
            return;   // KICK OUT OF THE RECURSION
        }

        remainder = number %2;
        printBinaryform(number >> 1);
        System.out.print(remainder);
    }
    private static boolean isPowerof2(int x) {
        return ((x& (x-1))==0);
    }

    /*private static boolean isPowerof2(int x) {

        while (((x % 2) == 0) && x > 1) *//* While x is even and > 1 *//*
            x /= 2;
        return (x == 1);
    }*/
}
