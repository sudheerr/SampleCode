package rs.innerclass;

/*
Method Local Classes
*/
class MyOuter2 {
	private String x = "Outer2";
	private static String y = "Outer2y";
	
	void doStuff() {
		String reg_var="reg_var";
		final String final_var="final_var";
		
		class MyInner {
			public void seeOuter() {
				//both static and instance variables are accessible
				System.out.println("Outer x is " + x);
				System.out.println("Outer y is " + y);
				
				/*Local varaibles are not accessible because their scope is
					until the method execution where as the innerclass instance might exist even after the
					method execution, but the final variables can be accessed.*/
				//System.out.println(reg_var); 
				System.out.println(final_var);
				
			} 
		} 
		MyInner mi = new MyInner(); // This line must come after the class
		mi.seeOuter();
	} // close outer class method doStuff()
	
	public static void doStuff2(){
		class MyInner {
			public void seeOuter() {
				//only static variables are avaible if the innerclass is in static method
				System.out.println("Static  Outer y is " + y);
			}
		}
		MyInner mi = new MyInner();
		mi.seeOuter();
	}
	
	public static void main(String[] ar){
		MyOuter2 mo= new MyOuter2();
		mo.doStuff();
		
		MyOuter2.doStuff2();
	}
} // close outer class