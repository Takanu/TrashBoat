

import Foundation
import Pelican

/**
Lets a Flair type send information back to the stack after it has been triggered, to
tell the stack how it should be removed if applicable.
*/
public struct FlairResponse {
	
	// If the FlairStack receives this after a trigger and is true, the state just triggered will be removed.
	public var removeSelf: Bool = false
	
	// If the FlairStack receives this after a trigger and is true, all states in the stack will be removed.
	public var removeAll: Bool = false
	
	init() { }
	
	init(removeSelf: Bool) {
		self.removeSelf = removeSelf
	}
	
	init(removeAll: Bool) {
		self.removeAll = removeAll
	}
}
