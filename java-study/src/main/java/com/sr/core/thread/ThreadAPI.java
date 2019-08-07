package com.sr.core.thread;

public class ThreadAPI {
	private static Thread t1 = new Thread("T1") {
		public void run() {
			/*try {
				wait(1000);
			} catch (InterruptedException ie) {
			}*/
		}
	};
	private static Thread t2 = new Thread("T2") {
		public void run() {
			//notify();
		}
	};
	private static Thread t3 = new Thread("T3") {
		public void run() {
			yield();
		}
	};
	private static Thread t4 = new Thread("T4") {
		public void run() {
			try {
				sleep(100);
			} catch (InterruptedException ie) {
			}
		}
	};

	public static void main(String[] args) {
		t1.start();
		t2.start();
		t3.start();
		t4.start();
		try {
			t4.join();
		} catch (InterruptedException ie) {
		}
	}
}