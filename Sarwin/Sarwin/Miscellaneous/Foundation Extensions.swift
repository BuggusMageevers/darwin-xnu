//
//  Foundation Extensions.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/7/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation


infix operator &~
extension UInt8 {
    static func &~ (lhs: UInt8, rhs: UInt8) -> UInt8 {
        return lhs & (~rhs)
    }
}
