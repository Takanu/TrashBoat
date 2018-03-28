

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
	
	/// The type this unit represents.
	public private(set) var type: PointType
	
	/// The value of the unit.
	public private(set) var value: PointValue
	
	
	public init(name: String,
							pluralisedName: String,
							description: String,
							type: PointType,
							value: PointValue) {
		
		self.name = name
		self.pluralisedName = pluralisedName
		self.description = description
		self.type = type
		self.value = value
	}
	
	
}
