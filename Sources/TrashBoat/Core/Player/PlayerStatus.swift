//
//  Player+Status.swift
//  App
//
//  Created by Takanu Kyriako on 07/09/2017.
//

import Foundation

/**
Defines the current status for a Player Session.
*/
enum PlayerStatus {
	
	/// The user is not in a current game.
	case idle
	
	/// The user is in an active game.  When in an active game, the player cannot join another game.
	case playing
}
