

import Foundation
import Pelican

/**
An instance of a PointType that defines the behaviour of a point including
how it is added or subtracted from, counted and displayed.

A PointInstance is ideal for tracking health, currency, turns and other scalar-type
properties.  Alternatively you can use PointManager to manage multiple types of Points
under one property.
*/
protocol PointInstance {
	
	/// The point total this instance has.
	var count: Int { get set }
	
	/// A textual representation of the points that this instance represents, including how to describe it.
	var type: PointType { get }
	
	/**
	A standard initialiser that's required for a PointInstance to be used with a PointManager.
	*/
	init(initialAmount: Int)
	
	/**
	Changes the amount of currency the player has in accordance with it's behaviours, returning a receipt.
	*/
	func changeAmount(_ change: PointAmount) -> PointReceipt

}
