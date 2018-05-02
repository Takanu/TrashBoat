//
//  PointValueConvertible.swift
//  Pelican
//
//  Created by Ido Constantine on 02/05/2018.
//

import Foundation

/**
Allows a type to convert itself to a PointValue.
*/
public protocol PointValueConvertible {
	
	func getPointValue() -> PointValue
	
}

extension Int: PointValueConvertible {
	
	public func getPointValue() -> PointValue {
		return .int(self)
	}
}

extension Double: PointValueConvertible {
	
	public func getPointValue() -> PointValue {
		return .double(self)
	}
}
