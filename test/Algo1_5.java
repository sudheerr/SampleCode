package test;

//Rotate Matrix 90deg
public class Algo1_5 {

    public static void main(String[] args) {
        // TODO Auto-generated method stub

        int[][] matrix = {{0, 1, 2, 3}, {4, 5, 6, 7}, {8, 9, 10, 11}, {12, 13, 14, 15}};
        logMatrix(matrix, 4);
        rotateMatrix(matrix, 4);
        System.out.println("After Rotation");
        logMatrix(matrix, 4);
    }

    public static void rotateMatrix(int[][] matrix, int n) {
        for (int layer = 0; layer < n / 2; layer++) {
            int first = layer;
            int last = n - 1 - layer;
            for (int i = first; i < last; i++) {
                int temp = matrix[first][i];
                int offset = i - first;
                matrix[first][i] = matrix[last - offset][first];
                matrix[last - offset][first] = matrix[last][last - offset];
                matrix[last][last - offset] = matrix[i][last];
                matrix[i][last] = temp;
            }
        }
    }

    public static void logMatrix(int[][] matrix, int n) {

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                System.out.print(matrix[i][j] + " | ");
            }
            System.out.println();
        }

    }
}
