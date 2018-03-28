

import Foundation
import Pelican


/** 
Defines a flexible unit for deriving a random number, using a range, a 
pattern or for not defining a random number at all.
*/
public struct Dice {
	
	/// The way this dice handles rolling and the kind of rolling that can be performed by it.
	private var type: DiceType
	private var range: ClosedRange<Int> = 0...1
	private var selection: [Int] = []
	private var constant: Int = 0
	private var probability: [(value: Int, odds: Int)] = []
	
	/// If true, this dice has been rolled and a result has been made.
	private var hasResult: Bool = false
	/// The result of the roll.  Do not use this to confirm whether or not the dice has been rolled.
	private var result: Int = 0
	/// The way this dice handles rolling and the kind of rolling that can be performed by it.
	public var getType: DiceType { return type }
	
	/// The result of the roll.  Returns nil, if the dice has yet to be rolled.
	public var getResult: Int? {
		if hasResult == true {
			return result
		}
		
		else { return nil }
	}
	
	public init(withRange range: ClosedRange<Int>) {
		self.type = .range
		self.range = range
	}
	
	public init(withSelection selection: Int...) {
		self.type = .selection
		self.selection = selection
	}
	
	public init(withSelection selection: [Int]) {
		self.type = .selection
		self.selection = selection
	}
	
	public init(withConstant constant: Int) {
		self.type = .constant
		self.constant = constant
	}
	
	public init(withProbability probability: [(value: Int, odds: Int)]) {
		self.type = .probability
		self.probability = probability
	}
	
	
	/** Generates a random number as a dice result, based on the way the dice has been set up */
	public mutating func roll() -> Int {
		
		switch self.type {
			
		case .range:
			let diff = (range.upperBound - range.lowerBound)
			var xoro = Xoroshiro()
			
			let randomNumber = Int(xoro.random32(max: UInt32(diff)))
			let result = randomNumber + range.lowerBound
			self.result = result
			
		case .selection:
			let diff = selection.count - 1
			var xoro = Xoroshiro()
			
			let randomNumber = Int(xoro.random32(max: UInt32(diff)))
			self.result = selection[randomNumber]
			
		case .constant:
			self.result = constant
			
		case .probability:
			var odds: [Int] = []
			var total = 0
			
			for item in probability {
				total += item.odds
				odds.append(total)
			}
			
			// If it ended up equalling nothing, or if theres only one set of values given, just return it.
			if total == 0 || probability.count == 1 {
				return probability[0].value
			}
			
			// If nothing was added, return 0
			if probability.count == 0 {
				return 0
			}
			
			var xoro = Xoroshiro()
			var randomNumber = Int(xoro.random32(max: UInt32(total - 1)))
			randomNumber += 1
			
			for (i, item) in odds.enumerated() {
				
				if item == randomNumber {
					self.result = probability[i].value
					return probability[i].value
				}
				
				else if item > randomNumber {
					self.result = probability[i].value
					return probability[i].value
				}
			}
			
			self.result = probability[odds.count - 1].value
			return probability[odds.count - 1].value

		}
		
		self.hasResult = true
		return self.result
	}
	
	/** Resets the dice result, acting as if it has not been rolled. */
	public mutating func reset() {
		self.hasResult = false
		self.result = 0
	}
	
}



