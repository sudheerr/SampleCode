package com.sr.core.misc;

import java.util.HashMap;

public class Puzzle {
    public static void main(String[] ar){

        System.out.println(returnNearestPowerof2(15));
        //int arr[] = {5,4,0,3,2,4};
        //System.out.println(equilibriumIndexOfArray(arr));
        
        
         int arr[]= {4, 2, -3, 1, 6};;
        // subArrayOfZero(arr);
         
         if (printZeroSumSubarray(arr))
                System.out.println("Found a subarray with 0 sum");
            else
                System.out.println("No Subarray with 0 sum");           
         
        
    }

    /**
     * Given an integer N. tell if it is power of 3 or not.
     * @param n
     * @return
     */
    public static boolean isPowerof3(int n){
        if(n<3){return false;}
        
        while (n % 3 == 0) {
            n /= 3;
        }
        
        return n==1;
    /*    Another nice solution is 
          double d=Math.log(n)/Math.log(3);
            return (d%1==0);
            
            this is because 
            logb x= (logk x)/(logk b)
            it returns a integer(without decimals)
            k can be any real number 
    */ 
   }
    
    
     /* given n, find p which is greater than or equal to n and is a power of 2.
        IP 5, OP 8     
        IP 17, OP 32     
        IP 32, OP 32   
     */
    public static int returnNearestPowerof2(int n){
        /*double ceil=Math.ceil(Math.log(n)/Math.log(2));
        return (int)Math.pow(2, ceil);
        */
                
        //Another method is to shift p until it is greater than n;
         int p = 1;
         while (p < n) {
            p <<= 1;
         }
         return p;
         
         
         //(~(n & (n - 1))); This can be used to find If n is a power of 2
    }
    
    /*
     * equilibrium index of an array is an index such 
     * that the sum of elements at lower indexes is 
     * equal to the sum of elements at higher indexes.
     */
    
    public static int equilibriumIndexOfArray(int[] arr){
        
        int length=arr.length,  sum=0, leftsum=0;
        for(int i=0;i<length;i++){
            sum+= arr[i];
        }
        
        
        for(int i=0;i<length;i++){
            sum -= arr[i];
            if(leftsum==sum){
                return i;
            }
            leftsum += arr[i];
            
        }
        return -1;
    }
    
    
    /*
     * Find if there is a subarray with 0 sum
     * 
     * ex Input: {4, 2, -3, 1, 6} Output: true 
       There is a subarray with zero sum from index 1 to 3.
     * 
     * ex Input: {-3, 2, 3, 1, 6} Output: false
       There is no subarray with zero sum.
     */
    //Simple solution is to consider all subarrays one by one and check the sum of every subarray
    // Another implementation is available in printZeroSumSubarray
    public static void subArrayOfZero(int[] arr){
        int len=arr.length;
        
        for(int i=0;i<len;i++){
            int sum=0;  
            for(int j=i;j<len;j++){
                sum += arr[j];
                
                if(sum==0){
                    System.out.println("sub Array i:"+i+", j:"+j);
                    break;
                }else{
                    continue;
                }
            }
            
        }
    }
    
    /**
     * Though this method wont print the start and end locations,
     *  but it can verify if the array has a subarray with sum zero
     * @param arr
     * @return
     */
    public static Boolean printZeroSumSubarray(int arr[])
    {
        HashMap<Integer, Integer> hM = new HashMap<Integer, Integer>();
         
        // Initialize sum of elements
        int sum = 0;        
         
        // Traverse through the given array
        for (int i = 0; i < arr.length; i++)
        {   
            // Add current element to sum
            sum += arr[i];
             
            // Return true in following cases
            // a) Current element is 0
            // b) sum of elements from 0 to i is 0
            // c) sum is already present in hash map
            if (arr[i] == 0 || sum == 0 || hM.get(sum) != null){
                return true;
            }
            // Add sum to hash map
            hM.put(sum, i);
        }    
         
        // We reach here only when there is no subarray with 0 sum
        return false;
    }        
    
    
}
