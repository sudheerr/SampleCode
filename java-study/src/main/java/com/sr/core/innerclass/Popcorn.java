package com.sr.core.innerclass;

/*Annonymous inner class

the whole point of making an anonymous inner class�to override
one or more methods of the superclass
*/

public class Popcorn {
	public void pop() {
		System.out.println("popcorn");
	}
}
class Food {
	Popcorn p = new Popcorn() {
		public void sizzle() {
			System.out.println("anonymous sizzling popcorn");
		}
		public void pop() {
			System.out.println("anonymous popcorn");
		}
	};//should end with a semicolon
	
	public void popIt() {
		p.pop(); // OK
	//	p.sizzle(); // Not Legal! Popcorn does not have sizzle()
	}
}

/*Another flavor of Annonymous inner class

	Implementing an interface on the fly
	
	One more thing to keep in mind about anonymous interface implementers�they
	can implement only one interface.
*/
interface Cookable {
	public void cook();
}
class Food2 {
	Cookable c = new Cookable() {
		public void cook() {
			System.out.println("anonymous cookable implementer");
		}
	};
}


/*Another variance method argument*/
class MyWonderfulClass {
	void go() {
		Bar b = new Bar();
		b.doStuff(new Foo(){public void foof(){}});
	}
}
interface Foo {
	void foof();
}
class Bar {
	void doStuff(Foo f) { }
}