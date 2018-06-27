

import Foundation
import Pelican

/**
Represents a self-organising stack of Flair types that share the same name and category.
*/
public class FlairStack: Equatable {
	
	/// REPLICATED VARIABLES
	/// The name of the states being grouped into the stack.
	var name: String
	
	/// The category the states being grouped into this stack belong to.
	var category: String
	
	/// If true, multiple instances of this state can be recorded and held by a system.
	var allowStacks: Bool = true
	
	/** If true, all state instances in the same stack will be called when trigger flags are sent.
	Requires `allowStacks` to be true.
	*/
	var triggerSimultaneously: Bool = false
	
	
	/// STACK
	/// The array of states the stack is keeping hold of.
	private var stack: [Flair] = []
	/// The number of states this stack currently has.
	var count: Int { return stack.count }
	
	
	/**
	Initialises the stack with the Flair that will form the stack.
	*/
	public init(firstState: Flair) {
		
		self.name = firstState.name
		self.category = firstState.category
		self.allowStacks = firstState.allowStacks
		self.triggerSimultaneously = firstState.triggerSimultaneously
		self.stack.append(firstState)
	}
	
	/**
	An initialiser used for copies.
	*/
	public init(name: String,
							category: String,
							allowStacks: Bool,
							triggerSimultaneously: Bool,
							stack: [Flair]) {
		
		self.name = name
		self.category = category
		self.allowStacks = allowStacks
		self.triggerSimultaneously = triggerSimultaneously
		self.stack = stack
		
	}
	
	/**
	Adds a flair to the stack, if it matches the one the stack represents (otherwise it will return without adding it).
	*/
	func addState(_ incomingState: Flair) {
		
		// Verify that the state should be added.
		if allowStacks == false { return }
		if incomingState.name != name { return }
		if incomingState.category != category { return }
		if incomingState.allowStacks != allowStacks { return }
		if incomingState.triggerSimultaneously != triggerSimultaneously { return }
		
		// If so, add it.
		stack.append(incomingState)
	}
	
	func removeFirst() {
		if stack.count != 0 {
			stack.removeFirst()
		}
	}
	
	/**
	Compares the incoming Flair object with the stack's current properties.
	*/
	func compareFlair(_ incomingFlair: Flair) -> Bool {
		if incomingFlair == stack[0] { return true }
		
		return false
	}
	
	/**
	Attempts to trigger any flags held by this state.
	*/
	func trigger(handle: Handle, flags: [StringRepresentible]) {
		
		if stack.count == 0 { return }
		
		// Call the trigger method for the first Flair only if they cannot be triggered simultaneously.
		if triggerSimultaneously == false {
			if let response = stack[0].trigger(withHandle: handle, flags: flags) {
				if response.removeAll == true {
					stack.removeAll()
				}
				
				else if response.removeSelf == true {
					stack.removeFirst()
				}
			}
			
			return
		}
		
		// Otherwise we need to step through every Flair in the stack
		else {
			var indexesToRemove: [Int] = []
			
			for (i, flair) in stack.enumerated() {
				if let response = flair.trigger(withHandle: handle, flags: flags) {
					if response.removeAll == true {
						stack.removeAll()
						return
					}
					
					// Create an inverted list of the indexes we need to remove afterwards to prevent access errors
					else if response.removeSelf == true {
						indexesToRemove.insert(i, at: 0)
					}
				}
			}
			
			// Remove them afterwards to prevent conflicts
			for i in indexesToRemove {
				stack.remove(at: i)
			}
		}
	}
	
	/**
	Duplicates the instance! \o/
	*/
	public func copy() -> FlairStack {
		
		let copy = FlairStack(name: self.name,
													category: self.category,
													allowStacks: self.allowStacks,
													triggerSimultaneously: self.triggerSimultaneously,
													stack: self.stack)
		
		return copy
		
	}
	
	static public func ==(lhs: FlairStack, rhs: FlairStack) -> Bool {
		
		if lhs.name != rhs.name { return false }
		if lhs.category != rhs.category { return false }
		if lhs.allowStacks != rhs.allowStacks { return false }
		if lhs.triggerSimultaneously != rhs.triggerSimultaneously { return false }
		
		return true
		
	}
}
