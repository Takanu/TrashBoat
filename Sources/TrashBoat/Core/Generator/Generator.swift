

import Foundation
import Pelican

/**
Defines a system for selecting randomised results from a series of list, based on given probabilities of each result.
Probabilities can dynamically change to prevent repeat selections from occurring.
*/
class Generator {
	
	/// The results that the generator can be chosen from.
	var pool: [GeneratorOption] = []
	
	/// The number of times the generator has produced a result, used for selection tracking purposes.
	var generatorIndex: Int = 0
	
	/// The last selected result index.
	var lastSelectedIndex: Int?
	
	/// If true, in the event where the probability for any item chosen is 0, it will give all items a probability of 1 for just that one time, and randomly pick an option.
	var alwaysEnsureSelection = true
	
	/**
	A generator initialiser that uses a static probability figure assigned to each potential selection.
	*/
	init(array: [(probability: Int, selection: Any)]) {
		
		for item in array {
			pool.append(GeneratorOption(probability: item.probability, item: item.selection))
		}
	}
	
	/**
	A generator initialiser that assigns a probability figure along with a function that can modify the probability of the selection.  The function is called every time the generator makes a selection.
	*/
	init(arrayWithDrop array: [(initial: Int, selection: Any, bump: (GeneratorOption) -> ())]) {
		
		for item in array {
			pool.append(GeneratorOption(probability: item.initial, item: item.selection, bump: item.bump))
		}
	}
	
	/**
	A generator initialiser where all options use the same generator to modulate probabilities for each selection.  The function provided is called every time the generator makes a selection.
	*/
	init(arrayWithGenerator gen: @escaping (GeneratorOption) -> (), array: [(probability: Int, selection: Any)]) {
		
		for item in array {
			let gen = GeneratorOption(probability: item.probability, item: item.selection, bump: gen)
			pool.append(gen)
		}
	}
	
	/**
	Based on the probabilities of the items provided, fetches an item if at least one selection has a probability greater than 0.
	*/
	func getResult() -> Any? {
		
		// Create a new pool based on the old one
		var testPool = pool
		
		// Generate odds from the pool
		var odds: [(value: Int, odds: Int)] = []
		for (i, sel) in testPool.enumerated() {
			if sel.probability > 0 {
				odds.append((value: i, odds: sel.probability))
			}
		}
		
		if odds.count == 0 {
			
			if alwaysEnsureSelection == false {
				return nil
			}
			
			else {
				for (i, _) in testPool.enumerated() {
						odds.append((value: i, odds: 1))
				}
			}
		}
		
		// Generate and roll the dice
		var dice = Dice(withProbability: odds)
		let result = dice.roll()
		
		// Bump the generator index
		generatorIndex += 1
		
		// Get and activate the option
		let selection = testPool[result]
		selection.select(newIndex: generatorIndex)
		lastSelectedIndex = result
		
		// Update all the options to refresh probabilities
		pool.forEach( { $0.update(newIndex: generatorIndex) } )
		
		return selection.item
	}
	
	func getResults(count: Int, resetLastSelected: Bool) -> [Any?] {
		
		var results: [Any] = []
		
		for _ in 0..<count {
			results.append(getResult() as Any)
		}
		
		if resetLastSelected == true {
			clearLastSelected()
		}
		
		return results
	}
	
	func clearLastSelected() {
		lastSelectedIndex = nil
	}
	
	/**
	Resets all generator probabilities to their initial results, and resets all collected results currently stored.
	*/
	func reset() {
		lastSelectedIndex = nil
		
		for item in pool {
			item.reset()
		}
	}
}
