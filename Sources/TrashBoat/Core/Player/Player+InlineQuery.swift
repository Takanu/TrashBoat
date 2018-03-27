//
//  Player+InlineQuery.swift
//  App
//
//  Created by Takanu Kyriako on 07/09/2017.
//

import Foundation
import Pelican

extension Player {
	
	/**
	Used to pick a character for themselves at the beginning.  Only works when they haven't been registered in a game.
	*/
	func inlineCharacter(update: Update) -> Bool {
		
		if status == .idle {
			
			let availableCharacters = CharacterType.cases().array
			var availableCharacterInline: [CharacterType:InlineResultArticle] = [:]
			
			for (i, char) in availableCharacters.enumerated() {
				availableCharacterInline[char] = InlineResultArticle(id: String(i + 1), title: char.rawValue,
				                                                     description: "Choose the \(char.rawValue)", contents: "\(char.rawValue)", markup: nil)
			}
			
			requests.sync.answerInlineQuery(queryID: String(update.id),
																			results: availableCharacterInline.values.filter({ _ in return true }),
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
			return true
		}
		
		else if status == .playing {
			var articles: [InlineResultArticle] = []
			articles.append(InlineResultArticle(id: "1", title: "You've already chosen a character.",
			                    description: "¯\\_(ツ)_/¯", contents: "I like clicking inline buttons that shouldn't be clicked, please pity me.", markup: nil))
			
			requests.sync.answerInlineQuery(queryID: String(update.id),
																			results: articles,
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
		}
		
		return false
	}
	
	/**
	Used to pick a player during an active player route.
	*/
	func inlinePlayerChoices(update: Update) -> Bool {
		
		if let transform = inlineResultTransforms[update.content] {
			let newPlayerChoices = transform(playerChoiceList)
			requests.sync.answerInlineQuery(queryID: String(update.id),
																			results: newPlayerChoices,
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
		}
		
		else {
			requests.sync.answerInlineQuery(queryID: String(update.id),
																			results: playerChoiceList,
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
		}
		
		return true
	}
	
	/**
	Used to browse the turn cycle and player statistics at any point in the game.
	*/
	func inlinePlayerBrowsing(update: Update) -> Bool {
		
		// Makey the cards
		var friendCards: [InlineResultArticle] = []
		
		// If the list hasn't been built yet.
		if playerBrowseList.count == 0 {
			friendCards.append(InlineResultArticle(id: String(1),
																			 title: "Looks like you have no friends.",
																			 description: "¯\\_(ツ)_/¯",
																			 contents: "IM SO LONELY",
																			 markup: nil
			))
				
			requests.sync.answerInlineQuery(queryID: String(update.id),
																 results: friendCards,
																 nextOffset: nil,
																 switchPM: nil,
																 switchPMParam: nil)
		}
		
		else {
			for (i, friend) in playerBrowseList.enumerated() {
				friendCards.append(friend.getInlineCard(id: String(i + 1)))
			}
			
			if let transform = inlineResultTransforms[update.content] {
				let newFriendCards = transform(friendCards)
				requests.sync.answerInlineQuery(queryID: String(update.id),
																				results: newFriendCards,
																				nextOffset: nil,
																				switchPM: nil,
																				switchPMParam: nil)
			}
				
			else {
				requests.sync.answerInlineQuery(queryID: String(update.id),
																				results: friendCards,
																				nextOffset: nil,
																				switchPM: nil,
																				switchPMParam: nil)
			}
		}
		return true
	}
	
	/**
	Used to browse for and use items.
	*/
	func inlineItems(update: Update) -> Bool {
		
		// Work out if the update content matches any given item route definition.
		let types = inventory.getAllTypes()
		let chosenType = types.first(where: {$0.getRouteName == update.content})
		
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
																				 title: "You don't have any \(chosenType!.getPluralisedName)",
																				 description: "¯\\_(ツ)_/¯",
																				 contents: "Shiny Inline Button - LIZARD BRAIN MUST PRESS", markup: nil)
				)
				requests.sync.answerInlineQuery(queryID: String(update.id),
																	 results: cards,
																	 nextOffset: nil,
																	 switchPM: nil,
																	 switchPMParam: nil)
				return true
			}
			
			// Add VIEW MODE warnings after the new state system is done.
			else if flair.findFlair(chosenType!.fetchStatusFlair, compareContents: false) == false {
					
				// Build the warning
				let warning = InlineResultArticle(id: String(1), title: "V I E W   M O D E   O N L Y", description: "You can't currently use charms for a turn, feel free to browse them though :)", contents: "Shiny Inline Button - LIZARD BRAIN MUST PRESS", markup: nil)
			
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
			
			requests.sync.answerInlineQuery(queryID: String(update.id),
																			results: cards,
																			nextOffset: nil,
																			switchPM: nil,
																			switchPMParam: nil)
			return true
		}
		
		return false
	}
	
}
