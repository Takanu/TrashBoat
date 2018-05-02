

import Foundation

/**
Used to let the player decide between using an Integer and Double as value types for Points
without having to use the messy and Linux-unfriendly NSNumber.
*/
public enum PointValue: Equatable, PointValueConvertible {
	case int(Int)
	case double(Double)
	
	/// Returns the type value in Integer form.  If the case is not an Integer, it will be converted.
	public var int: Int {
		switch self {
		case .int(let int):
			return int
		case .double(let double):
			return Int(double)
		}
	}
	
	/// Returns the type value in Double form.  If the case is not an Double, it will be converted.
	public var double: Double {
		switch self {
		case .int(let int):
			return Double(int)
		case .double(let double):
			return double
		}
	}
  
  var type: String {
    switch self {
    case .int(_):
      return "Int"
    case .double(_):
      return "Double"
    }
  }
	
	public func getPointValue() -> PointValue {
		return self
	}
  
  
  static public func ==(lhs: PointValue, rhs: PointValue) -> Bool {
    
    switch lhs {
    case .int(let lhsInt):
      if rhs.type == "Double" { return false }
      
      let rhsInt = rhs.int
      if lhsInt != rhsInt { return false }
      return true
      
    case .double(let lhsDouble):
      if rhs.type == "Double" { return false }
      
      let rhsDouble = rhs.double
      if lhsDouble != rhsDouble { return false }
      return true
    }
  }
}

