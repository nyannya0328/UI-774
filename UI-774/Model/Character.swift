//
//  Character.swift
//  UI-774
//
//  Created by nyannyan0328 on 2022/10/20.
//

import SwiftUI

struct Character: Identifiable {
    var id = UUID().uuidString
    var color : Color = .clear
    var value : String = ""
    var index : Int = 0
    var rect : CGRect = .zero
}


