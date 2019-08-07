package com.sr.core.collections;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.List;

public class TestStream {

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
/*		SimpleVNO latest = new SimpleVNO(9, 1, 1);
		
		
		FileOutputStream outputFile = new FileOutputStream("obj-storage.dat");
		ObjectOutputStream outputStream = new ObjectOutputStream(outputFile);
		outputStream.writeObject(latest);*/
		
		FileInputStream inputFile = new FileInputStream("obj-storage.dat");
		ObjectInputStream inputStream = new ObjectInputStream(inputFile);
		try {
			SimpleVNO latest2 = (SimpleVNO)inputStream.readObject();
			System.out.println(latest2);
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		
		
		
	}

}
