package test;

/**
 * Created by sr73948 on 11/20/2015.
 */
public class Queue {
    Node first, last;

    void enQueue(int data) {
        Node temp = new Node(data);
        if (first == null) {
            first = last = temp;
        } else {
            last.next = temp;
            last = last.next;
        }
    }

    Node deQueue() {
        Node temp = null;
        if (first != null) {
            temp = first;
            first = first.next;
        }
        return temp;
    }
}
