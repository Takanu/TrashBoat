
import Foundation
import Pelican

/**
This type represents a single collectible item type in your game.
Types that conform to this protocol can be both collected and used by a UserProxy.
*/
public protocol ItemRepresentible {
	
	/// The name of the item, conforming to ItemRepresentable.  Must be unique between items of the same type.
	var name: String { get }
	
	/// The type of item this object represents, as defined by an ItemTypeTag.  Protocols that represent a type of object should define this tag immediately when inheriting from ItemRepresentible.
	var type: ItemTypeTag { get }
	
	/// A brief description of the item.  I mean if you want (but as it's a protocol you kind of have to).
	var description: String { get }
	
	/// This retrieves the full name of the item.  As the name will likely not include the type, this is useful for making a full declaration of what the item is.
	func getFullName() -> String
	
	/// This retrieves an inline card for the item, allowing an item to represent itself in an inline menu.
	func getInlineCard() -> InlineResultArticle
	
	/// This function must clone the item and return a new instance.  Used for infinite staaaacccckkkkss.
	func clone() -> ItemRepresentible
	
}

extension ItemRepresentible {
	
	public var info: ItemInfoTag {
		return ItemInfoTag(withItem: self)
	}
	
	public func isEqualTo(_ item: ItemRepresentible) -> Bool {
		
		if name != item.name { return false }
		if type != item.type { return false }
		
		return true
	}
}
