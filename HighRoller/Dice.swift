//
//  Dice.swift
//  HighRoller
//
//  Created by Jeffrey Williams on 5/2/20.
//  Copyright © 2020 Jeffrey Williams. All rights reserved.
//

import Foundation

struct Die: Identifiable, Hashable {
    let id = UUID()
    let sides: Int
    var value: Int {
        return Int.random(in: 1...sides)
    }
}
