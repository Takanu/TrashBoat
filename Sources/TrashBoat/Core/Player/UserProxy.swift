
import Foundation
import Pelican


/**
Represents the player entity, including who the controller is, their
visual appearance, items, points and other statistics and other
player-specific details.

- note:
This is not the actual UserSession of the person playing the game
but a proxy they control and that can be used to identify them.  It's
important to use a proxy to enable the ability for players to leave games early
without causing unpredictable damage to the state of the game.
*/
protocol UserProxy: class {
	
	// SESSION DATA
	/// The tag of the session that this proxy belongs to.
	var tag: SessionTag { get }
	
	/// The user data of the session that this proxy belongs to.
	var userInfo: User { get }
	
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
	
	// REPRESENTABLE
	/**
	Returns an InlineResultArticle type that represents the player, allowing the player to be represented in a list for use in game events
	*/
	func getInlineCard(id: String) -> InlineResultArticle
	
}
	
extension UserProxy {
	
	init(session: UserSession) {
		self.tag = session.tag
		self.userInfo = session.info
		
	}
	
	/**
	Calculates a grammatically correct list of players as a string message, for use in declaring groups of players elegantly.
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




