package com;

public class KnightTour{
    static int size=8;
    static int [][]solArray;

    static int []xArray={2,1,-1,-2,-2,-1,1,2};
    static int []yArray={1,2,2,1,-1,-2,-2,-1};


    public static void main(String[] ar){
         solArray = new int[size][size];
        
         size = Integer.parseInt(ar[0]);

         int x= Integer.parseInt(ar[1]);
         int y= Integer.parseInt(ar[2]);

        for (int i=0;i<size;i++){
            for (int j=0;j<size;j++){
                solArray[i][j]=-1;
            }
        }
        solArray[x][y] = 0;
        solvKnightTour(x,y,1);

        printSolArray();

    }

    public static boolean solvKnightTour(int x, int y, int movei){
        int k, next_x, next_y;
        
        if(movei==size*size){
            return true;
        }

        for(k=0;k<8;k++){
            next_x = x + xArray[k];
            next_y = y + yArray[k];

            if(!isSafe(next_x,next_y)){
               continue;
            }

            System.out.print(" k "+k);
            solArray[next_x][next_y] = movei;
            if (solvKnightTour(next_x, next_y, movei + 1)){
                return true;
            }else{
                solArray[next_x][next_y] = -1;
            }
                    
        }

        return false;
    }




    public static void printSolArray(){
        for (int i=0;i<size;i++){
            for (int j=0;j<size;j++){
                System.out.print(solArray[i][j]+" ");
            }
            System.out.println("");
        }        
    }

    public static boolean isSafe(int x, int y)
    {
        if (x >= 0 && x < size && y >= 0 && y < size && solArray[x][y] == -1)
            return true;
        return false;
    }
 

}