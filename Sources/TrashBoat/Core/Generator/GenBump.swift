//
//  GeneratorBump.swift
//  App
//
//  Created by Takanu Kyriako on 15/09/2017.
//

import Foundation
import Pelican

/**
A series of static functions designed to provide convenient ways to assign common randomisation behaviours to a Generator.
*/
class GenBump {
	
	/// Reduces the probability by 1 every time it is selected.
	static func counter() -> ((GeneratorOption) -> ()) {
		
		let result: (GeneratorOption) -> () = { gen in
			
			if gen.hasBeenSelected {
				gen.probability -= 1
			}
		}
		
		return result
	}
	
	/// A more advanced selector bump that generates a function based on a given drop variable or equation. When an option is selected, it's probability temporarily drops.
	static func tempDrop(dropValue: Int) -> ((GeneratorOption) -> ()) {
		
		let result: (GeneratorOption) -> () =  { gen in
			
			if gen.hasBeenSelected == true {
				gen.probability = dropValue
			}
				
			else {
				gen.probability = gen.defaultProbability
			}
		}
		
		return result
	}
	
	/// A function that drops the probability of the option temporarily, once selected twice in a row.
	static func tempDoubleDrop(dropValue: Int) -> ((GeneratorOption) -> ()) {
		
		let result: (GeneratorOption) -> () =  { gen in
			
			if gen.hasBeenSelected == true {
				if gen.wasConsecutivelySelected == true {
					gen.probability = dropValue
				}
				
				else {
					gen.probability = gen.defaultProbability
				}
			}
				
			else {
				gen.probability = gen.defaultProbability
			}
		}
		
		return result
	}
	
	
	/**
	Both permanently reduces the probability by 1, every time it is selected, while providing a way to drop the value of the probability after it is selected twice in a row.
	*/
	static func counterDoubleDrop(dropValue: Int) -> ((GeneratorOption) -> ()) {
		
		let result: (GeneratorOption) -> () =  { gen in
			
			if gen.hasBeenSelected == true {
				
				if gen.wasConsecutivelySelected == true {
					gen.defaultProbability -= 1
					gen.probability = dropValue
				}
				
				else {
					gen.defaultProbability -= 1
					gen.probability = gen.defaultProbability
				}
			}
			
			else {
				gen.probability = gen.defaultProbability
			}
		}
		
		return result
	}

}
