//
//  Card.swift
//  FlashZilla
//
//  Created by Kristoffer Eriksson on 2021-05-07.
//

import Foundation

struct Card : Codable{
    let prompt: String
    var answer: String
    
    static var example: Card {
        Card(prompt: "Who played the 13th doctor who", answer: "witticker")
    }
}
