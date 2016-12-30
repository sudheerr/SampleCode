package com.thread;

//which code modifications will result in both threads
//being able to participate in printing one smiley (:-)) per line continuously?
public class Smiley extends Thread {
	Smiley(String s){
		super(s);
	}
	public void run() { // (1)
		while (true) {
			synchronized (Test.class) {
				try { // (3)
					System.out.print(":"); // (4)
					sleep(100); // (5)
					System.out.print("-"); // (6)
					sleep(100); // (7)
					System.out.println(")"); // (8)
					sleep(100); // (9)
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}

	public static void main(String[] args) {
		new Smiley("S1").start();
		new Smiley("S2").start();
	}
}


class Test{
	
}