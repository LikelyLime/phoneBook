//
//  NewImageResponse.swift
//  phoneBook
//
//  Created by 백시훈 on 7/15/24.
//

import Foundation
struct NewImageResponse: Codable{
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites
}

struct Sprites: Codable{
    let frontDefault: String
    
    enum CodingKeys: String, CodingKey{
        case frontDefault = "front_default"
    }
}
