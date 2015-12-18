package rs.collections;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.Collections;

public class Test4 {
	public static void main(String[] ar) throws IOException{
		
		ArrayList<String> c= new ArrayList<String>();
		c.add("Say");
		c.add("Hi");
		FileOutputStream fout;
		try {
			fout = new FileOutputStream("C:\\Users\\sr73948\\address.txt");
			ObjectOutputStream oos = new ObjectOutputStream(fout);   
			oos.writeObject(c);
			oos.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	
	}
}
