

import Foundation
import Pelican

/**
Contains a bunch of functions that support ItemRoute and PlayerRoute, to be used
when setting handlers for player routes.
*/

extension UserProxy {
	
	/**
	Used to pick a player during an active player route.
	*/
	func inlinePlayerChoices(update: Update) -> Bool {
		
		if let transform = inlineResultTransforms[update.content] {
			let newPlayerChoices = transform(playerChoiceList)
			request.async.answerInlineQuery(queryID: String(update.id),
																			 results: newPlayerChoices,
																			 nextOffset: nil,
																			 switchPM: nil,
																			 switchPMParam: nil)
		}
			
		else {
			request.async.answerInlineQuery(queryID: String(update.id),
																			 results: playerChoiceList,
																			 nextOffset: nil,
																			 switchPM: nil,
																			 switchPMParam: nil)
		}
		
		return true
	}
	
	/**
	Used to browse for and use items.
	*/
	func inlineItems(update: Update) -> Bool {
		
		// Work out if the update content matches any given item route definition.
		let types = inventory.getAllTypes()
		let chosenType = types.first(where: {$0.routeName == update.content})
		
		// If a type was found, try to fetch the item list for
		if chosenType != nil {
			
			
			// Decide where to get the cards from
			var cards: [InlineResultArticle] = []
			
			if itemSelect[chosenType!] != nil {
				cards = itemSelect[chosenType!]!
			}
				
			else {
				cards = inventory.getInlineCards(forType: chosenType!)!
			}
			
			
			// If we have no cards, provide a default response to at least acknowledge the request and return early
			if cards.count == 0 {
				
				cards.append(InlineResultArticle(id: String(1),
																				 title: "You don't have any \(chosenType!.pluralisedName)",
					description: "¯\\_(ツ)_/¯",
					contents: "Shiny Inline Button - LIZARD BRAIN MUST PRESS", markup: nil)
				)
				
				request.async.answerInlineQuery(queryID: String(update.id),
																				 results: cards,
																				 nextOffset: nil,
																				 switchPM: nil,
																				 switchPMParam: nil)
				return true
			}
				
				
			// Add VIEW MODE warnings after the new state system is done.
			else if flair.findFlair(chosenType!.fetchStatusFlair, compareContents: false) == false {
				
				// Build the warning
				let warning = InlineResultArticle(id: String(1),
																					title: "V I E W   M O D E   O N L Y",
																					description: "You can't currently use charms for a turn, feel free to browse them though :)",
																					contents: "Shiny Inline Button - LIZARD BRAIN MUST PRESS", markup: nil)
				
				// Amend the other cards
				for (i, card) in cards.enumerated() {
					card.tgID = String(i + 2)
				}
				
				// Insert the warning
				cards.insert(warning, at: 0)
			}
			
			
			// If we have a valid transform for this item type (based on the route name it specifies), use that to get a final set of cards.
			if let transform = inlineResultTransforms[update.content] {
				cards = transform(cards)
			}
			
			request.async.answerInlineQuery(queryID: String(update.id),
																			 results: cards,
																			 nextOffset: nil,
																			 switchPM: nil,
																			 switchPMParam: nil)
			return true
		}
		
		return false
	}
	
}
