//
//  StringRepresentible.swift
//  App
//
//  Created by Takanu Kyriako on 22/11/2017.
//

import Foundation

/**
A simple protocol designed to reduce the syntax clutter of declaring static scenario definitions and enumerations.
*/
public protocol StringRepresentible {
	func string() -> String
}

extension String: StringRepresentible {
	
	public func string() -> String {
		return self
	}
}
