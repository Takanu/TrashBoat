

import Foundation

/**
Represents a type of `Event`.  Useful for standarising presentation, procedural sorting
and event design and planning when handling large numbers of events that can be categorised
into different purposes.

Simpler games that have a linear series of events don't require this functionality and can
all be categorised as one type.

Once initialised, the contents are immutable.
*/
public struct EventType: Hashable, Equatable {
	
	public var hashValue: Int {
		return name.hashValue ^ symbol.hashValue ^ pluralisedName.hashValue ^ description.hashValue
	}
	
	/// The name of the type.
	public private(set) var name: String
	
	/// The symbol or short reference, used to represent the type in a condensed manner.
	public private(set) var symbol: String
	
	/// The pluralised name of the type.
	public private(set) var pluralisedName: String
	
	/// The description of the type itself.
	public private(set) var description: String
	
	/**
	Initialises the type tag with a set of required arguments used to identify and illustrate it in a game.
	*/
	public init(name: String,
			 symbol: String,
			 pluralisedName: String,
			 description: String) {
		
		self.name = name
		self.symbol = symbol
		self.pluralisedName = pluralisedName
		self.description = description
	}
	
}

extension EventType {
	
	static public func ==(lhs: EventType, rhs: EventType) -> Bool {
		if lhs.name != rhs.name { return false }
		if lhs.symbol != rhs.symbol { return false }
		if lhs.pluralisedName != rhs.pluralisedName { return false }
		if lhs.description != rhs.description { return false }
		
		return true
	}
	
}
