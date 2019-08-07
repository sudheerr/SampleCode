package com.sr.core.collections.tree;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by sr73948 on 11/24/2015.
 */
public class Node {
    Node left;
    Node right;
    Node parent;
    char data;

    public Node(char data, Node parent){
        this.data = data;
        this.parent = parent;
    }

    public boolean isRoot(){
        return  parent==null;
    }

    public boolean isLeaf(){
        return  left==null && right==null;
    }

    public List<Node> getChildren(){
        List<Node> children = new ArrayList<Node>();
        children.add(left);
        children.add(right);
        return children;
    }

    public Node getLeft() {
        return left;
    }

    public void setLeft(Node left) {
        this.left = left;
    }

    public Node getRight() {
        return right;
    }

    public void setRight(Node right) {
        this.right = right;
    }

    public Node getParent() {
        return parent;
    }

    public void setParent(Node parent) {
        this.parent = parent;
    }

    public char getData() {
        return data;
    }

    public void setData(char data) {
        this.data = data;
    }

    public void displayPreOrderTraversal(Node node){
        if (node ==null){
            return;
        }
        System.out.print(node.getData()+" ");
        displayPreOrderTraversal(node.getLeft());
        displayPreOrderTraversal(node.getRight());
    }

    public void displayPostOrderTraversal(Node node){
        if (node == null){
            return;
        }

        displayPostOrderTraversal(node.getLeft());
        displayPostOrderTraversal(node.getRight());
        System.out.print(node.getData()+" ");

    }

    public void displayInOrderTraversal(Node node){
        if (node ==null){
            return;
        }
        displayInOrderTraversal(node.getLeft());
        System.out.print(node.getData()+" ");
        displayInOrderTraversal(node.getRight());

    }
}
