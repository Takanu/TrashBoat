

import Foundation
import Pelican

/**
Encapsulates the process of requesting and processing requests where
a player is supposed to choose another player for an event.
*/
public class PlayerRoute: Route {
	
	// STATE
	/// The results currently received by the route.  This should never be used to directly receive results, as it cannot account for every player that didn't choose a target.
  private var results: [(player: UserProxy, choice: UserProxy?)] = []
	
	/// The selectors that are able to select a target.
  public var selectors: [UserProxy] = []
	
	/// The targets that can be picked from.
  public var targets: [UserProxy] = []
	
	/** A set of targets corresponding to each selector (player that is able to pick a player), with
	the string that's used by the route handler to identify them by.  If anonymised, the string will
	be a unique key that will be unrelated to the player name. */
	public var routedTargets: [String: [String: UserProxy]] = [:]
	
	/// The player list available to select from.  This list will be used to match players to the articles they should have access to.
	public var articles: [String: [InlineResultArticle]] = [:]
	
	
	// OPTIONS
	/** Represents an inline key, containing the data that the route will look when a
	player uses an inline query in order to display player selections. */
	public var inlineKey: MarkupInlineKey
	
	// Represents the inline card appearance for selecting no-one.
	static var pickNobodyCard = InlineResultArticle(id: "1",
																									title: "Pick Nobody",
																									description: "If you don't want to, pick nobody.",
																									contents: "Pick Nobody",
																									markup: nil)
	
	/// If true, the selector will see themselves as a player choice.
  public var includeSelf = false
	
	/// If true, the selector will be able to pick nobody as a player choice
  public var includeNone = false
  
  /// If all targets have assigned result, this optional functional will be called.
  public var next: (() -> ())?
	
	
	
	/**
	Creates a PlayerRoute type, specifically used to allow users to browse and select other players.
	
	- parameter inlineKey: The inline key that will be used to show player selections.
	*/
	public init(inlineKey: MarkupInlineKey) {
		self.inlineKey = inlineKey
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
	public func newRequest(selectors: [UserProxy],
												 targets: [UserProxy],
												 includeSelf: Bool,
												 includeNone: Bool,
												 next: @escaping () -> (),
												 anonymiser: ( ([UserProxy]) -> ([String]) )?) {
    
    resetRequest()
		
		self.next = next
    self.selectors = selectors
    self.targets = targets
    self.includeSelf = includeSelf
    self.includeNone = includeNone
    
    for selector in selectors {
      
      var targetArticles: [InlineResultArticle] = []
			var availableTargets: [UserProxy] = []
    
      // Generate the player list based on the passed information (must be done outside defer)
      var playerIndex = 0
      for (i, target) in targets.enumerated() {
        
        // If the target is supposed to be excluded from the list, make sure that happens here.
        if includeSelf == false && target.isEqualTo(selector) {
          continue
          
        } else {
					availableTargets.append(target)
          targetArticles.append(target.getInlineCard(id: String(playerIndex + 1)))
        }
        
        playerIndex = i + 1
      }
      
      // If a "No, i dont want to select someone asshole" option can be available, materialise it.
      if includeNone == true {
				
				let pickCopy = InlineResultArticle(id: String(playerIndex + 1),
																					 title: PlayerRoute.pickNobodyCard.title,
																					 description: PlayerRoute.pickNobodyCard.description ?? "",
																					 contents: PlayerRoute.pickNobodyCard.title,
																					 markup: nil)
				targetArticles.append(pickCopy)
      }
			
			// If we're using the anonymiser, substitute the Article contents for the newly generated names.
			if anonymiser != nil {
				let newLabels = anonymiser!(availableTargets)
				var modifiedArticles: [InlineResultArticle] = []
				var targetSet: [String: UserProxy] = [:]
				
				for i in 0..<availableTargets.count {
					let newLabel = newLabels[i]
					let newTarget = availableTargets[i]
					var newArticle = targetArticles[i]
					
					let inputContent = newArticle.content!.base as! InputMessageContent_Text
					let newInputText = InputMessageContent_Text(text: inputContent.text, parseMode: "Markdown", disableWebPreview: true)
					newArticle.content = InputMessageContent(content: newInputText)
					
					modifiedArticles.append(newArticle)
					targetSet[newLabel] = newTarget
				}
				
				selector.playerChoiceList = modifiedArticles
				routedTargets[selector.id] = targetSet
				articles[selector.id] = modifiedArticles
			}
			
			// Otherwise just set them normally
			else {
				var targetSet: [String: UserProxy] = [:]
				
				for i in 0..<availableTargets.count {
					let newArticle = targetArticles[i]
					let newTarget = availableTargets[i]
					let inputText = newArticle.content!.base as! InputMessageContent_Text
					targetSet[inputText.text] = newTarget
				}
				
				selector.playerChoiceList = targetArticles
				routedTargets[selector.id] = targetSet
				articles[selector.id] = targetArticles
			}
			
			//selector.playerRoute.enabled = true
    }
		
		// Set self as true
		self.enabled = true
  }

	
  override public func handle(_ update: Update) -> Bool {
    
    // Eliminate bad possibilities
    if update.from == nil || update.content == "" { return false }
    if selectors.contains(where: {$0.id == update.from!.tgID }) == false { return false }
    if results.contains(where: {$0.player.id == update.from!.tgID}) == true { return false }
    
    // Get the player
    let player = selectors.first(where: {$0.id == update.from!.tgID } )!
    
    // If the text is "Pick Nobody", add a nil result to the stack.
    if update.content == "Pick Nobody" {
      results.append((player, nil))
    }
      
    // Otherwise try and find the target the selector is referring to
    else {
      if let choice = routedTargets[player.id]![update.content] {
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
	public func getResults() -> [(player: UserProxy, choice: UserProxy?)] {
		var returnedResults = results
		
		let leftovers = selectors.filter( {T in results.contains(where: {P in T.id == P.player.id}) == false })
		for leftover in leftovers {
			returnedResults.append((leftover, nil))
		}
		
		return returnedResults
	}
	
	/**
	Resets everything!
	*/
  public func resetRequest() {
		
		for target in targets {
			target.playerChoiceList = []
			//target.playerRoute.enabled = false
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
	
	override public func compare(_ route: Route) -> Bool {
		
		if route is PlayerRoute {
			let otherRoute = route as! PlayerRoute
			
			// Check the ID
			if self.results.count != otherRoute.results.count { return false }
			
			return true
		}
		
		return false
	}
}
