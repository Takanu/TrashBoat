

import Foundation

/**
Defines the kind of dice a Dice is.  *shrug*
*/
enum DiceType {
	
	/// Defines a dice that can roll a value between two values.
	case range
	
	/// Defines a dice that can roll from a selection of values, where all of them have an equal chance of being rolled.
	case selection
	
	/// Defines a dice that can only roll a single value.
	case constant
	
	/// Defines a dice that can roll from a selection of values, where all of them have custom assigned probabilities for being rolled.
	case probability
}
