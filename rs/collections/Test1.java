package rs.collections;
import java.util.LinkedList;
import java.util.Vector;

public class Test1 {
	public static void main(String[] args) {
		Integer int1 = new Integer(10);
		Vector<Integer> vec1 = new Vector<Integer>();
		LinkedList<Integer> list = new LinkedList<Integer>();

		list.add(int1);
		vec1.add(int1);

		if (vec1.equals(list))
			System.out.println("equal");
		else
			System.out.println("not equal");
	}
}