package com.sr.core.misc;


/**
 * Created by sr73948 on 11/20/2015.
 */
public class Node {
    Object data;
    Node next;

    Node(Object data) {
        this.data = data;
    }

    void appendToTail(int data) {
        Node n = this;
        while (n.next != null) {
            n = n.next;
        }
        n.next = new Node(data);
    }

    void logData() {
        Node n = this;
        while (n.next != null) {
            System.out.println(n.data);
            n = n.next;
        }
        System.out.println(n.data);
    }
}