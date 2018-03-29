

import Foundation
import Pelican

/**
Defines a container that can hold a type of event and information about it, to be initialised and used at a later date.

Useful for parametrically building sets of events in an efficient way.
*/
public class EventContainer<HandleType: Handle> {
	
	/// The event to be created.
	public private(set) var eventType: Event<HandleType>.Type
	
	/// The name of the event.
	public private(set) var name: String
	
	/// The type of event.  Event types should be defined statically to ensure uniform standards.
	public private(set) var type: EventType
	
	/// The live event instance.  If nil, the event either hasn't started, or it has finished.
	public private(set) var event: Event<HandleType>?
	
	/// The function to be called next when the event is finished.  If nil, the event either hasn't started, or it has finished.
	public var next: ( () -> () )?
	
	/// The flairs influencing an event.  When
	public lazy var flair = FlairManager()
	
	
	/**
	Initialises itself with an event and tag, to temporarily initialise the event and extract name and type information.
	*/
	public init(event: Event<HandleType>.Type) {
		
		/// Initialise the event temporarily to extract the juicy bits.
		self.eventType = event
		let event = event.init(next: {})
		
		self.name = event.name
		self.type = event.type
	}
	
	/**
	Initialises the event and starts it.
	*/
	public func start(handle: HandleType, next: @escaping () -> ()) {
		
		self.event = self.eventType.init(next: self.finish)
		self.next = next
		self.event!.flair = flair
		
		event!.start(handle: handle)
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
