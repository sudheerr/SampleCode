package com.sr.core.misc;

//Generating all permutations of a given string
public class BackTracking{

    static int iterations=0;
	public static void main(String[] ar){
        String str ="ABCD";
        printStrs(str,0,str.length());
        //permutation("",str);
        //System.out.println("No of iterations is"+iterations);
	}
/*
My Solution
*/
	public static void printStrs(String str,int sIndex, int length){
        String buffer="";
        for(int i=sIndex;i<length;i++){
        	buffer=str.charAt(i)+str.substring(0,i)+str.substring(i+1,length);
            iterations++;

            if(sIndex==length-1)
            System.out.println(buffer);

            printStrs(buffer,sIndex+1,length);
        }
	}
/*
Internet solution
*/
    private static void permutation(String prefix, String str) {
        int n = str.length();
        if (n == 0) System.out.println(prefix);
        else {
            for (int i = 0; i < n; i++){
               iterations++;
                permutation(prefix + str.charAt(i), str.substring(0, i) + str.substring(i+1, n));
            }
                
        }
    }
}