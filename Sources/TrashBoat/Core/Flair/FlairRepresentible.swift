

import Foundation
import Pelican

/**
A shortcut protocol that lets other types be passed to the StateSystem quickly.
*/
protocol FlairRepresentible {
	
	func getFlair() -> Flair
}
