

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
	
	/// The point total this instance has.  This is a private value, use getValue() instead to retrieve the value of a PointInstance.
	var value: PointValue { get }
	
	/// A definition of the kind of value this instance represents, including how to describe it.
	var type: PointType { get }
	
	/// A textual description of the instance's value.
	var description: String { get }
	
	/// A list of transactions that have occurred inside the instance.  Make sure the first one is the initialised start amount!
	var transactions: [PointReceipt] { get set }
	
	
	/**
	A standard initialiser that's required for a PointInstance to be used with a PointManager.
	*/
	init(startAmount: PointValueConvertible)
	
	
	/**
	Returns the numerical value of this PointInstance as a PointUnit type.
	*/
	func getValue() -> PointUnit
	
	/**
	Adds the amount of currency the player has to the instance's value, in accordance with it's behaviours, returning a receipt
	if successful.
	
	- parameter change: The change in any numerical value.
	*/
	@discardableResult
	func add(_ change: PointValueConvertible) -> PointReceipt
	
	/**
	Adds the amount of currency the player has to the instance's value, in accordance with it's behaviours, returning a receipt
	if successful.
	
	- parameter units: The PointUnit types you wish to comprise the change of.
	*/
	@discardableResult
	func add(units: PointUnit...) -> PointReceipt
}
