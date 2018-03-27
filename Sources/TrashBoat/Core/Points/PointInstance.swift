

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
	
	var amount: PointAmount { get set }
	
	var type: PointType { get }
	
	/**
	Changes the amount of currency the player has in accordance with it's behaviours, returning a receipt.
	*/
	func changeAmount(_ change: PointAmount) -> PointReceipt

}
