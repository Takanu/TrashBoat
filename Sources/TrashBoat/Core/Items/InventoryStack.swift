

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
	
	/// The description of the object listed
	public private(set) var itemDescription: String
	
	/// Whether or not the item is stackable.  If false, only one item will be contained in an InventoryStack instance.
	public private(set) var itemIsStackable: Bool
	
	
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
		self.itemDescription = item.description
		self.itemIsStackable = item.isStackable
		items.append(item)
	}
	
	/**
	Adds an item to the stack if it:
	- Matches the item information exactly of the items held in this stack based on ItemRepresentible property conformance.
	- The item being added doesn't represent in instance that this stack already holds.
	
	- returns: True if the item was successfully added, false otherwise.
	*/
	public func add(_ incomingItem: ItemRepresentible) -> Bool {
		
		// Stackable doesn't refer to storage, but the way that items are presented to the player and accessed or removed.
		//if itemIsStackable == false { return false }
		
		if incomingItem.name != itemName ||
			incomingItem.itemType != itemType ||
			incomingItem.description != itemDescription ||
			incomingItem.isStackable != itemIsStackable {
			return false
		}
		
		for storedItem in items {
			if storedItem as AnyObject === incomingItem as AnyObject { return false }
		}
		
		items.append(incomingItem)
		return true
	}
	
	/**
	Compares an item to the item information stored by the stack to see if there's a match.
	*/
	public func compare(_ incomingItem: ItemRepresentible) -> Bool {
		if incomingItem.name != itemName ||
			incomingItem.itemType != itemType ||
			incomingItem.description != itemDescription ||
			incomingItem.isStackable != itemIsStackable {
			return false
		}
		
		return true
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
	Returns and removes the given item from the stack, if contained.
	
	- returns: The removed item if successful, or nil if not.
	*/
	public func remove(_ incomingItem: ItemRepresentible) -> ItemRepresentible? {
		
		for (i, stackItem) in items.enumerated() {
			if incomingItem === stackItem &&
				incomingItem.isEqualTo(stackItem) {
				
				items.remove(at: i)
				return stackItem
			}
		}
		
		return nil
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
	
	/**
	Returns all cards required for the stack to be fully represented.  If the stack isnt "stackable", a card will be returned for every item present, otherwise
	only one card will be returned.
	*/
	public func getInlineCards() -> [InlineResultArticle] {
		
		if itemIsStackable == true {
			return [items[0].getInlineCard()]
		} else {
			return items.map( { $0.getInlineCard() } )
		}
	}
	
	/**
	Returns all tags required for the stack to be fully represented.  If the stack isnt "stackable", an info tag will be returned for every item present, otherwise
	only one info tag will be returned.
	*/
	public func getItemInfo() -> [ItemInfoTag] {
		
		if itemIsStackable == true {
			return [items[0].info]
		} else {
			return items.map( { $0.info } )
		}
	}
	
	/**
	Returns the "stack information" for this stack.  If the items represented by this stack are not stackable, only one entry will be returned with the full
	stack count.  Otherwise each item will be returned with a stack count of 1.
	*/
	public func getStackInfo() -> [InventoryStackInfo] {
		if itemIsStackable == true {
			return [(items[0], self.count)]
		} else {
			return items.map( { ($0, 1) } )
		}
	}
	
	
	/**
	Returns any inline cards that associate the item to this
	*/
	
	static public func ==(lhs: InventoryStack, rhs: InventoryStack) -> Bool {
		if lhs.itemName != rhs.itemName { return false }
		if lhs.itemType != rhs.itemType { return false }
		if lhs.itemDescription != rhs.itemDescription { return false }
		
		if lhs.items.count != rhs.items.count { return false }
		if lhs.isUnlimited != rhs.isUnlimited { return false }
		
		return true
	}
}
