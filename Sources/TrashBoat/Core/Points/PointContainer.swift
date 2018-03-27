//
//  InventoryWallet.swift
//  App
//
//  Created by Takanu Kyriako on 22/11/2017.
//

import Foundation
import Pelican

/**
Manages the amount of a specific currency an inventory has.
*/
class PointContainer: Equatable {
	
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
