

import Foundation


/**
A structure left behind when an event is either completed or aborted, to quickly list what happened within it.
*/
struct EventRecord {
	
	/// The name of the event.
	var eventName: String
	
	/// The type of the event.
	var eventType: EventType
	
	/// The player who triggered the event.
	var trigger: UserProxy?
	
	/// Any other players that participated in the event.
	var participants: [UserProxy]?
	
	/// Any transactions that occurred during the event.
	var transactions: [(UserProxy, PointReceipt)]
	
	/// Any additional states or changes the record should hold.
	var states: [String: Any]
	
	init(name: String,
			 type: EventType,
			 trigger: UserProxy?,
			 participants: [UserProxy]?,
			 transactions: [(UserProxy, PointReceipt)] = [],
			 states: [String: Any] = [:]) {
		
		self.eventName = name
		self.eventType = type
		
		self.trigger = trigger
		self.participants = participants
		self.transactions = transactions
		self.states = states
	}

}
