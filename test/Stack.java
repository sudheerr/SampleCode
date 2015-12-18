package test;

/**
 * Created by sr73948 on 11/20/2015.
 */
public class Stack {
    Node top;

    int pop() {
        Node temp;
        if (top == null) {
            return 0;
        } else {
            temp = top;
            top = top.next;
        }
        return temp.data;
    }

    void push(int data) {
        Node temp = new Node(data);
        temp.next = top;
        top = temp;
    }

    int peek() {
        if (top != null) {
            return top.data;
        } else {
            return 0;
        }
    }

    boolean isEmpty() {
        return top == null;
    }
}
