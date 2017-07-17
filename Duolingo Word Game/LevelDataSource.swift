//
//  LevelDataSource.swift
//  Duolingo Word Game
//
//  Created by Ashish Mishra on 7/12/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class LevelDataSource: NSObject {
    
    var source: String?
    var charGrid : [[String]]?
    var wordLocations : [String : Any]?
    var flattenedLetters : [Character] = [Character]()
    
     init(jsonString : String) {
        super.init()
        var componentDictionaryForCurrentJson = self.convertToDictionary(text: jsonString)!
        
        self.source = componentDictionaryForCurrentJson["word"] as? String
        let doubleDimensionalCharacterGrid = componentDictionaryForCurrentJson["character_grid"] as! [[String]]
        self.charGrid = doubleDimensionalCharacterGrid
        self.wordLocations = componentDictionaryForCurrentJson["word_locations"] as? [String : Any]
        self.flattenedLettersArray()
    }
    
    func flattenedLettersArray() {
        for aObject in self.charGrid! {
            let charArray = aObject
            for aChar in charArray {
                let  currentChar = Character(aChar)
                self.flattenedLetters.append(currentChar)
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
