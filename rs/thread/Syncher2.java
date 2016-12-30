package com.thread;

public class Syncher2 {
	final static int[] intArray = new int[2];

	private static void pause() {
		while (intArray[0] == 0) {
			try {
				intArray.wait();
			} catch (InterruptedException ie) {
				System.out.println(Thread.currentThread() + " interrupted.");
			}
		}
	}

	public static void main(String[] args) {
		Thread runner = new Thread() {
			public void run() {
				synchronized (intArray) {
					pause();
					System.out.println(intArray[0] + intArray[1]);
				}
			}
		};
		runner.start();
		intArray[0] = intArray[1] = 10;
		synchronized (intArray) {
			intArray.notify();
		}
	}
}