

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
	
	/// The function to be called next when the event is finished.  If nil, the event either hasn't started, or it has finished.
	public var next: ( () -> () )?
	
	/// The flairs influencing an event.  When an event is executed, the flairs set here will be passed onto the event.
	public lazy var flairs = FlairManager()
	
	/**
	Initialises itself with an event, to temporarily initialise the event and extract name and type information.
	*/
	public init(_ event: Event<HandleType>.Type) {
		
		/// Initialise the event temporarily to extract the juicy bits.
		self.eventType = event
		let event = event.init(next: {})
		
		self.name = event.name
		self.info = event.info
		self.type = event.type
	}
	
	/**
	Initialises the event and starts it.
	*/
	public func start(handle: HandleType, next: @escaping () -> ()) {
		
		self.event = self.eventType.init(next: self.finish)
		self.next = next
		self.event!.flairs = flairs
		
		event!.start(handle: handle)
	}
	
	/**
	Tests the event, which asks the event to setup it's own state requirements before calling 'execute()'.
	*/
	public func test(handle: HandleType, next: @escaping () -> ()) {
		
		self.event = self.eventType.init(next: self.finish)
		self.next = next
		self.event!.flairs = flairs
		
		event!.test(handle: handle)
	}
	
	/**
	Finishes the event, removing the reference and calling the next() function.
	*/
	public func finish() {
		
		if next == nil {
			print("HEY, THE EVENT CONTAINER FINISH WAS CALLED WHEN NO NEXT FUNCTION EXISTS.\n\n\(type.name) - \(name)")
			return
			
		} else {
			let nextCopy = next!
			self.event = nil
			self.next = nil
			
			nextCopy()
		}
	}
}
