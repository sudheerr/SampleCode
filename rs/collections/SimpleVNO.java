package com.collections;

import java.io.Serializable;

public class SimpleVNO implements Comparable, Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 852421342069632586L;
	// Does not override equals() or hashCode().
	private int release;
	private int revision;
	private int patch;
	private int xyz;
	
	public SimpleVNO(int release, int revision, int patch) {
		this.release = release;
		this.revision = revision;
		this.patch = patch;
		this.xyz=100;
	}

	public String toString() {
		return "(" + release + "." + revision + "." + patch + "."+xyz+")";
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + patch;
		result = prime * result + release;
		result = prime * result + revision;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (!(obj instanceof SimpleVNO))
			return false;
		SimpleVNO other = (SimpleVNO) obj;
		if (patch != other.patch)
			return false;
		if (release != other.release)
			return false;
		if (revision != other.revision)
			return false;
		return true;
	}
	
	@Override
	public int compareTo(Object obj) { // (7)
		SimpleVNO vno = (SimpleVNO) obj;
		// Compare the release numbers. (8)
		if (this.release != vno.release)
		return new Integer(release).compareTo(vno.release);
		// Release numbers are equal, (9)
		// must compare revision numbers.
		if (this.revision != vno.revision)
		return new Integer(revision).compareTo(vno.revision);
		// Release and revision numbers are equal, (10)
		// patch numbers determine the ordering.
		return new Integer(patch).compareTo(vno.patch);
		}

	
	
	

}