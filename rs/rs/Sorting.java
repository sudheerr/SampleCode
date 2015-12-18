package rs.rs;

import java.util.Arrays;

public class Sorting {

	public static void main(String[] ar) {

		int[] arr = { 9, 8, 7, 6, 5, 4, 3, 2, 1 };
		// bubbleSort(arr);
		// insertionSort(arr);
		// selectionSort(arr);
		//Arrays.sort(arr);
		mergeSort(arr);
		printNumbers(arr);
		int index = binarySearch(arr, 6, 0, 10);
		System.out.println("index " + index);
		

	}

	public static void bubbleSort(int[] arr) {
		int len = arr.length, temp;

		for (int i = 0; i < len; i++) {
			for (int j = 0; j < len - i - 1; j++) {
				if (arr[j] > arr[j + 1]) {
					temp = arr[j + 1];
					arr[j + 1] = arr[j];
					arr[j] = temp;
				}
			}
		}

	}

	public static void insertionSort(int[] arr) {
		int len = arr.length, key;

		for (int i = 1; i < len; i++) {
			key = arr[i];
			for (int j = i - 1; j > -1 && arr[j] > key; j--) {
				arr[j + 1] = arr[j];
				arr[j] = key;
			}
		}
	}

	public static void selectionSort(int[] arr) {
		int len = arr.length, min;

		for (int i = 0; i < len; i++) {
			min = i;

			for (int j = i + 1; j < len; j++) {
				if (arr[j] < arr[min]) {
					min = j;
				}
			}

			if (min != i) {
				int temp = arr[i];
				arr[i] = arr[min];
				arr[min] = temp;
			}
		}
	}

	/**
	 * 
	 * @param arr
	 *            Array should be sorted
	 * @param key
	 * @param low
	 * @param high
	 * @return
	 */
	public static int binarySearch(int[] arr, int key, int low, int high) {
		if (high < low) {
			return -1;
		} else {
			int mid = (low + high) / 2;
			if (arr[mid] > key) {
				return binarySearch(arr, key, low, mid - 1);
			} else if (arr[mid] < key) {
				return binarySearch(arr, key, mid + 1, high);
			} else {
				return mid;
			}
		}
	}

	private static void printNumbers(int[] input) {

		for (int i = 0; i < input.length; i++) {
			System.out.print(input[i] + ", ");
		}
		System.out.println("\n");
	}

	public static void mergeSort(int[] arr) {
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

}
