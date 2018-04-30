

import Foundation

/**
Defines an EventError, which includes an Error type to help resolve and categorise the problem, and an
optional description for specifying issues in states or variables.
*/
public struct EventError: CustomStringConvertible {
	
	public private(set) var error: Error
	public private(set) var errorDescription: String?
	
	public var description: String {
		
		var finalDescription = ""
		if errorDescription == nil {
			finalDescription = "No description."
		} else {
			finalDescription = errorDescription!
		}
		
		return """
		\(error.localizedDescription) | \(finalDescription)
		"""
	}
	
	public init(_ error: Error, description: String? = nil) {
		self.error = error
		self.errorDescription = description
	}
}
