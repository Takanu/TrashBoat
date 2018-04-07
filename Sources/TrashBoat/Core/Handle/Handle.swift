

import Foundation
import Pelican

/**
A ChatSession proxy that allows access to events outside it's scope limited sets of information required to
interact with the chat such as a Session router, as well as key information from the scenario itself
like the active players and the current game state.

Some of these properties can be modified, and the game scenario is expected to resolve modifications
to the handle into the global game state once the event is over.

- note: Most other TrashBoat types expect a single Handle class type, ensure you only have one Handle that can specifically
handle your own needs for the entirety of your application.
*/
public protocol Handle: class {
	
	// API INTERFACE
	var tag: SessionTag { get set }
	var request: SessionRequest { get set }
	var queue: ChatSessionQueue { get set }
	var baseRoute: Route { get set }
	
	// GAME STATE
	var records: [EventRecord] { get set }
	
	// PANIC BUTTON
	//func abort
	
}

/**
Defines a type that can resolve the contents of a given handle.
*/
protocol HandleRepresentible {
	
	func getHandle() -> Handle
	
	func resolveHandle(_ handle: Handle)
}
