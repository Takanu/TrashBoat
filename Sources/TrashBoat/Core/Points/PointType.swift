

import Foundation
import Pelican


/**
Defines a type of Point that can be created and monitored by a PointManager
or initialised by using the `type` property.
*/
public struct PointType: Hashable, Equatable, CustomStringConvertible {
	
	/// The name of the currency.
	public private(set) var name: String
	
	/// The pluralised form of the currency name.
	public private(set) var pluralisedName: String
	
	/// The symbol used as a shorthand to the name of the currency.
	public private(set) var symbol: String
	
	/** A description of the point unit, conforms to `CustomStringConvertible` to
	be the default textual representation of this type. */
	public var description: String { return "\(symbol) \(name)" }
	
	/// The point type that this tag is associated and will create when a tag is given to a PointManager.
	public private(set) var instance: PointInstance.Type
	
	/// The unit type this tag is associated with, and that will be when a PointInstance using this type creates PointUnits.
	public private(set) var unit: PointUnit.Type
	
	public var hashValue: Int {
		return name.hashValue ^ pluralisedName.hashValue ^ symbol.hashValue
	}
	
	
	/**
	Initialises a new PointType, which both identifies and provides instructions for creating and managing a type of Point.
	*/
	public init(name: String,
							pluralisedName: String,
							symbol: String,
							instance: PointInstance.Type,
							unit: PointUnit.Type) {
		
		self.name = name
		self.pluralisedName = pluralisedName
		self.symbol = symbol
		self.instance = instance
		self.unit = unit
	}
	
	/**
	Equatable comparison.
	*/
	static public func ==(lhs: PointType, rhs: PointType)-> Bool {
		if lhs.name != rhs.name { return false }
		if lhs.pluralisedName != rhs.pluralisedName { return false }
		if lhs.symbol != rhs.symbol { return false }
		if lhs.instance != rhs.instance { return false }
		if lhs.unit != rhs.unit { return false }
		
		return true
	}
	
}

