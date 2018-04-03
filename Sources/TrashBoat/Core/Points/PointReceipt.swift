

import Foundation
import Pelican

/**
Represents the result of a change in value of a player's currency.
*/
public struct PointReceipt {
	
	/// The name of the currency
	public private(set) var type: PointType
	
	/// The amount of currency the player had before the transaction.
	public private(set) var previousAmount: PointValue
	
	/// The amount of currency the player had after the transaction.
	public private(set) var currentAmount: PointValue
	
	/// The net change that occurred as a result of the transaction.
	public private(set) var difference: PointValue
	
	/// The PointUnit types that represent the change, if any were used in the transaction.
	public private(set) var units: [PointUnit]?
	
	/**
	Initialises a receipt for a currency transaction using a numerical change value.
	*/
	public init(type: PointType, amountBefore: PointValue, amountAfter: PointValue, change: PointValue) {
		self.type = type
		self.previousAmount = amountBefore
		self.currentAmount = amountAfter
		self.difference = change
	}
	
	/**
	Initialises a receipt for a currency transaction using a series of PointUnit types.
	*/
	public init(type: PointType, amountBefore: PointValue, amountAfter: PointValue, change: PointUnit...) {
		self.type = type
		self.previousAmount = amountBefore
		self.currentAmount = amountAfter
		self.units = change
		
		// Calculate the numerical difference based on the PointUnit types provided.
		var differenceCalc: PointValue
		
		switch amountBefore {
		case .double(_):
			var result: Double = 0
			
			for unit in change {
				result += unit.value.double
			}
			
			if amountBefore.double > amountBefore.double {
				result = result * -1
			}
			
			differenceCalc = .double(result)
			
		case .int(_):
			var result: Int = 0
			
			for unit in change {
				result += unit.value.int
			}
			
			if amountBefore.int > amountBefore.int {
				result = result * -1
			}
			
			differenceCalc = .int(result)
		}

		self.difference = differenceCalc
	}
}
