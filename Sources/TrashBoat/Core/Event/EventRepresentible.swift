

import Foundation
import Pelican

/**
A protocol that should be used in conjunction with `Event` to force the explicit definition and implementation of core properties
and methods for a new event to function.

It's a humunculus of a Class and a Protocol, but it does make code design cleaner and more purposeful <3
*/
public protocol EventRepresentible {
	
	/// The name of the event.
	var eventName: String { get }
	
	/// A description of the event's function (Used when building inline cards).
	var eventInfo: String { get }
	
	/// The type of event.
	var eventType: EventType { get }
	
	
	/**
	Use this function to start the execution of your event.  Chain this into as many functions as you need, but make
	sure to call end() when done to return control back to the code that started the Event.
	*/
	func execute()
	
	/**
	Use this function to make your Event testable by assigning your event all the properties it
	expects to have when executed normally, then call `execute()`.
	*/
	func test(handle: Handle)
	
	
	
}
