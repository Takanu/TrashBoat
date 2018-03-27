

import Foundation
import Pelican


/**
Defines a type of Point that can be created and monitored by a PointManager
or initialised by using the `type` property.
*/
struct PointType: Hashable, Equatable {
	
	/// The name of the currency.
	public private(set) var name: String
	
	/// The symbol used as a shorthand to the name of the currency.
	public private(set) var symbol: String
	
	/// The point type that this tag is associated and will create when a tag is given to a PointManager.
	public private(set) var type: PointInstance.Type
	
	var hashValue: Int {
		return name.hashValue ^ symbol.hashValue
	}
	
	
	/**
	Initialises a new wallet type, which holds and manages a specific type of currency.
	*/
	init(name: String, symbol: String, type: PointInstance.Type) {
		self.name = name
		self.symbol = symbol
		self.type = type
	}
	
	/**
	Checks to see if the given currency has the same aesthetical details as this currency.  Any contents or numerical settings are not considered.
	*/
	static func ==(lhs: PointType, rhs: PointType)-> Bool {
		if lhs.name != rhs.name { return false }
		if lhs.symbol != rhs.symbol { return false }
		
		return true
	}
	
}

