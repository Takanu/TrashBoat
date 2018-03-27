//
//  PlayerRequest.swift
//  App
//
//  Created by Takanu Kyriako on 22/09/2017.
//

import Foundation
import Pelican

/**
Encapsulates the process of requesting and processing requests where
a player is supposed to choose another player for an event.
*/
class PlayerRoute: Route {
	
	/// The results currently received by the route.  This should never be used to directly receive results, as it cannot account for every player that didn't choose a target.
  private var results: [(player: Player, choice: Player?)] = []
	
	/// The selectors that are able to select a target.
  var selectors: [Player] = []
	
	/// The targets that can be picked from.
  var targets: [Player] = []
	
	/** A set of targets corresponding to each selector (player that is able to pick a player), with the string that's used by the route handler to identify them by.  If anonymised, the string will be a unique key that will be unrelated to the player name.
	*/
	var routedTargets: [Int: [String: Player]] = [:]
	
	public var inlineKey: MarkupInlineKey {
		return MarkupInlineKey(fromInlineQueryCurrent: MuseumTypes.playerChoiceRoute, text: "Choose Friend")
	}
  
  /// The player list available to select from.  This list will be used to match
  var articles: [Int:[InlineResultArticle]] = [:]
  var includeSelf = false
  var includeNone = false
  
  /// If all targets have assigned result, this optional functional will be called.
  var next: (() -> ())?
	
	init() {
		super.init(name: "player_route", action: {P in return true})
	}
	
	/**
	Starts a new request?
	- parameter selectors: The players that can pick another player.
	- parameter targets: The players that can be chosen from.
	- parameter includeSelf: If true, a player that's being asked to choose can also choose themselves.
	- parameter includeNone: If true, a player can decide not to choose anyone as an option.
	- parameter anonymiser: If not nil, this will be used to generate a unique name for every target, allowing the selectors selecting to not reveal to others who they have chosen.
	*/
	func newRequest(selectors: [Player], targets: [Player], includeSelf: Bool, includeNone: Bool, next: @escaping () -> (), anonymiser: ( ([Player]) -> ([String]) )?) {
    
    resetRequest()
		
		self.next = next
    self.selectors = selectors
    self.targets = targets
    self.includeSelf = includeSelf
    self.includeNone = includeNone
    
    for selector in selectors {
      
      var targetArticles: [InlineResultArticle] = []
			var availableTargets: [Player] = []
    
      // Generate the player list based on the passed information (must be done outside defer)
      var playerIndex = 0
      for (i, target) in targets.enumerated() {
        
        // If the target is supposed to be excluded from the list, make sure that happens here.
        if includeSelf == false && target == selector {
          continue
          
        } else {
					availableTargets.append(target)
          targetArticles.append(target.getInlineCard(id: String(playerIndex + 1)))
        }
        
        playerIndex = i + 1
      }
      
      // If a "No, i dont want to select someone asshole" option can be available, materialise it.
      if includeNone == true {
        let title = "Pick Nobody"
        let description = "If you don't want to, pick nobody."
        targetArticles.append(InlineResultArticle(id: String(playerIndex + 1), title: title, description: description, contents: title, markup: nil))
      }
			
			// If we're using the anonymiser, substitute the Article contents for the newly generated names.
			if anonymiser != nil {
				let newLabels = anonymiser!(availableTargets)
				var modifiedArticles: [InlineResultArticle] = []
				var targetSet: [String: Player] = [:]
				
				for i in 0..<availableTargets.count {
					let newLabel = newLabels[i]
					let newTarget = availableTargets[i]
					let newArticle = targetArticles[i]
					
					let inputText = newArticle.content!.base as! InputMessageContent_Text
					inputText.text = newLabel
					newArticle.content = InputMessageContent(content: inputText)
					
					modifiedArticles.append(newArticle)
					targetSet[newLabel] = newTarget
				}
				
				selector.playerChoiceList = modifiedArticles
				routedTargets[selector.info.tgID] = targetSet
				articles[selector.info.tgID] = modifiedArticles
			}
			
			// Otherwise just set them normally
			else {
				var targetSet: [String: Player] = [:]
				
				for i in 0..<availableTargets.count {
					let newArticle = targetArticles[i]
					let newTarget = availableTargets[i]
					let inputText = newArticle.content!.base as! InputMessageContent_Text
					targetSet[inputText.text] = newTarget
				}
				
				selector.playerChoiceList = targetArticles
				routedTargets[selector.info.tgID] = targetSet
				articles[selector.info.tgID] = targetArticles
			}
			
			selector.playerRoute.enabled = true
    }
		
		// Set self as true
		self.enabled = true
  }


  override func handle(_ update: Update) -> Bool {
    
    // Eliminate bad possibilities
    if update.from == nil || update.content == "" { return false }
    if selectors.contains(where: {$0.info.tgID == update.from!.tgID }) == false { return false }
    if results.contains(where: {$0.player.info.tgID == update.from!.tgID}) == true { return false }
    
    // Get the player
    let player = selectors.first(where: {$0.info.tgID == update.from!.tgID } )!
    
    // If the text is "Pick Nobody", add a nil result to the stack.
    if update.content == "Pick Nobody" {
      results.append((player, nil))
    }
      
    // Otherwise try and find the target the selector is referring to
    else {
      if let choice = routedTargets[player.info.tgID]![update.content] {
        results.append((player, choice))
      }
    }
    
    // After that if we've reached the quota, call next
    if results.count == selectors.count {
      if next != nil {
        next!()
      }
    }
    
    return true
  }
	
	/**
	Returns a set of results in a consistently formatted manner, where every target will appear even if they didn't select a charm.
	*/
	func getResults() -> [(player: Player, choice: Player?)] {
		var returnedResults = results
		
		let leftovers = selectors.filter( {T in results.contains(where: {P in T.info.tgID == P.player.info.tgID}) == false })
		for leftover in leftovers {
			returnedResults.append((leftover, nil))
		}
		
		return returnedResults
	}
	
	/**
	Resets everything!
	*/
  func resetRequest() {
		
		for target in targets {
			target.playerChoiceList = []
			target.playerRoute.enabled = false
		}
		
    selectors = []
    results = []
    targets = []
		routedTargets = [:]
    articles = [:]
    includeSelf = false
    includeNone = false
    next = nil
		
		self.enabled = false
  }
	
	override func compare(_ route: Route) -> Bool {
		
		if route is PlayerRoute {
			let otherRoute = route as! PlayerRoute
			
			// Check the ID
			if self.results.count != otherRoute.results.count { return false }
			
			return true
		}
		
		return false
	}
}
