

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
	Enables quick access to the amount of a given currency the player has by using the PointType.
	*/
	public subscript(incomingType: PointType) -> PointUnit? {
		get {
			for instance in container {
				if instance.type == incomingType {
					return instance.getValue()
				}
			}
			
			return nil
		}
	}
	
	/**
	Enables quick access to the amount of a given currency the player has by using the PointType name.
	*/
	public subscript(typeName: String) -> PointUnit? {
		get {
			for instance in container {
				if instance.type.name == typeName {
					return instance.getValue()
				}
			}
			
			return nil
		}
	}
	
	/**
	Checks if the manager has a PointInstance that represents a specific PointType.
	- returns: True if yes, false if no.
	*/
	public func hasType(_ type: PointType) -> Bool {
		
		for instance in container {
			if instance.type == type {
				return true
			}
		}
		return false
	}
	
	/**
	Adds the amount provided to this manager with the specified PointType.
	A PointInstance will be created for any PointTypes that have yet to be stored in the wallet.
	*/
	public func add(type: PointType, amount: PointValue) {
		
		// Ensure this won't add a wallet of the same type
		for instance in container {
			if instance.type == type {
				instance.add(amount)
			}
		}
		
		// If not, add it!
		let newInstance = type.instance.init(startAmount: amount)
		container.append(newInstance)
	}
	
	/**
	Deducts the amount provided from a PointInstance this Manager is responsible for.
	A PointInstance will be created if one does not yet exist for the specified type.
	*/
	public func deduct(type: PointType, amount: PointValue) {
		
		// Flip the amount.
		var minusValue: PointValue
		
		switch amount {
			
		case .double(let double):
			minusValue = .double(double * -1)
			
		case .int(let int):
			minusValue = .int(int * -1)
		}
		
		// Ensure this won't add a wallet of the same type
		for instance in container {
			if instance.type == type {
				instance.add(minusValue)
			}
		}
		
		// If not, add it!
		let newInstance = type.instance.init(startAmount: minusValue)
		container.append(newInstance)
	}
	
	/**
	Removes and clears all PointInstance and PointReceipt types the manager has currently collected.
	*/
	public func clear() {
		self.container.removeAll()
		self.transactions.removeAll()
	}
}
