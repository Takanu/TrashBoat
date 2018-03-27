//
//  UserProxy+Status.swift
//  App
//
//  Created by Takanu Kyriako on 07/09/2017.
//

import Foundation

/**
Defines the current status for a UserProxy Session.
*/
enum UserProxyStatus {
	
	/// The user is currently active in the current game.
	case active
	
	/// The user has left and their proxy needs to be removed at the earliest opportunity.
	case left
}
