package com.collections;

import java.util.ArrayList;
import java.util.Iterator;

public class IteratorUsage {
	public static void main(String[] args) {
		int sum = 0;
		ArrayList<Integer> collection = new ArrayList<Integer>();
		collection.add(10);
		collection.add(20);
		collection.add(30);
		Iterator it = collection.iterator();
		while(it.hasNext()){
			it.next();
			collection.get(1);
			
		}
		System.out.println(collection);
	}

}