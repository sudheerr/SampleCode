package rs.innerclass;

/*
Inner Class
*/
public class MyOuter{
	private int x = 7;
	// inner class definition
	public void makeInner() {
		MyInner in = new MyInner(); // make an inner instance
		in.seeOuter();
	}

	class MyInner {
		public void seeOuter() {
			System.out.println("Outer x is " + x);
			System.out.println(MyOuter.this);
		}
	}
	
	public static void main(String[] ar){
		System.out.println("Try 1 ");
		new MyOuter().makeInner();
		
		System.out.println("Try 2 ");
		MyOuter mo=new MyOuter();
		MyInner mi=mo.new MyInner();
		MyOuter.MyInner mi2=mo.new MyInner();
		mi.seeOuter();
		mi2.seeOuter();
	}
}