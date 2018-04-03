

import Foundation
import Pelican

/**
Defines a structure for a single set of rewards that can be re-used to give any number of players items and/or points.
*/
public class Reward {
	
	/// The points that can be awarded to the player.  From the range a value will be randomly selected.
	public var points: [PointType: ClosedRange<Int>] = [:]
	
	/// The items that this reward can dispense to the player, organised in stacks by their full name
	public var items: [String: [ItemRepresentible]] = [:]
	
	/// Random rewards to be retrieved at the point a player is being given a reward.
	public var randomItems: [() -> (ItemRepresentible)] = []
	
	/// Returns whether or not the reward has absolutely nothing to give to someone if used.
	public var hasNoReward: Bool {
		if points.keys.count != 0 { return false }
		if items.values.count != 0 { return false }
		if randomItems.count != 0 { return false }
		
		return true
	}
	
	/// Returns the number of items this reward is currently holding, including any items that should be generated.
	public var itemCount: Int {
		var result = 0
		
		items.forEach({result += $0.value.count})
		result += randomItems.count
		
		return result
	}
	
	public init() { }
	
	/**
	Initialises the reward with a points type and a range that will be used to randomly select the reward amount.
	*/
	public init(withCurrency type: PointType, amount: ClosedRange<Int>) {
		points[type] = amount
	}
	
	/**
	Initialises the reward with a specific selection of items that will be rewarded.
	*/
	public init(withItems incomingItems: ItemRepresentible...) {
		items = self.addItems(incomingItems, set: items)
	}
	
	/**
	Initialises the reward with a function that will be called when a reward needs to be given, vending zero or more items.
	*/
	public init(withRandomItems itemGen: () -> (ItemRepresentible)...) {
		randomItems = itemGen
	}
	
	
	private func addItems(_ incomingItems: [ItemRepresentible], set: [String: [ItemRepresentible]]) -> [String: [ItemRepresentible]] {
		
		var updatedSet = set
		
		/// Check their item tag.
		for item in incomingItems {
			
			// If we have a match, add the item to the stack.
			if set.keys.contains(item.getFullName()) {
				
				var array = items[item.getFullName()]!
				array.append(item)
				updatedSet[item.getFullName()] = array
			}
				
			// If we couldnt find a key, make a new set
			else {
				updatedSet[item.getFullName()] = [item]
			}
		}
		
		return updatedSet
	}
	
	/**
	Gives the player rewards for the stake level provided.  If one for the specific stake level cannot be found, the next lowest reward
	set will be selected, if it exists.  If it doesn't, it will return the lowest stake tier available.
	- returns: The reward item used and a pre-built message that can be sent as a message.  If no rewards were available, "x got nothing!" will be the message returned.
	*/
	private func giveReward(player: UserProxy) -> String {
		
		var message = ""
		
		/// IF WE HAVE NOTHING, just send a basic message and leave early.
		// If the reward has nothing somehow, make it special
		if hasNoReward == true {
			message = "\(player.firstName) got nothing!"
			return message
		}
		
		var numberWords = [
			"a",
			"two",
			"three",
			"four",
			"five",
			"six",
			"seven",
			"eight",
			"nine"
		]
		
		/// GIVE PLAYER STUFF FIRST
		// Build a dice to get a fortune figure!
		var finalCurrency: [PointType: Int] = [:]
		
		for pointsEntry in points {
			var pointsDice = Dice(withRange: pointsEntry.value)
			let finalAmount = pointsDice.roll()
			finalCurrency[pointsEntry.key] = finalAmount
		}
		
		// Build a list for randomised items
		var finalItems = items
		var generatedItems: [ItemRepresentible] = []
		
		for gen in randomItems { generatedItems.append(gen()) }
		finalItems = addItems(generatedItems, set: items)
		
		let itemSetCount = finalItems.count
		
		
		// Pass on the new currencies!
		for reward in finalCurrency {
			player.points.add(type: reward.key, amount: .int(reward.value))
			
			/// BUILD FANCY MESSAGE
			if reward.value > 0 {
				message += "\(player.firstName) got \(reward.value) \(reward.key.symbol) (\(player.points[reward.key]!) \(reward.key.symbol))."
			}
			
			else if reward.value < 0 {
				message += "\(player.firstName) lost \(abs(reward.value)) \(reward.key.symbol) (\(player.points[reward.key]!) \(reward.key.symbol))."
			}
		}
		
		
		// Pass on the new items!
		for (index, item) in finalItems.enumerated() {
			player.inventory.addItems(item.value)
			
			
			/// BUILD FANCY MESSAGE
			let itemQuantity = item.value.count
			
			// If we're at the first index, introduce it.
			if index == 0 {
				message += "\(player.firstName) got "
			}
			
			// If the total is one or the index is the end of the list, cap it.
			if itemSetCount == 1 || index == itemSetCount - 1 {
				
				message += "\(numberWords[itemQuantity - 1]) \(item.value[0].getFullName())!"
			}
				
			else if index == itemSetCount - 2 {
				
				message += "\(numberWords[itemQuantity - 1]) \(item.value[0].getFullName()) and "
			}
				
			else {
				
				message += "\(numberWords[itemQuantity - 1]) \(item.value[0].getFullName()), "
			}
		}
		
		// Return the payload
		return message
	}
	
	/**
	Applies a reward to multiple players, and also provides a message with the results of each player printed on separate lines.
	*/
	public func applyReward(_ players: [UserProxy]) -> String {
		
		var result = ""
		for (i, player) in players.enumerated() {
			result += giveReward(player: player)
			
			if i != players.count - 1 {
				result += "\n"
			}
		}
		
		return result
	}
}


