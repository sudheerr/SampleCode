package com;

public class RatInMaze {

    static int size = 4;
    static int maze[][]  = { {1, 0, 0, 0},
        {1, 1, 0, 1},
        {0, 1, 1, 1},
        {1, 0, 0, 1}
    };

    static int sol[][]  = { {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0},
        {0, 0, 0, 0}
    };

    public static void main(String[] ar) {
        solveMaze(0, 0);
        printSoln();
    }

    public static boolean solveMaze(int x , int y) {

        if (x == (size - 1) && y == (size - 1) ) {
            sol[x][y] = 1;
            return true;
        }

        if (isSafe(x, y) == true) {

            sol[x][y] = 1;

            if (solveMaze(x, y + 1) == true) {
                return true;
            }

            if (solveMaze(x + 1, y) == true) {
                return true;
            }
            sol[x][y] = 0;
            return false;
        }
       return false;
    }

    public static boolean isSafe(int x, int y) {
        if (x < size && y < size && maze[x][y] == 1) {
            return true;
        }
        return false;
    }

    public static void printSoln() {
        
        for (int i=0;i<size;i++){
            for (int j=0;j<size;j++){
            System.out.print(sol[i][j]);
            }
            System.out.println("");  
        }

    }    

}