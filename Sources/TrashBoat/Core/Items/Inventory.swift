

import Foundation
import Pelican

/**
Defines a simple and lightweight system for organising and managing items belonging to a player.
*/
public class Inventory {
	
	// CONTENTS
	/// Defines a structured set of items the player has, organised into stacks.
	public private(set) var items: [ItemTypeTag: [InventoryStack] ] = [:]
	
	// RECORD
	/// Defines an array of transactions that have occurred with items held in the inventory.
	public private(set) var itemTransactions: [String] = []
	
	
	// FLAIR DEFINITIONS
	/// Defines the flair category that collects what items players are currently able to use.  Should be used in conjunction with UserProxy and ItemRoute.
	static var fetchStatusCategory = "Item Usage"
	
	
	public init() { }
	
	
	/**
	Adds an item type to the inventory system, before any items from that type are added.
	This enables an inventory to provide better feedback in inline menus if the player has no items of that type.
	*/
	public func addItemType(_ type: ItemTypeTag) {
		
		/// Check that the item has a type category
		if items.keys.contains(type) == false {
			items[type] = []
		}
	}
	
	/**
	Adds an item to the player's inventory.
	*/
	public func addItems(_ incomingItems: [ItemRepresentible]) {
		
		for item in incomingItems {
		
			/// Check that the item has a type category
			if items.keys.contains(item.type) == false {
				items[item.type] = []
			}
			
			/// Search through the stacks for one that matches the name
			var stacks = items[item.type]!
			var itemAdded = false
			for stack in stacks {
				
				if stack.itemName == item.name {
					stack.addItem(item)
					items[item.type] = stacks
					itemAdded = true
					break
				}
			}
			
			// If we're here, we need to make a new stack
			if itemAdded == false {
				stacks.append(InventoryStack(item: item))
				items[item.type] = stacks
			}
		}
	}
	
	/**
	Changes the behaviour of a stack of any given item, if it already exists as a stack.
	*/
	public func modifyStack(ofItem item: ItemRepresentible, useUnlimitedStack: Bool) {
		/// Check that the item has a type category
		if items.keys.contains(item.type) == false {
			items[item.type] = []
		}
		
		/// Search through the stacks for one that matches the name
		let stacks = items[item.type]!
		for stack in stacks {
			
			if stack.itemName == item.name {
				stack.isUnlimited = useUnlimitedStack
			}
		}
	}
	
	
	/**
	Checks to see if this item is in the player's inventory.
	- returns: True if the player has the item, false if not.
	*/
	public func hasItem(_ item: ItemRepresentible) -> Bool {
		
		/// Check that the type category is stored, and if not return false early.
		if items.keys.contains(item.type) == false {
			return false
		}
		
		/// Search through the stacks for one that matches the name.  If found, return true.
		for stack in items[item.type]! {
			if stack.itemName == item.name {
				return true
			}
		}
		
		return false
	}
	
	/**
	Returns every type where the inventory has at least one item belonging to it.
	*/
	public func getAllTypes() -> [ItemTypeTag] {
		
		return items.keys.filter( { _ in return true } )
	}
	
	/**
	Returns a copy of every item the inventory is currently storing of a given type.
	*/
	public func cloneItems(forType type: ItemTypeTag) -> [[ItemRepresentible]]? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(type) == false { return nil }
		
		/// Search through the stacks for one that matches the name.  If found, extract an item from it.
		let stacks = items[type]!
		var result: [[ItemRepresentible]] = []
		
		for stack in stacks {
			if stack.count != 0 {
				result.append(stack.cloneStack())
			}
		}
		
