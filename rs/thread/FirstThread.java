package rs.thread;

import java.util.ArrayList;
import java.util.List;

public class FirstThread{
	public static void main(String... ar){
		
		/*MyThread thread= new MyThread();
		thread.setDaemon(true);
		thread.start();
		for(int i=0;i<100;i++){
			System.out.print(i+" ");	
		}
		System.out.println("\nExiting");*/
		List arList= new ArrayList<>(); 
		P p= new P(arList);
		p.start();
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		C c= new C(arList);
		c.start();
		
     /*  ThreadB b = new ThreadB();
       b.start();
 
     //  synchronized(b){
        try{
            System.out.println("Waiting for b to complete...");
                b.wait();
            }catch(InterruptedException e){
                e.printStackTrace();
            }
 
            System.out.println("Total is: " + b.total);
      //}
	}*/
}
}

class MyThread extends Thread {
	
	@Override
	public void run() {
		// TODO Auto-generated method stub
		for(;;){
			System.out.println("My Thread executing");	
		}
	}

}

class ThreadB extends Thread{
    int total;
    @Override
    public void run(){
        synchronized(this){
            for(int i=0; i<100 ; i++){
                total += i;
            }
            notify();
        }
    }
}



class P extends Thread{
	List l1;
	P(List l){
		l1=l;
	}
	@Override
    public void run(){
		int i=0;
		for(;;){
			synchronized(l1){
				i++;
				l1.add(i);
				try {
					System.out.println("produced "+i);
					l1.wait();
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}	
			}
			
		}
		
	}
}

class C extends Thread{
	List l2;
	C(List l){
		l2=l;
	}
	@Override
    public void run(){
		for(;;){
			synchronized(l2){
				System.out.println("consumed "+l2.get(0));
				l2.remove(0);
				l2.notify();
			}
		}
	}
}