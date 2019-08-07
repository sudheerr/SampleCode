package com.sr.core.misc;


/**
 * Created by sr73948 on 11/20/2015.
 How would you design a stack which, in addition to push and pop,
 also has a function min which returns the minimum element? Push, pop and min should all operate in O(1) time.

 OPTIMIZED Version.
 */
public class StackTest {

    public static void main(String[] args) throws Exception {

        /*Important step is to make sure when multiple same mins are pushed, both has to be pushed to second stack
        * In the below line condition has to be less than and equal to, if it is just less than code is wrong.
        * key <= minStack[mintop]
        * */
        MinStack smin = new MinStack(10);
        smin.push(5);
        smin.push(3);
        smin.push(1);
        smin.push(4);
        smin.push(1);
        smin.push(3);
        smin.push(6);
        System.out.println("len: "+smin.minStack.length);

        System.out.println(smin.pop() + " : " + smin.min());
        System.out.println(smin.pop() + " : " + smin.min());
        System.out.println(smin.pop() + " : " + smin.min());
        System.out.println(smin.pop() + " : " + smin.min());
        System.out.println(smin.pop() + " : " + smin.min());
        System.out.println(smin.pop() + " : " + smin.min());
    }
}

class MinStack {
    int stackSize;
    int[] stack;
    int[] minStack;
    int top = -1, mintop = -1;

    public MinStack(int size) {
        stackSize = size;
        stack = new int[size];
        minStack = new int[size];
    }

    public void push(int key) throws Exception {
        if (top + 1 >= stackSize) {
            throw new Exception("Out of Memory");
        }
        top++;
        stack[top] = key;
        if (mintop == -1 || key <= minStack[mintop]) {
            mintop++;
            minStack[mintop] = key;
        }
    }

    public int pop() throws Exception {
        if (top == -1) {
            throw new Exception("No Element");
        }
        int key = stack[top];
        top--;
        if (key == minStack[mintop]) mintop--;
        return key;
    }

    public int min() throws Exception {
        if (mintop == -1) {
            throw new Exception("No Element");
        }
        return minStack[mintop];
    }

    public static void main(String[] args) {
        MinStack ms = new MinStack(100);
        try {
            ms.push(1);
            System.out.println("The minimun element is: " + ms.min());
            ms.push(0);
            ms.push(1);
            System.out.println("The poped element is: " + ms.pop());
            System.out.println("The minimun element is: " + ms.min());
            System.out.println("The poped element is: " + ms.pop());
            System.out.println("The minimun element is: " + ms.min());
        } catch (Exception e) {
            System.out.println(e.toString());
        }
    }
}