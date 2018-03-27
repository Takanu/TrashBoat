
import Foundation
import Pelican

// Just a few extensions for handling player queue swapsies!
extension Array {
	
	/**
	Moves the entry on the end of the array to the front.
	*/
	mutating func lastToFirst() {
		let item = self.removeLast()
		self.insert(item, at: 0)
	}
	
	/**
	Moves the first entry in the array to be the last.
	*/
	mutating func firstToLast() {
		let item = self.removeFirst()
		self.append(item)
	}
	
	/**
	Moves an item that matches the corresponding index to the last index of the array.
	*/
	mutating func pushToLast(index: Int) {
		
		let item = self.remove(at: index)
		self.append(item)
	}
}
