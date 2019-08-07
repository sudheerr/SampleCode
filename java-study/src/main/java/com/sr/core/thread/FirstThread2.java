package com.sr.core.thread;
public class FirstThread2 {
	public static void main(String[] args) {
		Counter counterA = new Counter(); // (4) Create a counter.
		Thread worker = new Thread(counterA, "Counter A");
		//System.out.println(worker);
		Thread worker2 = new Thread(counterA, "Counter B");
		
		worker.start(); // (6) Start the thread.
		worker2.start(); // (6) Start the thread.
		
		

	/*	try {
			int val;
			do {
				val = counterA.getValue(); // (7) Access the counter value.
				System.out.println("Counter value read by " + Thread.currentThread().getName() + ": " + val);
				Thread.sleep(1000); // (9) Current thread sleeps.
			} while (val < 5);
		} catch (InterruptedException e) {
			System.out.println("The main thread is interrupted.");
		}*/
		System.out.println("Exit from main() method.");
	}
}
/*
class Counter extends Thread {
	private int currentValue;

	public Counter(String threadName) {
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
*/
class Counter implements Runnable {

	private int currentValue;

	private Integer test;
	public Counter() {
		currentValue = 0;
	}

	public synchronized int getValue() {
		return currentValue;
	}
	public synchronized int increment() {
		return currentValue++;
	}

	public void run() { // (1) Thread entry point
		try {
			while (currentValue < 10) {
					increment();
					
					System.out.println("* "+Thread.currentThread().getName());
					this.notify();
					System.out.println(Thread.currentThread().getName() + ": " + getValue());
					Thread.sleep(50); // (3) Current thread sleeps.
				
			}
			
		} catch (InterruptedException e) {
			System.out.println(Thread.currentThread().getName() + " interrupted.");
		}
		System.out.println("Exit from thread: " + Thread.currentThread().getName());
	}
}


