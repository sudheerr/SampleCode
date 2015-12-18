package com;

import java.io.*;
import java.util.*;
public class Test1{

    public static void main(String... ar){


        List<Integer> l = new ArrayList<Integer>();
        int num;
        System.out.println("Input");
        for(;;){
            try{
               BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
               String read = br.readLine();
               try{
                num = Integer.parseInt(read);
                if(num==42){
                    break;
                }
                l.add(new Integer(num));
               }catch(NumberFormatException e){
                System.out.println(e.getMessage());    
               }
               
            }catch(IOException e){
                System.out.println(e.getMessage());    
            }
        }
        System.out.println("Output");
        for(int i=0;i<l.size();i++){
            System.out.println(l.get(i));
        }
    }
}