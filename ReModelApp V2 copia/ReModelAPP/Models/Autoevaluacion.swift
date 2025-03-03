//
//  Autoevaluacion.swift
//  ReModel
//
//  Created by Khupier on 13/1/25.
//

import Foundation
import SwiftData

@Model
final class Autoevaluacion {
    var id: UUID
    var fecha: Date
    var energia: Int // 1-5
    var motivacion: Int // 1-5
    var dolor: Int // 1-5
    var cansancio: Int // 1-5
    
    init(id: UUID = UUID(), fecha: Date = Date(), energia: Int, motivacion: Int, dolor: Int, cansancio: Int) {
        self.id = id
        self.fecha = fecha
        self.energia = energia
        self.motivacion = motivacion
        self.dolor = dolor
        self.cansancio = cansancio
    }
}
