
import Foundation
import Pelican


/**
Represents the player entity, including who the controller is, their
visual appearance, items, points and other statistics and other
player-specific details.

- note:
This is not the actual UserSession of the person playing the game
but a proxy they control and that can be used to identify them or attach game
properties to.  It's important to use a proxy to enable the ability for players
to leave games early without causing unpredictable damage to the state of the game.
*/
protocol UserProxy: class {
	
	// SESSION DATA
	/// The tag of the session that this proxy belongs to.
	var tag: SessionTag { get }
	
	/// The user data of the session that this proxy belongs to.
	var userInfo: User { get }
	
	
	// SESSION TYPES
	/// The base route of the UserSession this proxy belongs to.
	var baseRoute: Route { get set }
	
	/// The request type of the UserSession this proxy belongs to.
	var request: SessionRequest { get set }
	
	
	// CONVENIENCES
	/// The unique identifier for the user.
	var id: Int { get }
	
	/// User's or bot's first name.
	var firstName: String { get }
	
	/// User's or bot's last name.
	var lastName: String? { get }
	
	/// User's or bot's username.
	var username: String? { get }
	
	
	// STATUS
	/// The current status of the player using this proxy.  Used to let the game state know if the player has left.
	var status: UserProxyStatus { get set }
	
	/// The flair currently attached to the player.  Used for flexible state tracking and procedural events.
	var flair: FlairManager { get set }
	
	
	// ITEMS
	/// The items a player currently has.
	var inventory: Inventory { get set }
	
	/// The points a player currently has.
	var points: PointManager { get set }
	
	
	// INLINE CUSTOMISER
	/// The players this player can choose from, if in the middle of using a player route.
	var playerChoiceList: [InlineResultArticle] { get set }
	
	/// The list of players in the game, allowing the player to browse the turn order and statistics.
	var playerBrowseList: [UserProxy] { get set }
	
	/** The items that can be selected from the player's inventory, as specified by a ItemRoute.
	Still requires the FetchStatus flair in order for a player to be able to select items from it. */
	var itemSelect: [ItemTypeTag: [InlineResultArticle]] { get set }
	
	/// A space for generators to be able to modify the appearance of inline results sent to the player.  Just use the query name for the key.
	var inlineResultTransforms: [String: ([InlineResultArticle]) -> ([InlineResultArticle]) ] { get set }
	
	
	// REPRESENTABLE
	/** Returns an InlineResultArticle type that represents the player, allowing the player to be
	represented in a list for use in game events.  */
	func getInlineCard(id: String) -> InlineResultArticle
	
	
	// EQUATABLE
	/// Checks for equality between two UserProxy types.
	func isEqualTo(_ other: UserProxy) -> Bool
	
}

/**
Equality extensions
*/
extension UserProxy where Self : Equatable {
	
	func isEqualTo(_ other: UserProxy) -> Bool {
		
		if let o = other as? Self { return self == o }
		return false
	}
	
}
	
extension UserProxy {
	
	/**
	Calculates a grammatically correct list of players as a string message, for use in declaring
	collections of players elegantly.
	*/
	public static func getListText(_ players: [UserProxy]) -> String {
		
		var string = ""
		
		for (index, player) in players.enumerated() {
			if players.count == 1 {
				string += "\(player.firstName)"
			}
				
			else if index == players.count - 1 {
				string += "and \(player.firstName)"
			}
				
			else if index == players.count - 2 {
				string += "\(player.firstName) "
			}
				
			else {
				string += "\(player.firstName), "
			}
		}
		
		return string
	}
}




