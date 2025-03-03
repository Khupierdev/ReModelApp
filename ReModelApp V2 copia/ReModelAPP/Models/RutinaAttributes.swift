//
//  RutinaAttributes.swift
//  ReModel
//
//  Created by Khupier on 15/1/25.
//

import ActivityKit
import Foundation

struct RutinaAttributes: ActivityAttributes {
    public typealias ContentState = RutinaContentState
    
    var nombre: String
    var descripcion: String
    var totalEjercicios: Int
}

struct RutinaContentState: Codable, Hashable {
    var ejercicioActual: String
    var tiempoTranscurrido: TimeInterval
    var progreso: Double
    var series: Int
    var repeticiones: Int
}
