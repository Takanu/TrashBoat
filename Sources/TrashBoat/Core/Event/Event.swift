

import Foundation
import Pelican

/**
Encapsulates an event in a game, which should act as a reusable experience.  Also provides shortcuts for retrieving items and player requests in a safe way.

- warning: Subclasses should __always__ inherit the `EventRepresentible` protocol to define the event's core properties and methods,
and almost always be initialised as part of an `EventContainer` to contain event code and initialise the event only when needed.
*/
open class Event<HandleType: Handle> {
	
	/// The name of the event
	public private(set) var name: String = "Untitled"
	
	/// The type of event.
	public private(set) var type = EventType(name: "UNDEFINED",
																					 symbol: "💀",
																					 pluralisedName: "UNDEFINED",
																					 description: "DEFINE ME")

	
	/// The handle used to send requests to Telegram, and to modify key game state information.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	public var handle: HandleType!
	
	/// The request class, shared by `handle` to make requests.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	public var request: SessionRequest!
	
	/// The queue system, shared by 'handle' to queue requests.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	public var queue: ChatSessionQueue!
	
	/// The base route, shared by 'handle' to handle update filtering.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	public var baseRoute: Route!
	
	// The tag, shared by 'handle' to identify the chat when making requests.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	public var tag: SessionTag!
	
	/// The flairs influencing an event.  These should typically be set before the event begins by an EventContainer.
	public lazy var flair = FlairManager()
	
	
	
	/// What the event should call once it is finished.
	private var next: (() -> ())
	
	/// Returns an inline card that represents the event in a standardised format.  NOTE - Change the ID before use.
	public var inlineCard: InlineResultArticle {
		return InlineResultArticle(id: "0",
															 title: "\(type.symbol) - \(name)",
															 description: "",
															 contents: name,
															 markup: nil)
	}
	
	required public init(next: @escaping () -> ()) {
		
		self.next = next
		
		if self is EventRepresentible {
			let spaceRep = self as! EventRepresentible
			self.name = spaceRep.eventName
			self.type = spaceRep.eventType
		}
	}
	
	/**
	Starts the event by assigning it a game object and exiting closure.
	*/
	open func start(handle: HandleType) {
		self.handle = handle
		self.request = handle.request
		self.queue = handle.queue
		self.baseRoute = handle.baseRoute
		self.tag = handle.tag
		
		handle.baseRoute[["event"]]?.clearAll()
		handle.queue.clear()
		
		execute()
	}
	
	
	/**
	The function which all sub-classes should overwrite to perform the Event's objective or purpose.
	*/
	open func execute() {
		print("[#line:#function]\nYOU MUST INHERIT EVENTREPRESENTIBLE WHEN USING THE EVENT TYPE.  SEE, YOU MISSED THIS")
	}
	
	/**
	The function which all sub-classes should overwrite to make an Event testable.
	
	Use this function to make your Event testable by assigning your event all the properties it
	expects to have when executed normally, then call `execute()`
	*/
	open func test(handle: Handle) {
		print("[#line:#function]\nYOU MUST INHERIT EVENTREPRESENTIBLE WHEN USING THE EVENT TYPE.  SEE, YOU MISSED THIS")
	}
	
	/**
	A required function to call in order to end the event and pass back control of the game to PartySession.
	*/
	open func end(playerTrigger: UserProxy?, participants: [UserProxy]?) {
		
		// Reset the queue timers and ungrouped router for convenience
		handle.queue.clear()
		handle.baseRoute[["event"]]?.clearAll()
		
		// Assign a record to the handle.
		let record = EventRecord(name: name, type: type, trigger: playerTrigger, participants: participants)
		handle.records.append(record)
		
		// Clear references to the event for memory deallocation purposes.
		handle = nil
		request = nil
		queue = nil
		baseRoute = nil
		
		// Exit
		next()
	}
}

extension Event: CustomStringConvertible {
	
	public var description: String {
		return "\(name) - \(type.name) Event"
	}
	
}
