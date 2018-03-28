

import Foundation

/**
A type that allows for the creation and management of PointContainer types, designed for tracking
things like player currency and health.

Enables other types like Reward to find a single abstracted point from which to modify point values in
an implicit manner.
*/
public class PointManager {
	
	/// Defines a list of point types the player has, including the amount they have and how they can behave.
	public private(set) var container: [PointInstance] = []
	
	/// Defines an array of transactions that have occurred with the inventory wallet.
	public private(set) var transactions: [PointReceipt] = []
	
	public init() {}
	
	/**
	Enables quick access to the amount of a given currency the player has.
	*/
	subscript(incomingType: PointType) -> PointValue? {
		get {
			for currency in container {
				if currency.type == incomingType {
					return currency.value
				}
			}
			
			return nil
		}
	}
	
	/**
	Adds a new currency to the wallet!  If a matching wallet already exists, it will not be added again.
	*/
	public func addCurrency(_ type: PointType, initialAmount: PointValue) {
		
		// Ensure this won't add a wallet of the same type
		for currency in container {
			if currency.type == type { return }
		}
		
		// If not, add it!
		let newWallet = type.instance.init(initialAmount: initialAmount)
		container.append(newWallet)
	}
	
	/**
	Modifies the specified currency by the given numerical change.  If the currency type has not been added, it must be added first.
	- returns: A receipt that can be used to inspect the changes, if a currency with the specified name was found.
	*/
	@discardableResult
	public func changeCurrency(_ type: PointType, change: PointValue) -> PointReceipt? {
		
		// Ensure this won't add a wallet of the same type
		for currency in container {
			if currency.type == type {
				return currency.changeAmount(change)
			}
		}
		
		return nil
	}
	
	/**
	Removes and clears all PointInstance and PointReceipt types the manager has currently collected.
	*/
	public func clearAll() {
		self.container.removeAll()
		self.transactions.removeAll()
	}
}
