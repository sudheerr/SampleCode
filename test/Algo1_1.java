package test;

import java.util.Arrays;

/**
 * Implement an algorithm to determine if a string has all unique characters.
 * What if you can not use additional data structures?
 */
public class Algo1_1 {
    public static void main(String[] args) {
        // String test = "HELLO";
/*		char[] chAr = args[0].toCharArray();
        Arrays.sort(chAr);
		int length = chAr.length;
		boolean b = false;
		for (int i = 0; i < length - 1; i++) {
			if (chAr[i] == chAr[i + 1]) {
				b = true;
			}
		}*/
        char[] chAr = new char[]{'a', 'b', 'c', 'd'};
        chAr[3] = 1;
        char ch = ' ';
        for (int i = 0; i < 255; i++) {
            System.out.println(i + " : " + (char) i);
        }
        //boolean b= isUniqueChars("abcd!");

    }

    public static boolean checkForUnique(String str) {
        boolean containsUnique = false;

        for (char c : str.toCharArray()) {
            if (str.indexOf(c) == str.lastIndexOf(c)) {
                containsUnique = true;
            } else {
                containsUnique = false;
            }
        }

        return containsUnique;
    }

    public static boolean isUniqueChars(String str) {
        int checker = 0;
        for (int i = 0; i < str.length(); i++) {
            int val = str.charAt(i) - 'a';
            if ((checker & (1 << val)) > 0) {
                System.out.println("duplicates found");
                return false;
            }
            checker |= (1 << val);
        }
        return true;
    }
}