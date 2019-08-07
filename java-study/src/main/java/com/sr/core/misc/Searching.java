package com.sr.core.misc;

/**
 * Created by sr73948 on 11/24/2015.
 */
public class Searching {

    public static void main(String[] args){
        int arr[] = {1,2, 3,4, 5, 6, 7, 8 ,9};
        int sortArr[] = {0,6,5, 3, 4, 8, 9, 1, 2};
        //System.out.println(" index : "+binarySearch(arr, 0, 8, 4));
        mergeSort(sortArr);
        printNumbers(sortArr);
    }

    public static int binarySearch(int[] array, int low, int high, int val){
        if (high< low){
            return -1;
        }
        int mid = (high+low)/2;
        if(array[mid]>val){
            return binarySearch(array, low, mid, val);
        }else if( array[mid]<val){
            return binarySearch(array, mid, high, val);
        }else{
            return  mid;
        }
    }

    public static void mergeSort(int[] arr){
        int len = arr.length;
        if (len <= 1) {
            return;
        }
        int half = len / 2;
        int rhalf = len - half;

        int[] leftArray = new int[half];
        int[] rightArray = new int[rhalf];

        for (int i = 0; i < half; i++) {
            leftArray[i] = arr[i];
        }

        for (int i = 0; i < rhalf; i++) {
            rightArray[i] = arr[i + half];
        }

        mergeSort(leftArray);
        mergeSort(rightArray);

        merge(arr, leftArray, rightArray);
    }

    public static void merge(int[] result, int[] left, int[] right) {

        int i1 = 0; // index into left array
        int i2 = 0; // index into right array
        for (int i = 0; i < result.length; i++) {
            if (i2 >= right.length
                    || (i1 < left.length && left[i1] <= right[i2])) {
                result[i] = left[i1]; // take from left
                i1++;
            } else {
                result[i] = right[i2]; // take from right
                i2++;
            }
        }
    }



    /**
     * Idea is to replace the least value first
     * @param sortArray
     */
    public static void selectionSort(int[] sortArray){
        int len= sortArray.length, min;
        for (int i=0;i< len;i++){
            min =i;
            for (int j=i+1;j<len;j++){
                if(sortArray[j]<sortArray[min]){
                    min=j;
                }
            }
            if(min!=i){
                int temp = sortArray[i];
                sortArray[i] = sortArray[min];
                sortArray[min] = temp;
            }
        }
    }

    public static void insertionSort(int[] sortArray){
        for(int i=1;i<sortArray.length;i++){
            int pivot = sortArray[i];
            for(int j=i-1; j>-1 && pivot < sortArray[j];j--){
                sortArray[j+1]=sortArray[j];
                sortArray[j]= pivot;
            }
        }
    }

    public static void bubbleSort(int[] sortArray){
        int len= sortArray.length;
        for(int i=0;i<len;i++){
            for(int j=0;j<len-i-1;j++){
                if(sortArray[j]>sortArray[j+1]){
                    int temp =sortArray[j];
                    sortArray[j]=sortArray[j+1];
                    sortArray[j+1]= temp;
                }
            }
        }
    }
    private static void printNumbers(int[] input) {

        for (int i = 0; i < input.length; i++) {
            System.out.print(input[i] + ", ");
        }
        System.out.println("\n");
    }
}
