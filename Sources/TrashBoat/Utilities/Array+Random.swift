

import Foundation


extension Array {
	
	/**
	Returns an element from the sequence at a random position.
	*/
  public var getRandom: Element? {
    if self.count > 0 {
      var xoro = Xoroshiro()
      let index = Int(xoro.random32(max: UInt32(self.count - 1)))
      return self[index]
    }
    
    else { return nil }
  }
	
	/**
	Returns a random index of the array.
	*/
	public var getRandomIndex: Int? {
		
		if self.count > 0 {
			var xoro = Xoroshiro()
			let index = Int(xoro.random32(max: UInt32(self.count - 1)))
			return index
		}
			
		else { return nil }
	}
	
	/**
	Returns a sequence of elements randomly selected from the array, the length of which is based on the length specified.
	*/
	public func randomSelection(length: Int) -> [Element]? {
		if self.count > 0 {
			
			var result: [Element] = []
			
			for _ in 0..<count {
				var xoro = Xoroshiro()
				let index = Int(xoro.random32(max: UInt32(self.count - 1)))
				
				result.append(self[index])
			}
			
			return result
		}
			
		else { return nil }
	}
	
	/**
	Returns a sequence of elements randomly selected from the array, the length of which is based on the length specified.
	Includes the option to include a random generator to make the picks.
	*/
	public func randomSelection(length: Int, generator: RandomGenerator) -> [Element]? {
		if self.count > 0 {
			
			var result: [Element] = []
			
			for _ in 0..<count {
				var newGen = generator
				let index = Int(newGen.random32(max: UInt32(self.count - 1)))
				
				result.append(self[index])
			}
			
			return result
		}
			
		else { return nil }
	}
	
	/**
	Removes and returns an element from the sequence at a random position.
	*/
  public mutating func popRandom() -> Element? {
    if self.count > 0 {
      var xoro = Xoroshiro()
      let index = Int(xoro.random32(max: UInt32(self.count - 1)))
      
      let item = self[index]
      self.remove(at: index)
      
      return item
    }
      
    else { return nil }
  }
	
	/**
	Returns a random sequence of elements based on the length you specify.  This differs from `randomSelection(length:)` in that the random selection will start by creating a copy of the array and randomly removing elements from it until it is empty.  When empty, the array will be repopulated again until the length parameter is met.
	*/
	public func randomUniqueSelection(length: Int) -> [Element]? {
		
		if self.count > 0 {
			
			var deck = self
			var result: [Element] = []
			
			// Loop over the deck, regenerating it if we need to.
			for _ in 0..<length {
				
				if deck.count == 0 {
					deck = self
				}
				
				result.append(deck.popRandom()!)
			}
			
			return result
		}
		
		else { return nil }
		
	}
}
