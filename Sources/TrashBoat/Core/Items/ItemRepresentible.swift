
import Foundation
import Pelican

/**
This type represents a single collectible item in your game.
Types that conform to this protocol can be both collected and distributed by an `Inventory` and an `InventoryStack`.
*/
public protocol ItemRepresentible {
	
	/// The name of the item, conforming to ItemRepresentable.  Must be unique between items of the same type.
	var name: String { get }
	
	/// The type of item this object represents, as defined by an ItemTypeTag.  Protocols that represent a type of object should define this tag immediately when inheriting from ItemRepresentible.
	var itemType: ItemTypeTag { get }
	
	/// A brief description of the item.  I mean if you want (but as it's a protocol you kind of have to).
	var description: String { get }
	
	/// Retrieves the full name of the item.  As the name will likely not include the type, this is useful for making a full declaration of what the item is.
	func getFullName() -> String
	
	/// Retrieves an inline card for the item, allowing an item to represent itself in an inline menu.
	func getInlineCard() -> InlineResultArticle
	
	/// Return a new instance that copies all the properties of the instance it's called on.  Used for infinite staaacckkkss when added to an `Inventory`.
	func clone() -> ItemRepresentible
	
}

extension ItemRepresentible {
	
	public var info: ItemInfoTag {
		return ItemInfoTag(withItem: self)
	}
	
	public func isEqualTo(_ item: ItemRepresentible) -> Bool {
		
		if name != item.name { return false }
		if itemType != item.itemType { return false }
    if description != item.description { return false }
    
		return true
	}
}
