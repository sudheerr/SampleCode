package com.collections;

import java.io.FileNotFoundException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

//import java.util.stream.Collectors;
import org.apache.commons.lang.StringEscapeUtils;
//import static org.apache.commons.lang.StringEscapeUtils.escapeHtml;
public class Test {

	public static void main(String[] args) throws Exception{
		System.out.println("Hello1");
		if(args.length==0){
			try{
				throw new Exception(){};
			}finally{
				System.out.println("Hello");
			}	
		}
		
		System.out.println("Hello2");

		/*String str= "bellow, bray, bray, break up, break up, cachinnate, cachinnation, cackle, cackle, cackle, cackle, cackle, cackle, chortle, chortle, chortle, chortle, chortle, chortle, chortle, chortle, chuckle, chuckle, chuckle, chuckle, chuckle, chuckle, convulse, convulse, crack up, crack up, giggle, giggle, giggle, giggle, giggle, giggle, grin, grin, grinning, guffaw, guffaw, guffaw, guffaw, guffaw, guffaw, guffaw, haw-haw, hee-haw, hee-haw, horselaugh, howl, howl, howl, howl, jeer, jeer, jeer, jeer, laugh, laugh, roar, roar, roar, roar, roar, scoff, shriek, simper, smile, smirk, smirk, sneer, snicker, snicker, snicker, snicker, snicker, snigger, snigger, snigger, snort, snort, titter, titter, titter, titter";
	
		String s1  = deDup(str);
		try(  PrintWriter out = new PrintWriter( "filename.txt" )  ){
		    out.println( s1 );
		}*/
		
		/*String upb  = String.format("%.6f", 512435.4546);	
		String upb2  = String.format("%,.6f", 1940766.00);
		System.out.println(upb);
		System.out.println(upb2);*/
		System.out.println(StringEscapeUtils.escapeHtml("&#x2714;"));
		System.out.println(StringEscapeUtils.escapeHtml("The less than sign (<) and ampersand (&) must be escaped before using them in HTML"));
		/*Timestamp timestamp = new Timestamp(timeInMillis);
		timestamp.setNanos((int) (timeInNanos % 1000000000));*/
		
		String testStr2 = "&#x2714;";
		String testStr = "< > \" &";

		System.out.println("Original :✓ " + testStr);
		System.out.println("Escaped : " + StringEscapeUtils.escapeJava(testStr2));
		System.out.println("Escaped : " + StringEscapeUtils.escapeHtml(testStr2));

		//System.out.println("Escaped : " + StringEscapeUtils.escapeHtml(testStr));
		
		//Timestamp ts = new Timestamp(Calendar.getInstance().getTimeInMillis());
		//System.out.println(timestamp);
	}
	
	/*public static String deDup(String s) {
	    return Arrays.stream(s.split(","))
	    		.distinct()
	    		.sorted()
	    		.collect(Collectors.joining(","));
	}*/
}
