

import Foundation
import Pelican

/**
An instance of a PointType that defines the behaviour of a point including
how it is added or subtracted from, counted and displayed.

A PointInstance is ideal for tracking health, currency, turns and other scalar-type
properties.  Alternatively you can use PointManager to manage multiple types of Points
under one property in an implicit manner.
*/
public protocol PointInstance: CustomStringConvertible {
	
	/// The point total this instance has.
	var value: PointValue { get set }
	
	/// A definition of the kind of value this instance represents, including how to describe it.
	var type: PointType { get }
	
	/// A textual description of the instance's value.
	var description: String { get }
	
	/**
	A standard initialiser that's required for a PointInstance to be used with a PointManager.
	*/
	init(initialAmount: PointValue)
	
	/**
	Changes the amount of currency the player has in accordance with it's behaviours, returning a receipt
	if successful.
	
	- parameter change: The change in any numerical value.  NSNumber does the heavy-lifting of type conversion
	and assumes your point value could be based on an integer or floating point value.
	*/
	func changeAmount(_ change: PointValue) -> PointReceipt?
	
	/**
	Changes the amount of currency the player has in accordance with it's behaviours, returning a receipt
	if successful.
	
	- parameter units: The PointUnit types you wish to comprise the change of.
	*/
	func changeAmount(_ units: PointUnit...) -> PointReceipt?
}
