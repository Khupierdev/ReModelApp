//
//  Ejercicio.swift
//  GYMNESIA
//
//  Created by Khupier on 5/1/25.
//

import Foundation
import SwiftData

@Model
final class Ejercicio {
    @Attribute(.unique) var id: String
    var nombre: String
    var zonaMusculares: [String]
    var musculosEspecificos: [String]
    
    init(id: String = UUID().uuidString, nombre: String, zonaMusculares: [String], musculosEspecificos: [String]) {
        self.id = id
        self.nombre = nombre
        self.zonaMusculares = zonaMusculares
        self.musculosEspecificos = musculosEspecificos
    }
}
