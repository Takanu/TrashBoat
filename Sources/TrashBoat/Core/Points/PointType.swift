//
//  CurrencyType.swift
//  App
//
//  Created by Takanu Kyriako on 17/11/2017.
//

import Foundation
import Pelican


/**
An type of inventory entity which holds and manages a specific type of currency.
*/
class PointType: Hashable, Equatable {
	
	/// The name of the currency.
	var name: String
	
	/// The symbol used as a shorthand to the name of the currency.
	var symbol: String
	
	/// If true, the value of the currency can fall below zero.
	var allowNegativeValue: Bool
	
	var hashValue: Int {
		return name.hashValue ^ symbol.hashValue ^ allowNegativeValue.hashValue
	}
	
	
	/**
	Initialises a new wallet type, which holds and manages a specific type of currency.
	*/
	init(name: String, symbol: String, allowNegativeValue: Bool) {
		self.name = name
		self.symbol = symbol
		self.allowNegativeValue = allowNegativeValue
	}
	
	/**
	Checks to see if the given currency has the same aesthetical details as this currency.  Any contents or numerical settings are not considered.
	*/
	static func ==(lhs: PointType, rhs: PointType)-> Bool {
		if lhs.name != rhs.name { return false }
		if lhs.symbol != rhs.symbol { return false }
		if lhs.allowNegativeValue != rhs.allowNegativeValue { return false }
		
		return true
	}
	
}

