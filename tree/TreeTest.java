package tree;

/**
 * Created by sr73948 on 11/24/2015.
 *
 *               a
 *         b          e
 *     c      d
 *         f    g
 *
 *
 *    PreOrder Traversal    a b c d f g e
 *    PostOrder Traversal   c f g d b e a
 *    InOrder Traversal     c b f d g a e
 */
public class TreeTest {
    public static void main(String[] args){

        Tree tree = new Tree();

        Node root = new Node('a', null);
        tree.setRoot(root);
        root.setLeft(new Node('b', root));
        root.setRight(new Node('e', root));
        Node temp =root.getLeft();
        temp.setLeft(new Node('c', temp));
        temp.setRight(new Node('d', temp));
        temp =temp.getRight();
        temp.setLeft(new Node('f', temp));
        temp.setRight(new Node('g', temp));

        System.out.println("Expected true : "+root.isRoot());
        System.out.println("Expected false : "+root.isLeaf());
        System.out.println("Expected false : "+temp.isRoot());
        System.out.println("Expected false : "+temp.isLeaf());
        System.out.println("Expected true : "+temp.getLeft().isLeaf());

        root.displayPreOrderTraversal(root);
        System.out.println();
        root.displayPostOrderTraversal(root);
        System.out.println();
        root.displayInOrderTraversal(root);
    }


}
