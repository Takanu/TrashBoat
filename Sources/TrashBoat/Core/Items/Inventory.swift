

import Foundation
import Pelican

/**
Defines a simple and lightweight system for organising and managing items belonging to any type.
Combine `Inventory` with `ItemRoute` and the `inlineItems` UserProxy route handler for a streamlined
way to both let players view items through inline queries, and request them from the game once sent
as messages.

---

Items added are organised into arrays of `InventoryStack` types where one Item Type will have it's own
array of stacks.  An `InventoryStack` is an internal system that keeps track of item counts and will
add items to the top of the stack and remove items from the bottom of the stack (AKA - a First In First Out queue).

Stacks can also be declared as unlimited using the `isUnlimited` boolean and using `add` and `modifyStack` method
properties, that will prevent item removal and instead clone an item from the stack every time one is requested from it.
*/
public class Inventory {
	
	// CONTENTS
	/// Defines a structured set of items the player has, organised into stacks.
	public private(set) var items: [ItemTypeTag: [InventoryStack] ] = [:]
	
	// RECORD
	// I currently have no design or purpose for this, it doesn't immediately have a use or design like Point does.
	/// Defines an array of transactions that have occurred with items held in the inventory.
	//public private(set) var transactions: [String] = []
	
	// FLAIR DEFINITIONS
	/// Defines the flair category used to collect items that players are currently able to use.  Should be used in conjunction with UserProxy and ItemRoute.
	static var fetchStatusCategory = "Item Usage"
	
	// MODIFIERS
	/** Allows you to change how inline card information is generated by the Inventory by defining
	where the item name and quantity are positioned and what text they are positioned with.

	Use `$name` and `$count` to define the place where the item name and quantity should be positioned. */
	public var inlineCardTitle: String = ""

	
	public init() { }
	
	
	/**
	Adds an item type to the inventory system, before any items from that type are added.
	This enables an inventory to provide better feedback in inline menus if the player has no items of that type.
	*/
	public func addType(_ type: ItemTypeTag) {
		
		/// Check that the item has a type category
		if items.keys.contains(type) == false {
			items[type] = []
		}
	}
	
	/**
	Adds one or more items to the inventory system.  Type keys and `InventoryStack` types will automatically be
	generated for items that require it.
	
	- parameter makeUnlimitedStacks: If true, the stacks of any items you add will become an "unlimited stack".
	This prevents the stack from removing the finite items it stores and instead will clone an item from it
	every time one is requested (typically from the front of the stack).
	
	- parameter incomingItems: The items you wish to add to this inventory.  If any items already have a stack
	associated with them in the inventory they will be added to it.
	*/
	public func add(makeUnlimitedStacks: Bool = false, _ sequence: ItemRepresentible...) {
		addItems(array: sequence, makeUnlimitedStacks: makeUnlimitedStacks)
	}
	
  
	/**
	Adds one or more items to the inventory system.  Type keys and `InventoryStack` types will automatically be
	generated for items that require it.
	
	- parameter makeUnlimitedStacks: If true, the stacks of any items you add will become an "unlimited stack".
	This prevents the stack from removing the finite items it stores and instead will clone an item from it
	every time one is requested (typically from the front of the stack).
	
	- parameter incomingItems: The items you wish to add to this inventory.  If any items already have a stack
	associated with them in the inventory they will be added to it.
	*/
  public func add(makeUnlimitedStacks: Bool = false, _ array: [ItemRepresentible]) {
    addItems(array: array, makeUnlimitedStacks: makeUnlimitedStacks)
  }
  
  
  private func addItems(array: [ItemRepresentible], makeUnlimitedStacks: Bool) {
    
    for item in array {
      
      /// Check that the item has a type category
      if items.keys.contains(item.itemType) == false {
        items[item.itemType] = []
      }
      
      /// Search through the stacks for one that matches the name
      var stacks = items[item.itemType]!
      var itemAdded = false
      for stack in stacks {
        
        if stack.itemName == item.name {
          stack.add(item)
          
          if makeUnlimitedStacks == true {
            stack.isUnlimited = true
          }
          
          items[item.itemType] = stacks
          itemAdded = true
          break
        }
      }
      
      // If we're here, we need to make a new stack
      if itemAdded == false {
        let newStack = InventoryStack(item: item)
        
        if makeUnlimitedStacks == true {
          newStack.isUnlimited = true
        }
        
        stacks.append(newStack)
        items[item.itemType] = stacks
      }
    }
  }
	
	
	/**
	Changes the behaviour of a stack of any given item, if it already exists as a stack.
	
	- parameter ofItem: The item whose stack you wish to edit.  It is not guaranteed that a
	stack exists for the item.
	- parameter makeStackUnlimited: If true, the stack will no longer show a quantity when retrieving
	items from it, and will always copy an item from the front of the stack when it is asked to return an item.
	*/
	public func editStack(ofItem item: ItemRepresentible, makeStackUnlimited: Bool) {
		/// Check that the item has a type category
		if items.keys.contains(item.itemType) == false {
			items[item.itemType] = []
		}
		
		/// Search through the stacks for one that matches the name
		let stacks = items[item.itemType]!
		for stack in stacks {
			
			if stack.itemName == item.name {
				stack.isUnlimited = makeStackUnlimited
			}
		}
	}
	
	
	/**
	Check to see if this item is in the inventory system.
	
	- returns: True if the inventory has the item, false if not.
	*/
	public func hasItem(_ item: ItemRepresentible) -> Bool {
		
		/// Check that the type category is stored, and if not return false early.
		if items.keys.contains(item.itemType) == false {
			return false
		}
		
		/// Search through the stacks for one that matches the name.  If found, return true.
		for stack in items[item.itemType]! {
			if stack.itemName == item.name {
				return true
			}
		}
		
		return false
	}
	
