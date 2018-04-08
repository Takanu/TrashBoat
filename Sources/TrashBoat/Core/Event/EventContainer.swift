

import Foundation
import Pelican

/**
Defines a container that can hold a type of event and information about it to be initialised and used at a later date.

Design your events using `Event` and `EventRepresentible`, then initialise and execute them with an `EventContainer`.

Useful for parametrically building sets of events in an efficient way.
*/
public class EventContainer<HandleType: Handle> {
	
	/// The name of the event.
	public private(set) var name: String
	
	//// A description of the event's function (Used when building inline cards).
	public private(set) var info: String
	
	/// The type of event.  Event types should be defined statically to ensure uniform standards.
	public private(set) var type: EventType
	
	/// The event to be created when started or tested.
	private var eventType: Event<HandleType>.Type
	
	/// The live event instance.  If nil, the event either hasn't started, or it has finished.
	private var event: Event<HandleType>?
	
	/// The function to be called exit when the event is finished.  If nil, the event either hasn't started, or it has finished.
	public var exit: EventExit?
	
	/// The flairs influencing an event.  When an event is executed, the flairs set here will be passed onto the event.
	public lazy var flairs = FlairManager()
	
	/**
	Initialises itself with an event, to temporarily initialise the event and extract name and type information.
	*/
	public init(_ event: Event<HandleType>.Type) {
		
		/// Initialise the event temporarily to extract the juicy bits.
		self.eventType = event
		let event = event.init(exit: {_ in})
		
		self.name = event.name
		self.info = event.info
		self.type = event.type
	}
	
	/**
	Initialises the event and starts it.
	
	- parameter handle: The handle that the event will use to read and edit game states and send Telegram requests.
	
	- parameter exit: The closure that should be executed when the event finishes.
	
	- note: The event may end early if it has a `verify()` override that fails to verify the Handle state,
	or if an error is encountered during the execution of the event.
	*/
	public func start(handle: HandleType, exit: @escaping EventExit) {
		
		self.event = self.eventType.init(exit: self.end)
		self.exit = exit
		self.event!.flairs = flairs
		
		if let error = event!.verify(handle: handle) {
			end(error: error)
			return
		}
		
		event!.start(handle: handle)
	}
	
	/**
	Tests the event, which asks the event to setup it's own state requirements before calling 'execute()'.
	
	- parameter handle: The handle that the event will use to read and edit game states and send Telegram requests.
	
	- parameter exit: The closure that should be executed when the event finishes.
	
	- note: The event may end early if it has a `verify()` override that fails to verify the Handle state,
	or if an error is encountered during the execution of the event.
	*/
	public func test(handle: HandleType, exit: @escaping EventExit) {
		
		self.event = self.eventType.init(exit: self.end)
		self.exit = exit
		self.event!.flairs = flairs
		
		if let error = event!.verify(handle: handle) {
			end(error: error)
			return
		}
		
		event!.test(handle: handle)
	}
	
	/**
	Finishes the event, removing the reference and calling the exit() function.
	*/
	private func end(error: Error?) {
		
		if exit == nil {
			print("HEY, THE EVENT CONTAINER FINISH WAS CALLED WHEN NO exit FUNCTION EXISTS.\n\n\(type.name) - \(name)")
			return
			
		} else {
			let exitCopy = exit!
			self.event = nil
			self.exit = nil
			
			exitCopy(error)
		}
	}
}
