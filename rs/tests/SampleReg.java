package rs.tests;

public class SampleReg {

	public static void main(String[] args) {
		
		String word="Ext.define('UIField',{ acceptFiles : {},});";
		String pattern = ",(\\s)*}";
		
		System.out.println(word.replaceAll(pattern, "}"));
		
	}
}
