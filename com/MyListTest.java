package com;
import com.MyList;
public class MyListTest{
    public static void main(String[] ar){
        MyList list = new MyList();
        list.add("A");
        list.add("B");
        list.add("C");
        list.showData();

        System.out.println("size : "+list.size());
        list.add("D",2);
        list.showData();
        System.out.println("size : "+list.size());
        
        System.out.println("REMOVE 1 "+list.remove(1));
        list.showData();
        System.out.println("get(2): "+list.get(2));
        list.showData();
        System.out.println("pop : "+list.pop());
        System.out.println("pop : "+list.pop());
        System.out.println("pop : "+list.pop());


    }
}