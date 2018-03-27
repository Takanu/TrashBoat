//
//  Player.swift
//  party
//
//  Created by Takanu Kyriako on 10/05/2017.
//
//

import Foundation
import Pelican


/**
Represents the player entity, including who the controller is,
visual appearance, items and dice and other statistics and 
character-specific details.

Also as a UserSession, the user could also not be in a game at all...
*/
class Player<HandleType: Handle>: Equatable {
	
	// GLOBAL STATUS
	/// Defines the activity of this current session.
	//var status: PlayerStatus = .idle
	
	/// The game the player is currently playing in.  Nil if the player is not currently playing.
	//var activeGame: Scenario? = nil
	
	
	// ROUTES
	/// The character request route
	var charRoute: RouteListen
	
	/// The player request route
	var playerRoute: RouteListen
	
	/// The item request route
	var itemRoute: RoutePass
	
	/// The player browse route
	var playerBrowseRoute: RouteListen
	
	
	// GAME PARAMETERS
	/// Holds all items currently available to the player, sorted by both type and quantity.  The items held will change depending on the game mode being played.
	var inventory = Inventory()
	
	/// A  s p e c t a c u l a r   way to keep track of all states influencing a player.
	var flair = FlairManager<HandleType>()
	
	/// Returns the user as a secret inline symbol, used for group or stealth mentions.
	var mention: String {
		return "[●](tg://user?id=\(tag.id))"
	}
	
	
	// INLINE REQUESTS
	/** The items that can be selected from the player's inventory, as specified by a ItemRoute.
	Still requires the FetchStatus flair in order for a player to be able to select items from it. */
	var itemSelect: [ItemTypeTag: [InlineResultArticle]] = [:]
	
	/// A space for generators to be able to modify the appearance of inline results sent to the player.  Just use the query name for the key.
	var inlineResultTransforms: [String: ([InlineResultArticle]) -> ([InlineResultArticle]) ] = [:]
	
	
	
	
	// Use this to set the inline router.
	required init(bot: PelicanBot, tag: SessionTag, update: Update) {
		
		charRoute = RouteListen(name: "char",
														pattern: "Character",
														type: .inlineQuery,
														action: {P in return true})
		
//		playerRoute = RouteListen(name: "player_choice",
//															pattern: MuseumTypes.playerChoiceRoute,
//															type: .inlineQuery,
//															action: {P in return true})
//
		itemRoute = RoutePass(name: "item",
													updateTypes: [.inlineQuery],
													action: {P in return true})
		
//		playerBrowseRoute = RouteListen(name: "player_list",
//																		pattern: MuseumTypes.playerBrowseRoute,
//																		type: .inlineQuery,
//																		action: {P in return true})
		
		//super.init(bot: bot, tag: tag, update: update)
	}
	
	func postInit() {
		
		// Setup the router now the initialisation has occurred
		charRoute.action = inlineCharacter(update:)
		charRoute.enabled = true
		
//		playerRoute.action = inlinePlayerChoices(update:)
//		playerRoute.enabled = false
		
		itemRoute.action = inlineItems(update:)
		itemRoute.enabled = false
		
//		playerBrowseRoute.action = inlinePlayerBrowsing(update:)
//		playerBrowseRoute.enabled = false
		
		// Build the "base" router, used to filter out blank updates.
		let baseClosure = { (update: Update) -> Bool in
			
			if update.from == nil { return false }
			if update.content == "" { return false }
			
			return true
		}
		
		let base = RouteManual(name: "base",
													 handler: baseClosure,
													 routes: charRoute, playerRoute, itemRoute, playerBrowseRoute)
		baseRoute = base
		
	}
	
	
	/**
	Resets all player properties to the default state.  Also bumps the timeout timer.
	*/
	func reset() {
		
//		self.status = .idle
//		self.activeGame = nil
//		self.char = nil
		
		self.inventory.clearAll()
		self.flair.clearAll()
		playerChoiceList = []
		playerBrowseList = []
		itemSelect = [:]
		inlineResultTransforms = [:]
		
		charRoute.enabled = true
		playerRoute.enabled = false
		itemRoute.enabled = false
		playerBrowseRoute.enabled = false
		
		// Bump down the timeout system to a small amount again.
		timeout.set(updateTypes: [.message, .callbackQuery, .inlineQuery], duration: 30.sec) {
			self.close()
		}
	}
	
	// Equatable conformance
	public static func ==(lhs: Player<HandleType>, rhs: Player<HandleType>) -> Bool {
		
		if lhs.info.tgID != rhs.info.tgID { return false }
		return true
	}
	
	/**
	Calculates a grammatically correct list of players as a string message, for use in declaring groups of players elegantly.
	*/
	public static func getListText(_ players: [Player]) -> String {
		
		var string = ""
		
		for (index, player) in players.enumerated() {
			if players.count == 1 {
				string += "\(player.name)"
			}
				
			else if index == players.count - 1 {
				string += "and \(player.name)"
			}
				
			else if index == players.count - 2 {
				string += "\(player.name) "
			}
				
			else {
				string += "\(player.name), "
			}
		}
		
		return string
	}
}




