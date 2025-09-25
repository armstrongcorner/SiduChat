//
//  StringUtil.swift
//  SiduChat
//
//  Created by Armstrong Liu on 21/09/2025.
//

import Foundation

class StringUtil {
    static func extractParenthesisContent(from input: String) -> String? {
        if let range = input.range(of: #"(?<=\().*?(?=\))"#, options: .regularExpression) {
            return String(input[range])
        } else {
            return nil
        }
    }
}