		return result
		
	}
	
	/**
	Returns one of every item the inventory is currently storing of a given type.
	- note: This retrieval does not remove the item from the inventory, all items retrieved are copied from their respective stacks.
	*/
	public func getItemInfo(forType type: StringRepresentible) -> [ItemInfoTag]? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(where: {$0.name == type.string()}) == false { return nil }
		
		/// Search through the stacks for one that matches the name.  If found, extract an item from it.
		let inventorySet = items.first(where: {$0.key.name == type.string()})!
		let stacks = inventorySet.value
		var result: [ItemInfoTag] = []
		
		for stack in stacks {
			if stack.count != 0 {
				result.append(stack.itemInfo)
			}
		}
		
		return result
	}
	
	/**
	Returns and removes an item from the player's inventory if they own it.
	*/
	public func removeItem(type: StringRepresentible, name: StringRepresentible) -> ItemRepresentible? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(where: {$0.name == type.string()}) == false { return nil }
		
		/// Search through the stacks for one that matches the name.  If found, extract an item from it.
		let inventorySet = items.first(where: {$0.key.name == type.string()})!
		var stacks = inventorySet.value
		for (i, stack) in stacks.enumerated() {
			if stack.itemName == name.string() {
				
				let retrievedItem = stack.removeItem()
				
				// If the stack count is down to 0 and the item is not unlimited, remove it.
				if stack.isEmpty == true {
					stacks.remove(at: i)
				}
				
				// Set the state and return
				items[inventorySet.key] = stacks
				return retrievedItem
			}
		}
		
		// If we're here, we failed - return nil!
		return nil
		
	}
	
	/**
	Returns and removes an item from the player's inventory if they own it.
	*/
	public func removeItem(_ item: ItemRepresentible) -> ItemRepresentible? {
		return removeItem(type: item.type.name, name: item.name)
	}
	
	/**
	Returns and removes an item from the player's inventory if they own it, at a random position in the stack.
	*/
	public func removeRandomItem(type: StringRepresentible, name: StringRepresentible) -> ItemRepresentible? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(where: {$0.name == type.string()}) == false { return nil }
		
		/// Search through the stacks for one that matches the name.  If found, extract an item from it..
		let inventorySet = items.first(where: {$0.key.name == type.string()})!
		var stacks = inventorySet.value
		for (i, stack) in stacks.enumerated() {
			if stack.itemName == name.string() {
				
				let retrievedItem = stack.removeRandomItem()
				
				// If the stack count is down to 0 and the item is not unlimited, remove it.
				if stack.isEmpty == true {
					stacks.remove(at: i)
				}
				
				// Set the state and return
				items[inventorySet.key] = stacks
				return retrievedItem
			}
		}
		
		// If we're here, we failed - return nil!
		return nil
		
	}
	
	/**
	Returns and removes an item from the player's inventory if they own it, at a random position in the stack.
	*/
	public func removeRandomItem(_ item: ItemRepresentible) -> ItemRepresentible? {
		return removeRandomItem(type: item.type.name, name: item.name)
	}
	
	/**
	Randomly returns and retrieves any item that can be found which matches the given type.
	*/
	public func removeRandomItem(ofType type: String, includeUnlimitedStack: Bool) -> ItemRepresentible? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(where: {$0.name == type}) == false { return nil }
		
		/// Search through the stacks for an item we can fetch
		let inventorySet = items.first(where: {$0.key.name == type})!
		var stacks = inventorySet.value
		
		if stacks.count == 0 { return nil }
		
		if stacks.first(where: {$0.count != 0}) == nil { return nil }
		if includeUnlimitedStack == false {
			if stacks.first(where: {$0.isUnlimited == false}) == nil { return nil }
		}
		
		/// If it passed verification, we can safely search through stacks in a random manner
		var retrievedItem: ItemRepresentible? = nil
		while retrievedItem == nil {
			
			let stack = stacks.getRandom
			if stack == nil { return nil }
			if stack!.count == 0 || stack!.isUnlimited { continue }
			
			else {
				retrievedItem = stack!.removeRandomItem()
				
				// If the stack count is down to 0 and the item is not unlimited, remove it.
				if stack!.isEmpty == true {
					let index = stacks.index(where: {$0.itemName == stack!.itemName})!
					stacks.remove(at: index)
				}
			}
		}
		
		// Set back the stacks and return with the retrieved item
		items[inventorySet.key] = stacks
		return retrievedItem
	}
	
	/**
	Removes all items of a given type from the inventory.
	- parameter forType: The type of items you want to retrieve from the inventory.
	- parameter includeUnlimitedStack: If true, any item with an unlimited stack will be removed.  Otherwise, it will remain in the inventory.
	- returns: An array of all the items of this type if the player has at least one item belonging to it.
	*/
	public func removeAllItems(forType type: ItemTypeTag, includeUnlimitedStack: Bool) -> [ItemRepresentible]? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(type) == false { return nil }
		
		/// Search through the stacks for an item we can fetch
		var results: [ItemRepresentible] = []
		var inventorySet = items[type]!
		
		for stack in inventorySet {
			
			// If the stack is unlimited but we can't remove unlimited stacks, continue
			if stack.isUnlimited == true && includeUnlimitedStack == false {
				continue
				
			} else {
				
				// Clone the stack and add all items to the results array
				let items = stack.cloneStack()
				items.forEach({ results.append($0) })
				
				// Remove the current stack from the array
				let index = inventorySet.index(of: stack)!
				inventorySet.remove(at: index)
			}
			
		}
		
		// Rewrite the inventory stack and return the results.
		items[type] = inventorySet
		return results
	}
	
	/**
	Clears an inventory including all wallet currencies and items.  Weeewwwww.
	*/
	public func clearAll() {
		
		items.removeAll()
		itemTransactions.removeAll()
	}
}
