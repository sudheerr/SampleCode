package com.sr.core.misc;

public class Puzzle2 {

    public static void main(String[] args){
        int arr[] = {1, 1, 1, 1, 0, 0};
        System.out.println(findZeros(arr));
    }
    
    public static int findZeros(int[] arr){
        int len=arr.length-1;
        if(arr[len]==1){
            return 0;   
        }else if(arr[0]==0){
            return arr.length;
        }else{
            return findNoOfZeros(arr,0,len);
        }
    }
    
    public static int findNoOfZeros(int[] arr, int low, int high){
        int med=low+high/2;
        if(arr[med]==0 && arr[med-1]==1){
            return arr.length-med;
        }else{
            if(arr[med]==0){
                return findNoOfZeros(arr,low,med);  
            }else{
                return findNoOfZeros(arr,med,high);
            }
        }
    }
    
    
}
