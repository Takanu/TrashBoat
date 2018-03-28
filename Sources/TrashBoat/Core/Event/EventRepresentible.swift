

import Foundation
import Pelican

/**
A protocol used to force the explicit definition of core properties when a new event type is defined.  Makes code design cleaner <3
*/
protocol EventRepresentible {
	
	/// The name of the event.
	var eventName: String { get }
	
	/// The type of event.
	var eventType: EventType { get }
	
}
