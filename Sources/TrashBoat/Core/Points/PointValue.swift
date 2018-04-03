

import Foundation

/**
Used to let the player decide between using an Integer and Double as value types for Points
without having to use the messy and Linux-unfriendly NSNumber.
*/
public enum PointValue: Equatable {
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
}

