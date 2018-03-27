//
//  PointManager.swift
//  SandBucket
//
//  Created by Ido Constantine on 26/03/2018.
//

import Foundation

/**
A type that allows for the creation and management of PointContainer types, designed for tracking
things like player currency and health.
*/
class PointManager {
	
	/// Defines a list of point types the player has, including the amount they have and how they can behave.
	public private(set) var container: [PointContainer] = []
	
	/// Defines an array of transactions that have occurred with the inventory wallet.
	public private(set) var transactions: [PointReceipt] = []
	
	/**
	Enables quick access to the amount of a given currency the player has.
	*/
	subscript(incomingType: PointType) -> Int? {
		get {
			for currency in container {
				if currency.type == incomingType {
					return currency.amount
				}
			}
			
			return nil
		}
	}
	
	/**
	Adds a new currency to the wallet!  If a matching wallet already exists, it will not be added again.
	*/
	func addCurrency(_ newCurrency: PointType, initialAmount: Int) {
		
		// Ensure this won't add a wallet of the same type
		for currency in container {
			if currency.type == newCurrency { return }
		}
		
		// If not, add it!
		let newWallet = PointContainer(withType: newCurrency, initialAmount: initialAmount)
		container.append(newWallet)
	}
	
	/**
	Modifies the specified currency by the given numerical change.  If the currency type has not been added, it must be added first.
	- returns: A receipt that can be used to inspect the changes, if a currency with the specified name was found.
	*/
	@discardableResult
	func changeCurrency(_ type: PointType, change: Int) -> PointReceipt? {
		
		// Ensure this won't add a wallet of the same type
		for currency in container {
			if currency.type == type {
				return currency.changeAmount(change)
			}
		}
		
		return nil
	}
}
