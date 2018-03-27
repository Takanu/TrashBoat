//
//  Event.swift
//  spooky
//
//  Created by Takanu Kyriako on 25/01/2018.
//

import Foundation
import Pelican

/**
Encapsulates an event in a game, which should act as a reusable experience.  Also provides shortcuts for retrieving items and player requests in a safe way.

Should almost always be initialised as part of an `EventContainer`, and subclasses should always use the `EventRepresentible` protocol to define the event's name and type.
*/
class Event<T: Handle> {
	
	/// The name of the event
	public var getName: String { return name }
	var name: String = "Untitled"
	
	/// The type of event.
	public var getType: EventType { return type }
	var type: EventType = EventType(name: "UNDEFINED",
																					symbol: "💀",
																					pluralisedName: "UNDEFINED",
																					description: "DEFINE ME")
	
	/// The handle used to send requests to Telegram, and to modify key game state information.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	var handle: T!
	
	/// The request class, shared by `handle` to make requests.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	internal var request: SessionRequest!
	
	/// The queue system, shared by 'handle' to queue requests.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	var queue: ChatSessionQueue!
	
	/// The base route, shared by 'handle' to handle update filtering.  WARNING - DO NOT USE OUTSIDE THE SCOPE OF AN EVENT.
	var baseRoute: Route!
	
	/// The flairs influencing an event.  These should typically be set before the event begins by an EventContainer.
	lazy var flair = FlairManager<T>()
	
	
	
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
	
	required init(next: @escaping () -> ()) {
		
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
	func start(handle: T) {
		self.handle = handle
		self.request = handle.request
		self.queue = handle.queue
		self.baseRoute = handle.baseRoute
		
		handle.baseRoute[["event"]]?.clearAll()
		handle.queue.clear()
		
		execute()
	}
	
	/**
	The function which all sub-classes should overwrite to implement it's unique functionality.
	*/
	func execute() {
		
	}
	
	/**
	A required function to call in order to end the event and pass back control of the game to PartySession.
	*/
	func end(playerTrigger: UserProxy, participants: [UserProxy]?) {
		
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
