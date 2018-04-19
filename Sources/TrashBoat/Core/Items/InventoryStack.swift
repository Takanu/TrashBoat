

import Foundation
import Pelican

/**
Manages an array of items that share the same item type and name.
*/
public class InventoryStack: Equatable {
	
	// ITEM INFO
	/// The name of the item, as listed in the object.
	public private(set) var itemName: String
	
	/// The type of item in this stack, as listed in the object.
	public private(set) var itemType: ItemTypeTag
	
	/// The information of the item, as defined by it's ItemInfoTag.
	public private(set) var itemInfo: ItemInfoTag
	
	/// The description of the object listed
	public private(set) var itemDescription: String
	
	/// An inline card that represents the item being stored in the stack, generated from the function of the item itself.
	public private(set) var itemCard: InlineResultArticle
	
	
	// STACK PROPERTIES
	/// The stack of items that make up this InventoryStack.
	private var items: [ItemRepresentible] = []
	
	/// If true, this stack can provide an unlimited supply of the specified item as long as it has one instance of it.
	public var isUnlimited: Bool = false
	
	/// Returns the number of items in the stack.
	public var count: Int { return items.count }
	
	/// Returns whether or not the stack is empty, and therefore should be removed.
	public var isEmpty: Bool {
		if count == 0 { return true }
		return false
	}
	
	
	/**
	Creates a new InventoryStack based on the information of the item, and adds it to the stack.
	*/
	public init(item: ItemRepresentible) {
		self.itemName = item.name
		self.itemType = item.itemType
		self.itemInfo = item.info
		self.itemDescription = item.description
		self.itemCard = item.getInlineCard()
		items.append(item)
	}
	
	/**
	Adds an item to the stack.
	*/
	public func add(_ item: ItemRepresentible) {
		if item.name != itemName || item.itemType != itemType { return }
		
		items.append(item)
	}
	
	/**
	Returns a clone of every item being held in the stack.
	*/
	public func cloneStack() -> [ItemRepresentible] {
		return items.map({$0.clone()})
	}
	
	/**
	Returns a clone of the first item in the stack.
	*/
	public func cloneFirst() -> ItemRepresentible {
		return items.first!.clone()
	}
	
	/**
	Returns a clone of a random item in the stack.
	*/
	public func cloneRandom() -> ItemRepresentible {
		return items.getRandom!.clone()
	}
	
	/**
	Returns and removes the first item from the stack if it has any.  The item being requested must match the item held by the stack.
	*/
	public func removeFirstItem() -> ItemRepresentible? {
		//if item.name != name || item.itemType != type { return nil }
		
		if isUnlimited == true {
			if count > 0 {
				return items[0].clone()
				
			}
			else {
				return nil
			}
		}
		
		else {
			if count > 0 {
				return items.removeFirst()
				
				
			}
			else {
				return nil
			}
		}
	}
	
	/**
	Returns and removes a random item from the stack if any are available.  The item being requested must match the item held by the stack.
	*/
	public func removeRandomItem() -> ItemRepresentible? {
		//if item.name != name || item.itemType != type { return nil }
		
		if isUnlimited == true {
			if count > 0 {
				return cloneRandom()
				
			}
			else {
				return nil
			}
		}
			
		else {
			if count > 0 {
				return items.popRandom()
				
			}
			else {
				return nil
			}
		}
	}
	
	static public func ==(lhs: InventoryStack, rhs: InventoryStack) -> Bool {
		if lhs.itemName != rhs.itemName { return false }
		if lhs.itemType != rhs.itemType { return false }
		if lhs.itemInfo != rhs.itemInfo { return false }
		if lhs.itemDescription != rhs.itemDescription { return false }
		
		if lhs.items.count != rhs.items.count { return false }
		if lhs.isUnlimited != rhs.isUnlimited { return false }
		
		return true
	}
}
