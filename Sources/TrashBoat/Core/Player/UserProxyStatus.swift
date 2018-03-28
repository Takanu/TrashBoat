

import Foundation

/**
Defines the current status for a UserProxy Session.
*/
public enum UserProxyStatus {
	
	/// The user hasn't joined the game yet.
	case idle
	
	/// The user has joined but the game has yet to start.
	case joined
	
	/// The user is actively playing in the current game.
	case active
	
	/// The user has left and their proxy needs to be removed at the earliest opportunity.
	case leaving
}
