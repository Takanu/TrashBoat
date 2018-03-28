

import Foundation
import Pelican


/**
Defines a type of Point that can be created and monitored by a PointManager
or initialised by using the `type` property.
*/
public struct PointType: Hashable, Equatable {
	
	/// The name of the currency.
	public private(set) var name: String
	
	/// The pluralised form of the currency name.
	public private(set) var pluralisedName: String
	
	/// The symbol used as a shorthand to the name of the currency.
	public private(set) var symbol: String
	
	/// The point type that this tag is associated and will create when a tag is given to a PointManager.
	public private(set) var instance: PointInstance.Type
	
	public var hashValue: Int {
		return name.hashValue ^ symbol.hashValue
	}
	
	
	/**
	Initialises a new wallet type, which holds and manages a specific type of currency.
	*/
	public init(name: String, pluralisedName: String, symbol: String, instance: PointInstance.Type) {
		self.name = name
		self.pluralisedName = pluralisedName
		self.symbol = symbol
		self.instance = instance
	}
	
	/**
	Checks to see if the given currency has the same aesthetical details as this currency.  Any contents or numerical settings are not considered.
	*/
	static public func ==(lhs: PointType, rhs: PointType)-> Bool {
		if lhs.name != rhs.name { return false }
		if lhs.symbol != rhs.symbol { return false }
		
		return true
	}
	
}

