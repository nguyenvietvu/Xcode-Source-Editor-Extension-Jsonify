//
//  FormatError.swift
//  Parser
//
//  Created by MrDev on 01/03/2022.
//

import Foundation

enum FormatError: String {
    case missingBracketOpen = "missing '{'"
    case missingBracketClose = "missing '}'"
    case missingSBracketOpen = "missing '['"
    case missingSBracketClose = "missing ']'"
    case missingBrackets = "missing '{}'"
    case parsingError = "//parsing json error"
}
