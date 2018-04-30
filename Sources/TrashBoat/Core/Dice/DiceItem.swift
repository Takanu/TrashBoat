

import Foundation
import Pelican

/// Builds and contains a set of dice based on the type defined on initialisation.
public class DiceItem: ItemRepresentible {
	
	/// The name of the dice item
	public var name: String
	
	/// A description of what the dice is.
	public var description: String
	
	public var isStackable: Bool = true
	
	/// A static type to conform to ItemRepresentible.
	public var itemType = ItemTypeTag(name: "Dice",
												 symbol: "🎲",
												 pluralisedName: "Dice",
												 routeName: "Dice",
												 description: "Lets you move in an area and perform actions in events and battles.")
	
	/// The dice associated with the item, that will be rolled to get the final result.
	private var dice: [Dice] = []
	
	/// If true, this item has been rolled and a result has been made.
	private var hasResult: Bool = false
	
	/// The current result of the DiceItem.
	private var result: Int = 0
	
	/// Returns the result of the dice item.  Make sure to roll it before retrieving a result.
	var getResult: Int { return result }
	
	/// Returns the result of the roll in textual form.
	var getResultText: String {
		
		if cursed == true {
			return "'s dice was cursed!  (Rolled 0)"
		}
		
		else {
			return " rolled a \(result)!"
		}
	}
	
	/// Determines whether or not the dice is cursed, which causes it to break.
	public var cursed: Bool = false
	
	
	public init(name: String, description: String, dice: [Dice]) {
		self.name = name
		self.description = description
		self.dice = dice
	}
	
	
	public func clone() -> ItemRepresentible {
		let clone = DiceItem(name: self.name, description: self.description, dice: self.dice)
		clone.cursed = self.cursed
		return clone
	}
	
	
	/** Generates a random number as a dice result, based on the way the dice has been set up */
	public func roll() -> Int {
		var tempResult = 0
		var rolledDice: [Dice] = []
		
		if cursed == true {
			self.result = 0
			return self.result
		}
		
		for d in dice {
			var newD = d
			tempResult += newD.roll()
			rolledDice.append(newD)
		}
		
		self.dice = rolledDice
		self.result = tempResult
		self.hasResult = true
		
		return self.result
	}
	
	/** Resets the dice result, acting as if it has not been rolled. */
	public func reset() {
		var resetDice: [Dice] = []
		
		for d in dice {
			var newD = d
			newD.reset()
			resetDice.append(newD)
		}
		
		self.dice = resetDice
		self.hasResult = false
		self.result = 0
	}
	
	/**
	ItemRepresentible conforming function
	*/
	public func getFullName() -> String {
		return "\(name) Dice"
	}
	
	/**
	Returns an Inline Result version of the dice for display when a user is looking at the dice they own.
	*/
	public func getInlineCard() -> InlineResultArticle {
		return InlineResultArticle(id: "0", title: getFullName(), description: description, contents: getFullName(), markup: nil)
	}
	
	/**
	Rolls an entire set of given dice, returning useful results <3
	*/
	static public func rollItemSet(_ set: [(player: UserProxy, item: ItemRepresentible?)]) -> [(player: UserProxy, dice: DiceItem?)]? {
		
		// Check we've been given a set where the item type is actually a DiceItem.
		for entry in set {
			if entry.item is DiceItem || entry.item == nil { continue }
			else { return nil }
		}
		
		// Now build the real results.
		var results: [(player: UserProxy, dice: DiceItem?)] = []
		for entry in set {
			
			let player = entry.player
			let dice = entry.item as! DiceItem?
			
			if dice != nil {
				_ = dice!.roll()
			}
		
			results.append((player, dice))
		}
		
		return results
	}
}
