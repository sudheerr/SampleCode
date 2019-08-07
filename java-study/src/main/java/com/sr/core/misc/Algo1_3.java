package com.sr.core.misc;

public class Algo1_3 {
    public static void main(String[] args) {
        String test = "HELLO";
        char[] ar = test.toCharArray();
        removeDuplicates(ar);
        System.out.println(ar);
    }

    public static void removeDuplicates(char[] str) {
        if (str == null) return;
        int len = str.length;
        if (len < 2) return;
        int tail = 1;
        for (int i = 1; i < len; ++i) {
            int j;
            for (j = 0; j < tail; ++j) {
                if (str[i] == str[j]) {
                    break;
                }

            }
            if (j == tail) {
                str[tail] = str[i];
                ++tail;

            }
        }
        str[tail] = 0;
    }
}