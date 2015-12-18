package rs.rs;

import java.lang.reflect.Type;
import java.util.Date;

public class Test {

	public static void main(String[] ar){
		Type t;
		t=Color.class.getGenericSuperclass();
		System.out.println(t.toString());
		
		//
		
		Date d=new Date(1396846799680l);
		System.out.println(d);
	}
}


enum Color{
	RED
}