	/**
	Returns every item type the inventory is currently storing at least one item from.
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
	Returns one of every item the inventory is currently storing of a given type as an info tag.
	
	- note: This retrieval does not remove the item from the inventory, only item information
	is extracted.
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
	Copies and returns one of every item the inventory is currently storing of the provided type, from the
	**front of each stack.**  This will not reduce the stack count of the items requested.
	
	- note: In order to avoid item count issues, try to avoid copying items - use item info tags instead.
	*/
	public func getItemCopies(forType type: StringRepresentible) -> [ItemRepresentible]? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(where: {$0.name == type.string()}) == false { return nil }
		
		/// Search through the stacks for one that matches the name.  If found, extract an item from it.
		let inventorySet = items.first(where: {$0.key.name == type.string()})!
		let stacks = inventorySet.value
		var result: [ItemRepresentible] = []
		
		for stack in stacks {
			if stack.count != 0 {
				result.append(stack.cloneFirst())
			}
		}
		
		return result
	}
	
	
	/**
	Returns and removes an item from the inventory if found.
	
	If removing the item would reduce the stack count to zero, the stack is removed from the inventory.
	*/
  @discardableResult
	public func removeItem(name: StringRepresentible, type: StringRepresentible) -> ItemRepresentible? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(where: {$0.name == type.string()}) == false { return nil }
		
		/// Search through the stacks for one that matches the name.  If found, extract an item from it.
		let inventorySet = items.first(where: {$0.key.name == type.string()})!
		var stacks = inventorySet.value
		for (i, stack) in stacks.enumerated() {
			if stack.itemName == name.string() {
				
				let retrievedItem = stack.removeFirstItem()
				
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
	Returns and removes an item from the inventory if found, using another instance of the item.
	*/
  @discardableResult
	public func removeItem(_ item: ItemRepresentible) -> ItemRepresentible? {
		return removeItem(name: item.name, type: item.itemType.name)
	}
	
	/**
	Returns and removes an item from the inventory if found, using an ItemInfoTag.
	*/
  @discardableResult
	public func removeItem(withInfo info: ItemInfoTag) -> ItemRepresentible? {
		return removeItem(name: info.name, type: info.type.name)
	}
	
	/**
	Returns and removes an item from the inventory if found, at a random position in the stack.
	
	This differs from `removeItem` as those related functions only remove items from the front of the stack.
	*/
  @discardableResult
	public func removeRandomItem(name: StringRepresentible, type: StringRepresentible) -> ItemRepresentible? {
		
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
	Returns and removes an item from the inventory if found, at a random position in the item stack.
	*/
  @discardableResult
	public func removeRandomItem(_ item: ItemRepresentible) -> ItemRepresentible? {
		return removeRandomItem(name: item.name, type: item.itemType.name)
	}
	
	/**
	Returns and removes an item from the inventory if found, at a random position in the item stack.
	*/
  @discardableResult
	public func removeRandomItem(withInfo info: ItemInfoTag) -> ItemRepresentible? {
		return removeRandomItem(name: info.name, type: info.type.name)
	}
	
	/**
	Randomly returns and retrieves any item that can be found which matches the given type.
	*/
  @discardableResult
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
	- parameter includeUnlimitedStacks: If true, any item with an unlimited stack will be removed.  Otherwise, it will remain in the inventory.
	- returns: An array of all the items of this type if the player has at least one item belonging to it.
	*/
  @discardableResult
	public func removeAllItems(forType type: ItemTypeTag, includeUnlimitedStacks: Bool) -> [ItemRepresentible]? {
		
		/// Check that the type category is stored, and if not return nil.
		if items.keys.contains(type) == false { return nil }
		
		/// Search through the stacks for an item we can fetch
		var results: [ItemRepresentible] = []
		var inventorySet = items[type]!
		
		for stack in inventorySet {
			
			// If the stack is unlimited but we can't remove unlimited stacks, continue
			if stack.isUnlimited == true && includeUnlimitedStacks == false {
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
	Clears all items stored in an inventory.  Weeewwwww.
	*/
	public func clear() {
		
		items.removeAll()
		//transactions.removeAll()
	}
}
