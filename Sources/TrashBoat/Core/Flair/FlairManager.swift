

import Foundation
import Pelican

/**
A controller of flair types (`*w*`) that can be used to help define the game state on a global
or type level in a procedural manner.
*/
public class FlairManager {
	
	/// The current collection of states this system is holding.
	public private(set) var flairs: [String: [FlairStack] ] = [:]
	
	
	public init() { }
	
	
	/**
	Returns all the names of the states that appear under a given category, if that category exists.
	*/
	public subscript(category: StringRepresentible) -> [String]? {
		
		get {
			
			let categoryName = category.string()
			
			if flairs.keys.contains(categoryName) {
				let stack = flairs[categoryName]!
				var result: [String] = []
				
				for flair in stack {
					result.append(flair.name)
				}
				
				return result
			}
			
			return nil
		}
	}
	
	/**
	Adds a new `Flair` item to the system.  Note that if the state you're adding already matches the category and name of one in the system,
	the one in the system will have their stack number increase without the newly added state being added.
	*/
	public func addFlair(withName name: StringRepresentible, category: StringRepresentible) {
		
		let newFlag = Flair(withName: name.string(), category: category)
		addToList(newFlag)
	}
	
	/**
	Adds a new state to the system using flags that have already been built.  Note that if the state you're adding already matches the category and name of one in the system,
	the one in the system will have their stack number increase without the newly added state being added.
	*/
	public func addFlair(_ flairs: Flair...) {
		
		for flair in flairs {
			addToList(flair)
		}
	}
	
	/**
	Always use this function if you want to add a new state to the dictionary.
	*/
	private func addToList(_ incomingFlair: Flair) {
		
		//print("Adding Flair: \(incomingFlair.name)\n\(getFlairMap())")
		
		// Try and find the category, if not create one
		if flairs.keys.contains(incomingFlair.category) == false {
			
			flairs[incomingFlair.category] = []
		}
		
		// Now try and find if a stack exists for the Flair.
		if let stack = flairs[incomingFlair.category]!.first(where: {$0.name == incomingFlair.name}) {
			stack.addState(incomingFlair)
		}
		
		// If not, create one and return.
		else {
			let stack = FlairStack(firstState: incomingFlair)
			flairs[incomingFlair.category]!.append(stack)
			return
		}
	}
	
	/**
	Tries to find if this system has the specified flair.  The flair given does not have to match exactly if compareContents is false.
	- returns: True if it does, false if not.
	*/
	public func findFlair(_ incomingFlair: Flair, compareContents: Bool) -> Bool {
		
		if let category = flairs[incomingFlair.category] {
			for stack in category {
				
				if compareContents == true {
					if stack.compareFlair(incomingFlair) == true { return true }
				}
				
				else {
					if stack.name == incomingFlair.name { return true }
				}
			}
		}
		return false
	}
	
	/**
	Tries to find a flair that matches the given name and category only.
	- returns: True if the flair exists, false if not.
	*/
	public func findFlair(withName name: StringRepresentible, category: StringRepresentible) -> Bool {
		let unwrappedName = name.string()
		//let unwrappedCategory = category.string()
		
		if let category = flairs[unwrappedName] {
			for stack in category {
				if stack.name == unwrappedName { return true }
			}
		}
		
		return false
	}

	
	/**
	Attempts to remove a flag from the state system using a given name and category.
	- parameter removeAll: If true, the stack that the Flair corresponds to will be removed if found.
	*/
	public func removeFlair(withName name: StringRepresentible, category: StringRepresentible, removeAll: Bool = false) {
		
		let flair = Flair(withName: name, category: category)
		removeFromList(flair, removeAll: removeAll)
	}
	
	/**
	Attempts to remove a flag from the state system using a prepared StateFlag instance.
	- parameter ignoreStack: If true, the stack number will not be considered, and the flag will be removed if found.
	*/
	public func removeFlair(_ flair: Flair, removeAll: Bool = false) {
		removeFromList(flair, removeAll: removeAll)
	}
	
	/**
	Always use this function if you want to remove a new state to the dictionary.
	*/
	private func removeFromList(_ incomingFlair: Flair, removeAll: Bool) {
		
		//print("Removing Flair: \(incomingFlair.name)\n\(getFlairMap())")
		
		// Attempt to find the category array
		if flairs.keys.contains(incomingFlair.category) {
			var array = flairs[incomingFlair.category]!
			
			// Attempt to find the associated FlairStack
			if let stack = array.first(where: {$0.name == incomingFlair.name}) {
				
				// Check the flairs match before continuing
				if stack.compareFlair(incomingFlair) == false { return }
				
				// Remove one to begin with
				stack.removeFirst()
					
				// If removeAll is true or the stack no longer has any Flairs, remove it
				if stack.count == 0 || removeAll == true {
					let index = array.index(where: {stack == $0})!
					array.remove(at: index)
				}
			}
			
			// Merge any changes back
			flairs[incomingFlair.category] = array
		}
	}
	
	/**
	Passes the given flags to any Flair currently added to the system.  They are matched with any potential Flair flags
	and if a match occurs, the Flair's next() event will be executed.
	*/
	public func trigger(handle: Handle, flags: [StringRepresentible]) {
		
		//print("Attempting Trigger: \(flags)\n\(getFlairMap())")
		
		for flairCategory in flairs {
			
			for stack in flairCategory.value {
				stack.trigger(handle: handle, flags: flags)
			}
		}
		
		// Look through the flairs to see how the change has affected the stacks (DO NOT DO IT BEFORE IN CASE A FLAIR TRIGGER MODIFIES THE CONTENTS OF THE FLAIR BEING OPERATED ON)
		for flairCategory in flairs {
			let currentKey = flairCategory.key
			var currentArray = flairCategory.value
			
			for stack in currentArray {
				if stack.count == 0 {
					let index = currentArray.index(of: stack)!
					currentArray.remove(at: index)
				}
			}
			
			// Set the new array
			flairs[currentKey] = currentArray
		}
		
		//print("Trigger Finished\n\(getFlairMap())")
	}
	
	/**
	Returns a string that describes the current state of the FlairSystem, for debugging purposes
	*/
	public func getFlairMap() -> String {
		
		var result = "-----\n"
		
		for category in flairs {
			result += "\(category.key): "
			
			for item in category.value {
				result += "\(item.name), "
			}
			result += "\n"
		}
		
		result += "\n-----"
		return result
	}
	
	/**
	Clears all the flair from the system.  Put on a tie dammit.
	*/
	public func clear() {
		flairs.removeAll()
	}
}
