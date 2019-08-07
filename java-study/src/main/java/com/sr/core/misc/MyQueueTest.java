package com.sr.core.misc;

/**
 * Created by sr73948 on 11/20/2015.
 * Implement a MyQueue class which implements a queue using two stacks.
 * Algo 3.5
 */

public class MyQueueTest {

}
class MyQueue{
    Stack s1;
    Stack s2;
    public MyQueue(){
        s1 = new Stack();
        s2 =new Stack();
    }

    public void push(int data){
        s1.push(data);
    }

    public void remove(){
        if(!s2.isEmpty()){
            s2.pop();
        }else{
            while(!s1.isEmpty()){
                s2.push(s1.pop());
            }
        }
        s2.pop();
    }

    public Object peek(){
        if(!s2.isEmpty()){
        return    s2.peek();
        }else{
            while(!s1.isEmpty()){
                s2.push(s1.pop());
            }
        }
       return s2.peek();
    }
}