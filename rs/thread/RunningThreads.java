package com.thread;

public class RunningThreads {
	private static Thread t1 = new Thread("T1") {
		public void run() {
			synchronized (RunningThreads.class) {
				try {
					// (1) INSERT CODE HERE ...
					//sleep(100);
					//yield();
					//wait();
					RunningThreads.class.wait(100);
				} catch (InterruptedException ie) {
					ie.printStackTrace();
				}
				System.out.println("Done");
			}
		}
	};

	public static void main(String[] args) {
		t1.start();
		try {
			t1.join();
		} catch (InterruptedException ie) {
			ie.printStackTrace();
		}
	}
}