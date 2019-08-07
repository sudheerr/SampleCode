package com.sr.core.misc;

public class Algo1_4 {
    public static void main(String[] args) {
        String s1 = "HELL0 WORLD";
        String s2 = "HELL0";
        char[] chAr = s1.toCharArray();
        ;
        System.out.println(replaceFun(chAr));
    }

    public static char[] replaceFun(char[] chAr) {
        int len = chAr.length;
        int spaceCounter = 0;
        for (int i = 0; i < len; i++) {
            if (chAr[i] == ' ') {
                spaceCounter++;
            }
        }
        int newLen = len + (spaceCounter * 2);
        char[] newCharAr = new char[newLen];
        for (int i = len - 1; i >= 0; i--) {
            if (chAr[i] == ' ') {
                newCharAr[newLen - 1] = '%';
                newCharAr[newLen - 2] = '2';
                newCharAr[newLen - 3] = '0';
                newLen = newLen - 3;
            } else {
                newCharAr[newLen - 1] = chAr[i];
                newLen = newLen - 1;
            }
        }
        return newCharAr;

    }
}