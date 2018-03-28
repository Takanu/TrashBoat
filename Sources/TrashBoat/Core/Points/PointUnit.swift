

import Foundation

/**
Defines a unit that can be given to a PointInstance to increase or decrease it's value.

Allows you to create specific units like currency bills or health segments to change
a PointInstance value.
*/
public struct PointUnit: CustomStringConvertible {
	
	/// The name of the point unit.
	public private(set) var name: String
	
	/// The pluralised name of the point unit.
	public private(set) var pluralisedName: String
	
	/// A description of the point unit.
	public private(set) var description: String
	
	/// The value of the unit.
	public private(set) var value: PointValue
}
