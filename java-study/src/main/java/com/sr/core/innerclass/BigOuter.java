package com.sr.core.innerclass;

/*Static Nested Classes

It is simply a non-inner (also called "top-level") class
scoped within another. So with static classes it's really more about name-space
resolution than about an implicit relationship between the two classes.

The class itself isn't really "static"; there's no such thing as a static class. The
static modifier in this case says that the nested class is a static member of the outer
class. That means it can be accessed, as with other static members, without having
an instance of the outer class.

Just as a static method does not have access to the instance variables and
nonstatic methods of the class, a static nested class does not have access to the instance
variables and nonstatic methods of the outer class.
*/

public class BigOuter {
	static class Nest {void go() { System.out.println("hi"); } }
}
class Broom {
	static class B2 {void goB2() { System.out.println("hi 2"); } }
	public static void main(String[] args) {
		BigOuter.Nest n = new BigOuter.Nest(); // both class names
		n.go();
		B2 b2 = new B2(); // access the enclosed class
		b2.goB2();
	}
}