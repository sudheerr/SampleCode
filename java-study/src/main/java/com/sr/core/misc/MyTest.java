package com.sr.core.misc;

import java.util.HashMap;
import java.util.ArrayList;
//import java.lang.String;
//import java.lang.Integer;

public class MyTest{
	public static void main(String[] args){
		System.out.println("MyTest main");
		String [] words = {"Stack", "over", "flow"};
		String [] more = {"java", "javascript", "c"};
		
		
		
		/*
		ArrayList aList = merge(words,more);
		logList(aList);
		hashMapTest();
		*/
	}

/** Merge two arrays of strings into ArrayList.*/
	static ArrayList merge(String[] words, String[] more){
		ArrayList<String> aList = new ArrayList<String>();
		for (String w : words){
			aList.add(w);
		}
		for (String w : more){
			aList.add(w);
		}
		return aList;
	}

	static void logList(ArrayList aList){
		if (aList!= null){
			int size = aList.size();
			for (int index=0; index < size; index++){
				System.out.println(aList.get(index));
			}	
		}		
	}

	static void hashMapTest(){
		System.out.println("inside hashMapTest");
		String [] students = new String[]{"a", "b", "c"};
		int size = students.length;
		HashMap<Integer,String> myMap = new HashMap<Integer,String>(size);
		for (int index=0;index<size;index++){
			myMap.put(index,students[index]);
		}

		for (int index=0;index<size;index++){
			System.out.println(myMap.get(index));
		}
	}

}