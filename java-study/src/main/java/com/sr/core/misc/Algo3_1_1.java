package com.sr.core.misc;


/**
 * Created by sr73948 on 11/20/2015.
 * Describe how you could use a single array to implement three stacks.
 */
public class Algo3_1_1 {

    public static void main(String[] args) {
        Algo3_1_1 obj = new Algo3_1_1();
        obj.push(1, 10);
        obj.push(1, 20);
        System.out.println(obj.isEmpty(0));
        System.out.println(obj.isEmpty(1));
        System.out.println(obj.isEmpty(2));
    }

    int stackSize = 100;
    int[] buffer = new int[3 * stackSize];
    int[] stackPointer = {0, 0, 0};

    void push(int stackNum, int value) {
        int index = (stackNum * 100) + stackPointer[stackNum] + 1;
        stackPointer[stackNum]++;
        buffer[index] = value;
    }

    int pop(int stackNum) {
        int index = (stackNum * 100) + stackPointer[stackNum];
        int data = buffer[index];
        stackPointer[stackNum]--;
        buffer[index] = 0;
        return data;
    }

    int peek(int stackNum) {
        int index = (stackNum * 100) + stackPointer[stackNum];
        return buffer[index];
    }

    boolean isEmpty(int stackNum) {
        return (stackPointer[stackNum] == 0);
    }
}
