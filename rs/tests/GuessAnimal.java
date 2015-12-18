package rs.tests;

public class GuessAnimal {
	//Java has four relational operators that can be used to compare any combination of
	//integers, floating-point numbers, or characters:
	//<,<=,>,>=	
	
	//Java also has two relational operators (sometimes called "equality operators") that
	//compare two similar "things" and return a boolean the represents what's true about
	//the two "things" being equal.
	//== , !=
	
	public static void main(String[] args) {
		String animal = "unknown";
		String test = "unknown";
		int weight = 700;
		char sex = 'm';
		double colorWaveLength = 1.630;
		float f=3.4f;
		
		if (weight >= 500) {
			animal = "elephant";
		}
		if (colorWaveLength > 1.621) {
			animal = "gray " + animal;
		}
		if (sex <= 'f') {
			animal = "female " + animal;
		}
		
		if (colorWaveLength != 'A' || f<'A') {
		}
		
		//if(animal <= test){}
		if(animal == test){}
		if(weight == f){}
		
		
		System.out.println("The animal is a " + animal);
	}
}
