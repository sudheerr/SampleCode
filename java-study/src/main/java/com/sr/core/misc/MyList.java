package com.sr.core.misc;
public class MyList{
    Node head;
    public MyList(){
        head =new Node(5);
    }
    
    public void add(Object data){
        Node n= new Node(data);
        Node temp =head;
        while (temp.next!=null){
            temp= temp.next;
        }
        temp.next=n;
    }

    public void add(Object data, int index){
        int i=0;
        Node n= new Node(data);
        Node temp =head;
        while (temp.next!=null && i<index){
            temp= temp.next;
            i++;
        }
        n.next=temp.next;
        temp.next=n;
    }

    public boolean remove(int index){
        int i=0;
        Node temp =head;
        while (i<index){
            if(temp.next==null){
                return false;
            }
            temp= temp.next;
            i++;
        }
        Node n=temp.next;
        if (n.next!=null){
            n=n.next;
        }
        temp.next=n;
        return true;   
    }

    public Object pop(){
        Node temp =head;
        Node prev=null;
        while (temp.next!= null){
            prev=temp;
            temp=temp.next;
        }
        Object data=temp.data;
        prev.next=null;
        return data;
    }

    public void push(Object data){
        add(data);
    }

    public Object get(int index){
        Node temp =head;
        int i=0;
        while (i<=index){
            if(temp.next== null){
                return null;
            }
            temp=temp.next;
            i++;
        }
        return temp.data;
    }

    public int size(){
        Node temp =head;
        int i=0;
        while (temp.next!=null){
            temp= temp.next;
            i++;
        }
        return i;
    }

    public void showData(){
        Node temp =head;
        System.out.println("Data: ");
        while (temp.next!=null){
            temp= temp.next;
            System.out.print(temp.data+" ");
        }
        System.out.println(" ");
    }
}