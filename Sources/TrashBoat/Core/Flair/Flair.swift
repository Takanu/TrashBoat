

import Foundation
import Pelican

/**
A (◕‿◕✿) single item that when added (⌐■_■) to a FlairSystem, helps define the state ԅ(≖‿≖ԅ)
of the game in a fluid (~‾▿‾)~ and procedural manner.
*/
public struct Flair: Hashable, Equatable, FlairRepresentible {
	
	/// Defines a closure used when a flair is successfully triggered by a flag.
	public typealias FlairOperation = ( (Flair, Handle) -> (FlairResponse) )
	
	/// The specific name of the state, which will be used when an event is trying to search for a specific flag.  Should be defined in normal case.
	public var name: String
	
	/// The category this flag belongs to, used in both direct searching and when the `StateSystem` class is organising the flags it has.  Should be defined in normal case.
	public var category: String
	
	/// A generic dictionary that Flairs can use to record any kind of variables or states they need to.
	public var payload: [String: Any] = [:]
	
	/// What flags this State is looking out for, in order to trigger it's `action` function.
	public var flags: [String] = []
	
	/// The function that's triggered
	public var action: FlairOperation?
	
	/// If true, multiple instances of this state can be recorded and held by a system.
	public var allowStacks: Bool = false
	
	/** If true, all state instances in the same stack will be called when trigger flags are sent.
	Requires `allowStacks` to be true.
	*/
	public var triggerSimultaneously: Bool = false
	
	
	public var hashValue: Int {
		return name.hashValue ^ category.hashValue ^ allowStacks.hashValue
	}
	
	
	/**
	Create a new, simple State with just a name and category.
	- parameter category: The name of the category to be added.  Should always be defined in normal case to match the behaviour of ItemTypeTag and it's requirements.
	- parameter name: The name of the flair to be added.  Should always be defined in normal case to match the behaviour of ItemTypeTag and it's requirements.
	*/
	public init(withName name: StringRepresentible, category: StringRepresentible) {
		
		self.name = name.string()
		self.category = category.string()
	}
	
	/**
	Create a new State with additional options for stacking options.
	*/
	public init(withName name: StringRepresentible,
							category: StringRepresentible,
							payload: [String: Any]?,
							allowStacks: Bool) {
		
		self.name = name.string()
		self.category = category.string()
		if payload != nil { self.payload = payload! }
		self.allowStacks = allowStacks
	}
	
	/**
	Create a complex State that can both be search for using specific search terms, and triggered indirectly using flags.
	
	- parameter category: The name of the category to be added.  Should always be defined in normal case to match the behaviour of ItemTypeTag and it's requirements.
	- parameter name: The name of the flair to be added.  Should always be defined in normal case to match the behaviour of ItemTypeTag and it's requirements.
	- parameter flags: Labels that the flair should hold onto when the FlairManager it's inside tries to find any flair to trigger.  If the flag a flair is holding matches any flag the trigger is looking for, the action() function of that flair will be triggered.
	- parameter action: The function to be used if this flair is successfully triggered.
	- parameter allowStacks: If true, when the flair is added to a FlairSystem for the first time, any duplicates that are also added will stack on top of each other.  Otherwise, they would be prevented from being added to the system.
	- parameter triggerSimultaneously: If `allowStacks` is true and there is more than one identical Flair in any given system, if one of the Flairs is triggered then all of them will be triggered simultaneously.  If false, only the first Flair in the stack will be triggered.
	- parameter payload: If you need
	*/
	public init(withName name: StringRepresentible,
							category: StringRepresentible,
							payload: [String: Any]?,
							flags: [StringRepresentible],
							action: @escaping FlairOperation,
							allowStacks: Bool,
							triggerSimultaneously: Bool) {
		
		self.name = name.string()
		self.category = category.string()
		if payload != nil { self.payload = payload! }
		self.flags = flags.map({ $0.string() })
		self.action = action
	}
	
	/**
	Attempt to trigger the state by passing it flags.
	- returns: True if a matching flag was found and the state had a action closure to trigger, false if not.
	*/
	public func trigger(withHandle handle: Handle, flags inputFlags: [StringRepresentible]) -> FlairResponse? {
		
		let sortedInputFlags = inputFlags.map({ $0.string() })
		
		for flag in sortedInputFlags {
			if self.flags.contains(flag) == true {
				
				if action != nil {
					let response = action!(self, handle)
					return response
				}
				
				return nil
			}
		}
		
		return nil
	}
	
	public func getFlair() -> Flair {
		return self
	}
	
	static public func ==(lhs: Flair, rhs: Flair) -> Bool {
		
		if lhs.name != rhs.name { return false }
		if lhs.category != rhs.category { return false }
		if lhs.flags.count != rhs.flags.count { return false }
		if lhs.allowStacks != rhs.allowStacks { return false }
		if lhs.triggerSimultaneously != rhs.triggerSimultaneously { return false }
		
		for (i, lhsFlag) in lhs.flags.enumerated() {
			let rhsFlag = rhs.flags[i]
			if lhsFlag != rhsFlag { return false }
		}
		
		return true
	}
}
