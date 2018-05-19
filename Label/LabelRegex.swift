//
//  LabelRegex.swift
//  Label
//
//  Created by Anthony Gordon on 09/12/2017.
//  Copyright © 2017 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import Foundation

// MARK: REGEX
/**
 Returns a regex for the property, this is currently used in the order confirmation screen.
 */
struct labelRegex {
    let name = Regex("^[a-zA-Z][0-9a-zA-Z .,'-]*$")
    let email = Regex("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
    let address = Regex("(?:[A-Z0-9][a-z0-9,.-]+[ ]?)+")
    let city = Regex("(?:[A-Z][a-z.-]+[ ]?)+")
    
    public func getRegexForCountry(country:String) -> Regex {
        switch country {
        case "United Kingdom":
            return Regex("([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z]))))\\s?[0-9][A-Za-z]{2})")
        case "United States":
            return Regex("^\\d{5}([\\-]?\\d{4})?$")
        case "Canada":
            return Regex("^[A-Za-z]\\d[A-Za-z][ -]?\\d[A-Za-z]\\d$")
        default:
            return Regex(".*")
        }
    }
    
    let password: Regex! = Regex("^(((?=.*[a-z])(?=.*[A-Z]))((?=.*[a-z])(?=.*[0-9])))(?=.{6,})") // 1 UPPERCASE - 6 CHARACTERS - 1 NUMBER VALIDATION
    
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
