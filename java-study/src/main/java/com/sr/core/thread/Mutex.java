package com.sr.core.thread;

class StackImpl2 { // (1)
	private Object[] stackArray;
	private int topOfStack;

	public StackImpl2(int capacity) {
		stackArray = new Object[capacity];
		topOfStack = -1;
	}

	//public boolean push(Object element) { // (2a) non-synchronized
	 public synchronized boolean push(Object element) { // (2b) synchronized
		if (isFull())
			return false;
		++topOfStack;
		try {
			Thread.sleep(1000);
		} catch (Exception e) {
		} // (3) Sleep a little.
		stackArray[topOfStack] = element;
		return true;
	}

	//public Object pop() { // (4a) non-synchronized
	 public synchronized Object pop() { // (4b) synchronized
		if (isEmpty())
			return null;
		Object obj = stackArray[topOfStack];
		stackArray[topOfStack] = null;
		try {
			Thread.sleep(10);
		} catch (Exception e) {
		} // (5) Sleep a little.
		topOfStack--;
		return obj;
	}

	public boolean isEmpty() {
		return topOfStack < 0;
	}

	public boolean isFull() {
		return topOfStack >= stackArray.length - 1;
	}
}

public class Mutex {
	public static void main(String[] args) {
		final StackImpl2 stack = new StackImpl2(20); // (6) Shared by the threads.
		(new Thread("Pusher") { // (7) Thread no. 1
			public void run() {
				for (;;) {
					System.out.println("Pushed: " + stack.push(2008));
				}
			}
		}).start();
		(new Thread("Popper") { // (8) Thread no. 2
			public void run() {
				for (;;) {
					System.out.println("Popped: " + stack.pop());
				}
			}

		}).start();
		System.out.println("Exit from main().");
	}
}