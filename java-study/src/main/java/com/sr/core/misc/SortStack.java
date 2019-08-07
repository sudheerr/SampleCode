package com.sr.core.misc;


/**
 * Created by sr73948 on 11/20/2015.
 */
public class SortStack {
    public static void main(String[] args) {
        Stack s = new Stack();
        s.push(5);
        s.push(3);
        s.push(4);
        s.push(1);
        s.push(2);

        Stack sortedStack = sortStackAsc(s);

        System.out.println(sortedStack.pop());
        System.out.println(sortedStack.pop());
        System.out.println(sortedStack.pop());
        System.out.println(sortedStack.pop());
        System.out.println(sortedStack.pop());
    }

    static Stack sortStackAsc(Stack s) {
        Stack sortStack = new Stack();
        while (!s.isEmpty()){
        	Object temp =s.pop();
            while(!sortStack.isEmpty() && (int)sortStack.peek()< (int)temp){
                s.push(sortStack.pop());
            }
            sortStack.push(temp);
        }
        return sortStack;
    }
}
