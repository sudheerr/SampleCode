package com.thread;
//Which statements are true about the following code?
//(a) The first number printed is 13.
//(b) The number 14 is printed before the number 22.
//(c) The number 24 is printed before the number 21.
//(d) The last number printed is 12.
//(e) The number 11 is printed before the number 23.
public class Joining {
	static Thread createThread(final int i, final Thread t1) {
		
		
		Thread t2 = new Thread() {
			public void run() {
				System.out.println(i + 1);
				try {
					t1.join();
				} catch (InterruptedException ie) {
				}
				System.out.println(i + 2);
			}
		};
		
		
		System.out.println(i + 3);
		t2.start();
		
		
		System.out.println(i + 4);
		return t2;
		
		
	}

	public static void main(String[] args) {
		createThread(10, createThread(20, Thread.currentThread()));
	}
}