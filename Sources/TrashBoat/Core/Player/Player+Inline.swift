//
//  Player+Inline.swift
//  App
//
//  Created by Takanu Kyriako on 12/09/2017.
//

import Foundation
import Pelican

extension Player {
	
	/**
	Returns an inline query entry for the player
	*/
	func getInlineCard(id: String) -> InlineResultArticle {
		
		let title = self.plainName
		let description = "\(inventory[MuseumTypes.fortune] ?? 0) 🌙 Fortune - \(inventory.getItemCount(forType: MuseumTypes.dice)) Dice"
		let message = title
		
		return InlineResultArticle(id: id, title: title, description: description, contents: message, markup: nil)
	}
}
