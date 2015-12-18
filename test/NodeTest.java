package test;

/**
 * Created by sr73948 on 11/19/2015.
 */
public class NodeTest {
    public static void main(String[] args) {
        Node n = new Node(3);
        Node n2 = new Node(5);

        n.appendToTail(1);
        n.appendToTail(5);

        n.appendToTail(9);
        n.appendToTail(2);



        /*for(int i=2;i<10;i++){
            n.appendToTail(i);
        }*/
        //Node nthNode = nthToLast(n,3);
        //System.out.println("nthdata "+nthNode.data);
        //deleteDups2(n);
        //deleteNode( n.next);
        //n.logData();
    }

    /*
    You have two numbers represented by a linked list, where each node contains a single digit.
    The digits are stored in reverse order, such that the 1’s digit is at the head of the list.
    Write a function that adds the two numbers and returns the sum as a linked list.
    EXAMPLE
    Input: (3 -> 1 -> 5), (5 -> 9 -> 2)
    Output: 8 -> 0 -> 8
     */
    static Node addLists(Node n1, Node n2, int carry) {
        if (n1.next == null) {

        }

        return null;
    }

    /*
        Implement an algorithm to delete a node in the middle of a single linked list, given only access to that node.
        EXAMPLE
        Input: the node ‘c’ from the linked list a->b->c->d->e
        Result: nothing is returned, but the new linked list looks like a->b->d->e
     */
    static void deleteNode(Node toDelete) {
        // System.out.println(toDelete.data);
        toDelete.data = toDelete.next.data;
        toDelete.next = toDelete.next.next;
        //System.out.println(toDelete.data);
    }

    static Node nthToLast(Node head, int n) {
        Node p1 = head;
        Node p2 = head;
        int i = 0;
        while (i < n - 1) {
            if (p2.next == null) {
                return null;
            }
            p2 = p2.next;
            i++;
        }
        while (p2.next != null) {
            p1 = p1.next;
            p2 = p2.next;
        }
        return p1;
    }


    static Node deleteNode(Node headNode, int data) {
        Node node = headNode;
        if (node.data == data) {
            return node.next;
        }
        while (node.next != null) {
            if (node.next.data == data) {
                node.next = node.next.next;
                return headNode;
            }
            node = node.next;
        }
        return headNode;
    }

    static void deleteDups2(Node head) {
        if (head == null) return;
        Node previous = head;
        Node current = previous.next;
        while (current != null) {
            Node runner = head;
            while (runner != current) { // Check for earlier dups
                if (runner.data == current.data) {
                    Node tmp = current.next; // remove current
                    previous.next = tmp;
                    current = tmp; // update current to next node
                    break; // all other dups have already been removed
                }
                runner = runner.next;
            }
            if (runner == current) { // current not updated - update now
                previous = current;
                current = current.next;
            }
        }
    }
}


