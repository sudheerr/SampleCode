package com.thread;

class Counter3 extends Thread {
	private int currentValue;

	public Counter3(String threadName) {
		super(threadName); // (1) Initialize thread.
		currentValue = 0;
		System.out.println(this);
		// setDaemon(true);
		start(); // (2) Start this thread.
	}

	public int getValue() {
		return currentValue;
	}

	public void run() { // (3) Override from superclass.
		try {
			while (currentValue < 5) {
				System.out.println(getName() + ": " + (currentValue++));
				Thread.sleep(250); // (4) Current thread sleeps.
			}
		} catch (InterruptedException e) {
			System.out.println(getName() + " interrupted.");
		}
		System.out.println("Exit from thread: " + getName());
	}
}

// _______________________________________________________________________________
public class AnotherClient {
	public static void main(String[] args) {
		Counter3 counterA = new Counter3("Counter A");
		Counter3 counterB = new Counter3("Counter B");
		try {
			System.out.println("Wait for the child threads to finish.");
			counterA.join(); // (5)
			if (!counterA.isAlive()) // (6)
				System.out.println("Counter A not alive.");
			counterB.join(); // (7)
			if (!counterB.isAlive()) // (8)
				System.out.println("Counter B not alive.");
		} catch (InterruptedException ie) {
			System.out.println("Main Thread interrupted.");
		}
		System.out.println("Exit from Main Thread.");
	}
}