//
//  CurrencyReceipt.swift
//  App
//
//  Created by Takanu Kyriako on 17/11/2017.
//

import Foundation
import Pelican

/**
Represents the result of a change in value of a player's currency.
*/
class PointReceipt {
	
	/// The name of the currency
	public private(set) var type: PointType
	
	/// The amount of currency the player had before the transaction.
	public private(set) var previousAmount: Int
	
	/// The amount of currency the player had after the transaction.
	public private(set) var currentAmount: Int
	
	/// The net change that occurred as a result of the transaction.
	public private(set) var difference: Int
	
	/**
	Initialises a receipt for a currency transaction.
	*/
	init(type: PointType, amountBefore: Int, amountAfter: Int, change: Int) {
		self.type = type
		self.previousAmount = amountBefore
		self.currentAmount = amountAfter
		self.difference = change
	}
}
