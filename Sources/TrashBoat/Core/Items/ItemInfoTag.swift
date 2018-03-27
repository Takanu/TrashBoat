
import Foundation
import Pelican

/**
Represents the basic information of an item.  Useful for events to understand what an item is or what items a player has in their inventory.
*/
struct ItemInfoTag: Equatable {
	
	/// The name of the item.
	var name: String
	
	/// The type or category of item it belongs to.
	var type: ItemTypeTag
	
	/// A description of the item.
	var description: String
	
	/// The full name of the item.  As the normal name will likely not include the type, this is useful for making a full declaration of what the item is.
	var fullName: String
	
	/// An inline card that represents the item.
	var inlineCard: InlineResultArticle
	
	/**
	Initialises the tag with a type that is `ItemRepresentible`, cloning the properties it requires.
	*/
	init(withItem item: ItemRepresentible) {
		self.name = item.name
		self.type = item.type
		self.description = item.description
		self.fullName = item.getFullName()
		self.inlineCard = item.getInlineCard()
	}
	
	static func ==(lhs: ItemInfoTag, rhs: ItemInfoTag) -> Bool {
		if lhs.name != rhs.name { return false }
		if lhs.type != rhs.type { return false }
		if lhs.description != rhs.description { return false }
		if lhs.fullName != rhs.fullName { return false }
		
		// Need to make types equatable before using this
		//if lhs.inlineCard != rhs.inlineCard { return false }
		
		return true
	}
}
