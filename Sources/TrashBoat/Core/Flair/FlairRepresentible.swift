//
//  FlairRepresentible.swift
//  App
//
//  Created by Ido Constantine on 21/11/2017.
//

import Foundation
import Pelican

/**
A shortcut protocol that lets other types be passed to the StateSystem quickly.
*/
protocol FlairRepresentible {
	
	func getFlair() -> Flair
}
