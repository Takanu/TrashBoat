

import Foundation

/**
A type that allows for the creation and management of PointContainer types, designed for tracking
things like player currency and health.

Enables other types like Reward to find a single abstracted point from which to modify point values in
an implicit manner.
*/
public class PointManager: Equatable {
	
	/// Defines a list of point types the player has, including the amount they have and how they can behave.
	public private(set) var container: [PointInstance] = []
	
	/// Defines an array of transactions that have occurred with the inventory wallet.
	public private(set) var transactions: [PointType: [PointReceipt]] = [:]
	
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
	Checks if the manager has a PointInstance that is represented by a specific name.
	- returns: True if yes, false if no.
	*/
	public func hasType(_ typeName: String) -> Bool {
		
		for instance in container {
			if instance.type.name == typeName {
				return true
			}
		}
		return false
	}
	
	/**
	Adds the amount provided to this manager with the specified PointType.
	A PointInstance will be created for any PointTypes that have yet to be stored in this manager.
	*/
	@discardableResult
	public func add(type: PointType, amount: PointValueConvertible) -> PointReceipt {
		
		// Ensure this won't add a wallet of the same type
		for instance in container {
			if instance.type == type {
				
				let receipt = instance.add(amount)
				addReceipt(receipt)
				return receipt
			}
		}
		
		// If not, add it!
		let newInstance = type.instance.init(startAmount: amount)
		transactions[type] = newInstance.transactions
		let receipt = transactions[type]![0]
		container.append(newInstance)
		
		return receipt
	}
	
	/**
	Adds all provided PointUnits to the manager.
	A PointInstance will be created for any PointTypes that have yet to be stored in this manager.
	*/
	public func add(_ units: PointUnit...) {
		for unit in units {
			self.add(unit: unit)
		}
	}
	
	/**
	Adds all provided PointUnits to the manager.
	A PointInstance will be created for any PointTypes that have yet to be stored in this manager.
	*/
	public func add(_ units: [PointUnit]) {
		for unit in units {
			self.add(unit: unit)
		}
	}
	
	/**
	Adds all provided PointUnit type to the manager.
	A PointInstance will be created for any PointTypes that have yet to be stored in this manager.
	
	- returns: A PointReceipt if successful.
	*/
	@discardableResult
	public func add(unit: PointUnit) -> PointReceipt {
		let type = unit.pointType
		
		// Ensure this won't add a wallet of the same type
		for instance in container {
			if instance.type == type {
				
				let receipt = instance.add(units: unit)
				addReceipt(receipt)
				return receipt
			}
		}
		
		// If not, add it!
		let newInstance = type.instance.init(startAmount: unit.value)
		transactions[type] = newInstance.transactions
		let receipt = transactions[type]![0]
		container.append(newInstance)
		
		return receipt
	}
	
	/**
	Adds points to the manager using the given name and point value.
	- warning: As this doesn't require the actual type name, this can fail.
	- returns: A point receipt if successful, and nil otherwise.
	*/
	@discardableResult
	public func add(pointName: String, value: PointValue) -> PointReceipt? {
		
		// Ensure this won't add a wallet of the same type
		for instance in container {
			if instance.type.name == pointName {
				
				let receipt = instance.add(value)
				addReceipt(receipt)
				return receipt
			}
		}
		
		return nil
		
	}
	
	/**
	Deducts the amount provided from a PointInstance this Manager is responsible for.
	A PointInstance will be created if one does not yet exist for the specified type.
	*/
	@discardableResult
	public func deduct(type: PointType, amount: PointValueConvertible) -> PointReceipt {
		
		// Flip the amount.
		var minusValue: PointValue
		let pointAmount = amount.getPointValue()
		
		switch pointAmount {
			
		case .double(let double):
			minusValue = .double(double * -1)
			
		case .int(let int):
			minusValue = .int(int * -1)
		}
		
		return add(type: type, amount: minusValue)
	}
	
	/**
	Deducts all provided PointUnits from the manager.
	A PointInstance will be created for any PointTypes that have yet to be stored in this manager.
	*/
	public func deduct(_ units: PointUnit...) {
		for unit in units {
			
			// Flip the amount.
			var minusValue: PointValue
			var newUnit = unit
			
			switch unit.value {
				
			case .double(let double):
				minusValue = .double(double * -1)
				
			case .int(let int):
				minusValue = .int(int * -1)
			}
			
			newUnit.value = minusValue
			self.add(unit: newUnit)
			
		}
	}
	
	/**
	Deducts all provided PointUnits from the manager.
	A PointInstance will be created for any PointTypes that have yet to be stored in this manager.
	*/
	public func deduct(_ units: [PointUnit]) {
		for unit in units {
			
			// Flip the amount.
			var minusValue: PointValue
			var newUnit = unit
			
			switch unit.value {
				
			case .double(let double):
				minusValue = .double(double * -1)
				
			case .int(let int):
				minusValue = .int(int * -1)
			}
			
			newUnit.value = minusValue
			self.add(unit: newUnit)
			
		}
	}
	
	/**
	Used by add and deduct functions to add a receipt to the receipts dictionary.
	*/
	private func addReceipt(_ receipt: PointReceipt?) {
		
		if receipt == nil { return }
		
		else {
			if transactions[receipt!.type] == nil {
				transactions[receipt!.type] = [receipt!]
				
			} else {
				transactions[receipt!.type]!.append(receipt!)
			}
		}
	}
	
	/**
	Removes and clears all PointInstance and PointReceipt types the manager has currently collected.
	*/
	public func clear() {
		self.container.removeAll()
		self.transactions.removeAll()
	}
	
	/**
	Copies the instance in it's entirety, creating new instances for all containers.
	*/
	public func copy() -> PointManager {
		
		let newCopy = PointManager()
		for instance in self.container {
			newCopy.container += [instance.copy()]
		}
		
		return newCopy
	}
	
	static public func ==(lhs: PointManager, rhs: PointManager) -> Bool {
		
		if lhs.container.count != rhs.container.count { return false }
		
		for (i, pointInstance) in lhs.container.enumerated() {
			let otherPointInstance = rhs.container[i]
			if pointInstance.isEqualTo(other: otherPointInstance) == false { return false }
		}
		
		if lhs.transactions.count != rhs.transactions.count { return false }
		
		for (i, transactionSet) in lhs.transactions.values.enumerated() {
			let otherTransactionSet = rhs.transactions.values.map {$0}[i]
			if transactionSet.count != otherTransactionSet.count { return false }
			
			for (p, transaction) in transactionSet.enumerated() {
				let otherTransaction = otherTransactionSet[p]
				if transaction != otherTransaction { return false }
			}
		}
		
		return true
		
	}
}
