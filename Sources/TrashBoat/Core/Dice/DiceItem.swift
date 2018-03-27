//
//  DiceItem.swift
//  App
//
//  Created by Takanu Kyriako on 12/09/2017.
//

import Foundation
import Pelican

/// Builds and contains a set of dice based on the type defined on initialisation.
class DiceItem: ItemRepresentible {
	
	/// The name of the dice item
	var name: String
	
	/// A description of what the dice is.
	var description: String
	
	/// A static type to conform to ItemRepresentible.
	var type = ItemTypeTag(name: "Dice",
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
	var cursed: Bool = false
	
	
	init(name: String, description: String, dice: [Dice]) {
		self.name = name
		self.description = description
		self.dice = dice
	}
	
	
	func clone() -> ItemRepresentible {
		let clone = DiceItem(name: self.name, description: self.description, dice: self.dice)
		clone.cursed = self.cursed
		return clone
	}
	
	
	/** Generates a random number as a dice result, based on the way the dice has been set up */
	func roll() -> Int {
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
	func reset() {
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
	Calculates a grammatically correct list of players and the results of their dice.
	*/
	public static func getResultsList(_ results: [(player: Player, dice: DiceItem?)]) -> String {
		
		var string = ""
		
		for (index, result) in results.enumerated() {
			if result.dice == nil {
				string += "\(result.player.name) rolled nothing."
			}
			
			else {
				string += "\(result.player.name)\(result.dice!.getResultText)"
			}
			
			if index != results.count - 1 {
				string += "\n"
			}
		}
		
		return string
	}
	
	/**
	ItemRepresentible conforming function
	*/
	func getFullName() -> String {
		return "\(name) Dice"
	}
	
	/**
	Returns an Inline Result version of the dice for display when a user is looking at the dice they own.
	*/
	func getInlineCard() -> InlineResultArticle {
		return InlineResultArticle(id: "0", title: getFullName(), description: description, contents: getFullName(), markup: nil)
	}
	
	/**
	Rolls an entire set of given dice, returning useful results <3
	*/
	static func rollItemSet(_ set: [(player: Player, item: ItemRepresentible?)]) -> [(player: Player, dice: DiceItem?)]? {
		
		// Check we've been given a set where the item type is actually a DiceItem.
		for entry in set {
			if entry.item is DiceItem || entry.item == nil { continue }
			else { return nil }
		}
		
		// Now build the real results.
		var results: [(player: Player, dice: DiceItem?)] = []
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
