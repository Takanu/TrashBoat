

import Foundation
import Pelican

/**
This extension lets you retrieve statistics and information regarding the contents of the inventory.
*/
extension Inventory {
	
	/**
	Returns an array of inline query cards that represent the items a player has of a specific type.
	*/
	public func getInlineCards(forType type: ItemTypeTag) -> [InlineResultArticle]? {
		if items.keys.contains(type) == false { return nil }
		
		var result: [InlineResultArticle] = []
		let stacks = items[type]!
		
		for (i, stack) in stacks.enumerated() {
			
			// Modify the ID to ensure they are unique
			let cardContents = stack.itemCard.content!.base as! InputMessageContent_Text
			let cardRef = stack.itemCard
			let newCard = InlineResultArticle(id: String(i + 1),
																				title: cardRef.title,
																				description: cardRef.description ?? "",
																				contents: cardContents.text,
																				markup: nil)
			
			// Modify the title to include the quantity if needed.
			if stack.isUnlimited == false {
				newCard.title = "\(newCard.title)  (You have \(stack.count))"
			}
			
			// Throw it onto the pile
			result.append(newCard)
		}
		
		return result
	}
	
	/**
	Returns the number of items a player has of any given item type.  An item stack value will only contribute to the total if `isUnlimited` is false.
	*/
	public func getItemCount(forType type: ItemTypeTag) -> Int {
		if items.keys.contains(type) == false { return 0 }
	
		var totalCount = 0
		let stacks = items[type]!
		for stack in stacks {
			if stack.isUnlimited == false {
				totalCount += stack.count
			}
		}
		
		return totalCount
	}
	
}
