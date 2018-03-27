//
//  ItemRoute.swift
//  App
//
//  Created by Takanu Kyriako on 18/11/2017.
//

import Foundation
import Pelican

/**
A abstract route system to allow players to request a specific item from their inventory.
*/
class ItemRoute: Route {
	
	/// The results currently received by players.  Do not use this to directly get the results of the route, as it will not include players that didn't submit a response.
	private var results: [ItemTypeTag: [(player: UserProxy, item: ItemRepresentible?)] ] = [:]
	
	/// The item types that are part of the current request.
	var itemTypes: [ItemTypeTag] = []
	
	/// The players that have been chosen to select an item
	var selectors: [UserProxy] = []
	
	/** Stores the generated Inline Results for all the items a selected player has (within the types that can be selected), with
	an invisible marker that prevents selection outside of inline queries.
	*/
	var routedItems: [Int: [ItemTypeTag: [String: ItemInfoTag]]] = [:]
	
	/** Stores the custom-made inline cards for each player
	*/
	var routedCards: [Int: [ItemTypeTag: [InlineResultArticle]]] = [:]
	
	/// The next function associated with each item type, if the result count associated with them matches their result count.
	var requestExits: [ItemTypeTag: (() -> ())? ] = [:]
	
	
	public var inlineKeys: [MarkupInlineKey] {
		var result: [MarkupInlineKey] = []
		
		for type in itemTypes {
			result.append(MarkupInlineKey(fromCallbackData: type.routeName, text: type.name)!)
		}
		
		return result
	}
	
	init() {
		super.init(name: "item_route", action: {P in return true})
	}
	
	/**
	Initialises a new request, that allows the chat session to listen for specific players to send specific item requests.  Will also
	configure the UserProxy type to view the items without the "VIEW MODE ONLY" warning.
	
	- parameter types: The types of items a player can submit, and the closure that will be triggered should all selectors submit one response
	for that item type.
	- parameter selectors: The users that are able to submit an item request.
	*/
	func newRequest(types: [(type: ItemTypeTag, next: ( () -> () )?)], selectors: [UserProxy]) {
		
		resetRequest()
		
		let invisibleGlyphs = ["\u{2063}", "\u{200B}", "\u{2064}"]
		self.itemTypes = types.map({ $0.type })
		self.selectors = selectors
		
		/// Build the custom inline cards for super-stealth.
		for player in selectors {
			
			var playerRoutedInlineCards: [ItemTypeTag: [InlineResultArticle]] = [:]
			var playerRoutedItems: [ItemTypeTag: [String: ItemInfoTag]] = [:]
			
			for set in types {
				
				let type = set.type
				
				let initialCards = player.inventory.getInlineCards(forType: type) ?? []
				var itemInfo = player.inventory.getItemInfo(forType: type.getName) ?? []
				
				var fixedCards: [InlineResultArticle] = []
				var routedItems: [String: ItemInfoTag] = [:]
				
				// For every card, we need to edit it's contents with a random set of invisible glyphs!
				for (i, card) in initialCards.enumerated() {
					let newCard = card
					let cardContents = card.content!.base as! InputMessageContent_Text
					let glyphSurprise = invisibleGlyphs.randomSelection(length: 6)!.joined()
					
					let newLabel = cardContents.text + glyphSurprise
					cardContents.text = newLabel
					newCard.content = InputMessageContent(content: cardContents)
					
					fixedCards.append(card)
					routedItems[newLabel] = itemInfo[i]
				}
				
				// Add the generated sets to the ItemTypeTag keys
				playerRoutedItems[type] = routedItems
				playerRoutedInlineCards[type] = fixedCards
			}
			
			// Add the new inline cards and routed item sets under the player's ID
			routedItems[player.id] = playerRoutedItems
			routedCards[player.id] = playerRoutedInlineCards
			
			// Give the player the new cards
			player.itemSelect = playerRoutedInlineCards
			
		}
		
		for set in types {
			
			// Set the flair in the system
			self.itemTypes.append(set.type)
			self.requestExits[set.type] = set.next
			
			// Build the array for the type in the results dictionary
			results[set.type] = []
			
			// Disable VIEW MODE ONLY warnings for all selectors
			selectors.forEach({ $0.flair.addFlair(set.type.fetchStatusFlair) })
		}
		
		self.enabled = true
		
		
	}
	
