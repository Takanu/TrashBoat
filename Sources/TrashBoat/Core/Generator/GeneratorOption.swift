//
//  GeneratorOption.swift
//  App
//
//  Created by Takanu Kyriako on 13/09/2017.
//

import Foundation
import Pelican

/**
A potential selection of the generator, defining it's own probability
as well as how that might change as it is selected.
*/
class GeneratorOption {
	
	// PROBABILITY TRACKERS
	/// The initial probability the selection is set to.
	var defaultProbability: Int
	
	/// The current probability value
	private var currentProbability: Int = 0
	
	/// The last set probability
	private var lastCurrentProbability: Int = 0
	
	
	/// What the probability was the previous time it was selected
	public var lastProbability: Int { return lastCurrentProbability }
	
	/// What the current probability of the selection is.  The probability of a selection can never be below 0.
	public var probability: Int {
		get {
			return currentProbability
		}
		set(newValue) {
			if newValue >= 0 {
				lastCurrentProbability = currentProbability
				currentProbability = newValue
			}
		}
	}
	
	// INDEX TRACKING
	/// The selection index of the generator the previous time it was picked
	private var lastSelectedIndex: Int = -1
	
	/// The selection index of the generator when it was last picked
	private var currentSelectedIndex: Int = -1
	
	/** What the current selection index of the selection is.  This is given to the selection when a generator picks it,
	and is based on how many times to generator has been asked to fetch results
	*/
	public var selectionIndex: Int {
		get {
			return currentSelectedIndex
		}
		set(newValue) {
			if newValue >= 0 {
				lastSelectedIndex = currentSelectedIndex
				currentSelectedIndex = newValue
			}
		}
	}
	
	/// The index the generator is currently set to
	private var generatorIndex: Int = -1
	
	// GLANCE INFO
	/// If true, this option has been selected
	public var hasBeenSelected: Bool {
		if generatorIndex == selectionIndex { return true }
		return false
	}
	
	/** If true, the last selection of the generator that this selection belongs to was
	picked the last time it was asked to provide a selection.
	*/
	public var wasConsecutivelySelected: Bool {
		if lastSelectedIndex == currentSelectedIndex - 1 {
			return true
		}
		
		return false
	}
	
	/// A factory function, that can be used to alter it's probability.
	public var bump: ((GeneratorOption) -> ())?
	
	/// The item that is selected, if chosen by a Generator.
	var item: Any
	
	
	/**
	Initialises an option with a static probaility value and item to be selected.
	*/
	init(probability: Int, item: Any) {
		self.defaultProbability = probability
		self.currentProbability = probability
		self.item = item
	}
	
	/**
	Initialises an option with a probaility value and item to be selected, alongside a function that will be called everytime the Generator the option is assigned to attempts to select one of the `GeneratorOption` instances it has.  The function can be used to modify the probability or contents of the generator.
	*/
	init(probability: Int, item: Any, bump: @escaping (GeneratorOption) -> ()) {
		self.defaultProbability = probability
		self.currentProbability = probability
		self.item = item
		self.bump = bump
	}
	
	
	/**
	Use this to mark the selection as having been selected.
	*/
	func select(newIndex: Int) {
		
		selectionIndex = newIndex
	}
	
	/**
	Use this to update the option (shouldn't need to call it outside the Generator).
	*/
	func update(newIndex: Int) {
		
		generatorIndex = newIndex
		
		// If the bump delegate exists, call it to self-modify any probabilities.
		if bump != nil {
			bump!(self)
		}
	}
	
	/**
	Resets all selected index and probability values to it's initialised values.
	*/
	func reset() {
		currentProbability = probability
		lastCurrentProbability = 0
		
		lastSelectedIndex = -1
		currentSelectedIndex = -1
		
		generatorIndex = -1
	}
}

