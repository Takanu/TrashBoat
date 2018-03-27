
import Foundation
import Pelican

/**
Represents a definition for an item type, that allows an Inventory to organise and define it in
clear terms, as well as allowing other types to identify and understand the type.  Protocols that represent a type
of object should define this tag immediately when inheriting from ItemRepresentible.

Types can only ever be set, their definition cannot change once created.
*/
class ItemTypeTag: Hashable, Equatable {
	
	var hashValue: Int {
		return name.hashValue ^ symbol.hashValue ^ pluralisedName.hashValue ^ routeName.hashValue ^ description.hashValue
	}
	
	/// The name of the type.
	public private(set) var name: String
	
	/// The symbol used to represent the type in a condensed manner.
	public private(set) var symbol: String
	
	/// The pluralised name of the type.
	public private(set) var pluralisedName: String
	
	/// The query that the bot or a user can use to obtain the type, when available as a route.
	public private(set) var routeName: String
	
	/// The description of the type itself.
	public private(set) var description: String
	
	
	/**
	Initialises the type tag with a set of required arguments used to identify and illustrate it in a game.
	*/
	init(name: String, symbol: String, pluralisedName: String, routeName: String, description: String) {
		self.name = name
		self.symbol = symbol
		self.pluralisedName = pluralisedName
		self.routeName = routeName
		self.description = description
	}

}

extension ItemTypeTag {
	
	static func ==(lhs: ItemTypeTag, rhs: ItemTypeTag) -> Bool {
		if lhs.name != rhs.name { return false }
		if lhs.symbol != rhs.symbol { return false }
		if lhs.pluralisedName != rhs.pluralisedName { return false }
		if lhs.routeName != rhs.routeName { return false }
		if lhs.description != rhs.description { return false }
		
		return true
	}
	
}