	/**
	Receives updates to work out if they should be accepted by this route as valid responses.  This function
	searches through all items a player has to see if it matches the definition
	*/
	override func handle(_ update: Update) -> Bool {
		
		// Eliminate bad possibilities
		if selectors.contains(where: {$0.id == update.from!.tgID }) == false { return false }
		//if results.contains(where: {$0.keys.player.info.tgID == update.from!.tgID}) == true { return false }
		
		// Get the player
		let player = selectors.first(where: {$0.id == update.from!.tgID } )!
		let playerRoutedItems = routedItems[player.id]!
		
		// Go through their items in the form of inline cards to work out if there's a match
		for type in itemTypes {
			
			// If the player has already successfully made a request for this item type, exit.
			let resultSet = results[type]!
			if resultSet.first(where: {$0.player.id == player.id}) != nil { return false }
			
			// Otherwise get the set of items for this type and searc hthrough them
			let itemTypeSet = playerRoutedItems[type]!
			
			for (i, label) in itemTypeSet.keys.filter({_ in return true}).enumerated() {
				
				// If the label matches the content, retrieve the item
				if label == update.content {
					
					let chosenItemInfo = itemTypeSet.values.filter({_ in return true})[i]
					
					// Request the item from the player's inventory and add it to the results if not nil.
					let fetchedItem = player.inventory.removeItem(type: chosenItemInfo.type.name, name: chosenItemInfo.name)
					
					if fetchedItem != nil {
						results[type]!.append((player, fetchedItem))
						
						// If all results have been collected for this type, call next.
						if results[type]!.count == selectors.count {
							
							let next = requestExits[type]!
							if next != nil {
								
								let unwrappedNext = next!
								unwrappedNext()
							}
						}
						
						return true
					}
				}
				
			}
		}
		return false
	}
	
	/**
	Returns a set of results in a consistently formatted manner, where every target will appear even if they didn't select an item.
	*/
	func getResults(forItemType type: String) -> [(player: UserProxy, item: ItemRepresentible?)]? {
		
		// Get the set corresponding to the item type provided if it exists
		let typeResults = results.first(where: {$0.key.name == type})
		if typeResults == nil { return nil }
		
		// Build a list of results using the initial players that submitted one
		var returnedResults = typeResults!.value
		
		// Figure out what players didn't submit something and add them to the list
		let leftovers = selectors.filter( {T in returnedResults.contains(where: {P in T.id == P.player.info.tgID}) == false })
		for leftover in leftovers {
			returnedResults.append((leftover, nil))
		}
		
		return returnedResults
	}
	
	/**
	Resets everything!
	*/
	func resetRequest() {
		
		// Enable VIEW MODE ONLY warnings for all selectors
		for type in itemTypes {
			selectors.forEach({ $0.flair.removeFlair(type.fetchStatusFlair, removeAll: true) })
		}
		
		// Clear out the item select options for every selected player
		selectors.forEach({ $0.itemSelect = [:] })
		
		// Now clear everything else
		results = [:]
		itemTypes = []
		selectors = []
		requestExits = [:]
		
		routedItems = [:]
		routedCards = [:]
		
		self.enabled = false
	}
	
	override func compare(_ route: Route) -> Bool {
		/*
		if route is CharmRoute {
			let otherRoute = route as! CharmRoute
			
			// Check the ID
			if self.id != otherRoute.id { return false }
			//if self.results.count != otherRoute.results.count { return false }
			
			return true
		}
		*/
		return false
	}
	
}
