//
//  FocusMode.swift
//  ReModel
//
//  Created by Khupier on 14/1/25.
//


import Foundation

struct FocusMode: Identifiable, Codable {
    let id: String
    let name: String
    let systemIdentifier: String
    var isSelected: Bool
    
    init(id: String = UUID().uuidString, name: String, systemIdentifier: String, isSelected: Bool = false) {
        self.id = id
        self.name = name
        self.systemIdentifier = systemIdentifier
        self.isSelected = isSelected
    }
}

