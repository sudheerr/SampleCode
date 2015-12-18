package test;

/**
 * Given an image represented by an NxN matrix, where each pixel in the image is 4 bytes,
 * write a method to rotate the image by 90 degrees. Can you do this in place?
 */
public class Algo1_6 {
    public static void main(String[] args) {
        int[][] matrix = {{1, 2, 4, 5}, {9, 1, 6, 5}, {7, 6, 0, 8}, {9, 3, 4, 2}, {1, 5, 4, 8}};
        //System.out.println(matrix.length+" : "+matrix[0].length);
        logMatrix(matrix, 5, 4);
        processMatrix(matrix, 5, 4);
        System.out.println("After Processing");
        logMatrix(matrix, 5, 4);
    }

    public static void processMatrix(int[][] matrix, int n, int m) {
        int[] row = new int[n];
        int[] col = new int[m];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                if (matrix[i][j] == 0) {
                    row[i] = 1;
                    col[j] = 1;
                }
            }
        }

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                if (row[i] == 1 || col[j] == 1) {
                    matrix[i][j] = 0;
                }
            }
        }
    }

    public static void logMatrix(int[][] matrix, int n, int m) {
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                System.out.print(matrix[i][j] + " | ");
            }
            System.out.println();
        }

    }
}
