//
//
//  MIT License
//
//  Copyright (c) 2023-Present Catcher
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

import Foundation

// MARK: - Catcher

open class Catcher {
	
	// MARK: Policy
	
	public enum Policy {
		case proceed
		case stop
	}
	
	// MARK: Typealias
	
	public typealias Action = (Error) -> Policy
	
	// MARK: Private properties
	
	private var alwaysActions: [Action] = []
	
	private var noMatchActions: [Action] = []
	
	private var errorActions: [(ErrorCategory, Action)] = []
	
	// MARK: Init
	
	public init() {
		
	}
	
	// MARK: Handle
	
	public func handle(_ error: Error) {
		
		defer {
			for action in alwaysActions.reversed() {
				if case .stop = action(error) {
					break
				}
			}
		}
		
		var isCategoryFound: Bool = false
		for (category, action) in errorActions.reversed() {
			if category.includes(error) {
				isCategoryFound = true
				if case .stop = action(error) {
					return
				}
			}
		}
		
		if isCategoryFound {
			return
		}
		
		for action in noMatchActions.reversed() {
			if case .stop = action(error) {
				return
			}
		}
		
	}
	
	// MARK: "On" methods
	
	@discardableResult public func on(
		_ category: ErrorCategory,
		do action: @escaping Action
	) -> Self {
		errorActions.append((category, action))
		return self
	}
	
	@discardableResult public func on(
		matches: @escaping (Error) -> Bool,
		do action: @escaping Action
	) -> Self {
		return on(ClosureErrorCategory(includes: matches), do: action)
	}
	
	@discardableResult public func onNoMatch(
		do action: @escaping Action
	) -> Self {
		noMatchActions.append(action)
		return self
	}
	
	@discardableResult public func always(
		do action: @escaping Action
	) -> Self {
		alwaysActions.append(action)
		return self
	}
	
	@discardableResult public func onType<ErrorKind: Error>(
		_ errorKind: ErrorKind.Type,
		do action: @escaping Action
	) -> Self {
		return on(TypeErrorCategory<ErrorKind>(), do: action)
	}
	
	@discardableResult public func on<ErrorKind: Error & Equatable>(
		_ error: ErrorKind,
		do action: @escaping Action
	) -> Self {
		return on(matches: { $0 as? ErrorKind == error }, do: action)
	}
	
}
