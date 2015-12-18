package rs.innerclass;

public class Car {
 class Engine {
	{ Car.this.drive(); System.out.println("Engine Instance Block"); System.out.println(this); }
	Engine(){System.out.println("Engine Constructor");}
	public String toString(){
		return "I am Engine";
	}
	
 }
 public static void main(String[] args) {
 	new Car().go();
 }
 void go() {
	 new Engine();
 }
 void drive() { System.out.println("hi"); }
 }