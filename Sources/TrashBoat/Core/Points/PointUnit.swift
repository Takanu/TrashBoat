

import Foundation

/**
Represents a PointValue with a PointType, providing additional space to describe
a numerical point value outside the confines of just it's type.

This allows you to create specific units like currency bills or health segments to change
a PointInstance value with or to represent collectible point items with.


*/
public protocol PointUnit: CustomStringConvertible {
	
	/// The name of the point unit.
	var name: String { get }
	
	/// The pluralised name of the point unit.
	var pluralisedName: String { get }
	
	/** A description of the point unit, conforms to `CustomStringConvertible` to
	be the default textual representation of this type. */
	var description: String { get }
	
	/// The type this unit represents.
	var type: PointType { get }
	
	/// The value of the unit.
	var value: PointValue { get set }
	
}


public extension PointUnit {
	/// Convenience getter for accessing the point value as an Int.
	var int: Int {
		return value.int
	}
	
	/// Convenience getter for accessing the point value as an Double.
	var double: Double {
		return value.double
	}
}
