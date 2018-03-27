//
//  InventoryWallet.swift
//  App
//
//  Created by Takanu Kyriako on 22/11/2017.
//

import Foundation
import Pelican

/**
An instance of a PointType that defines the behaviour of a point including
how it is added or subtracted from, counted and displayed.

A PointInstance is ideal for tracking health, currency, turns and other scalar-type
properties.  Alternatively you can use PointManager to manage multiple types of Points
under one property.
*/
class PointInstance: Equatable {
	
	public private(set) var amount: Int = 0
	var type: PointType
	
	init(withType type: PointType, initialAmount: Int) {
		self.type = type
		self.amount = initialAmount
	}
	
	/**
	Changes the amount of currency the player has in accordance with it's behaviours, returning a receipt.
	*/
	func changeAmount(_ change: Int) -> PointReceipt {
		
		let lastAmount = amount
		amount = amount + change
		
		if type.allowNegativeValue == false {
			amount = max(amount, 0)
		}
		
		let change = amount - lastAmount
		
		return CurrencyReceipt(type: type, amountBefore: lastAmount, amountAfter: amount, change: change)
	}
	
	static func ==(lhs: PointContainer, rhs: PointContainer) -> Bool {
		if lhs.amount != rhs.amount { return false }
		if lhs.type != rhs.type { return false }
		
		return true
	}
}
