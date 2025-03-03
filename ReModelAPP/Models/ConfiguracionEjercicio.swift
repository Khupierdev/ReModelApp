//
//  ConfiguracionEjercicio.swift
//  GYMNESIA
//
//  Created by Khupier on 5/1/25.
//


import Foundation
import SwiftData

@Model
final class ConfiguracionEjercicio {
    var series: Int
    var repeticiones: Int
    var peso: Double
    var pesoUniforme: Bool
    var pesoPorSerie: [Double]
    
    init(series: Int = 3, repeticiones: Int = 10, peso: Double = 0, pesoUniforme: Bool = true) {
        self.series = series
        self.repeticiones = repeticiones
        self.peso = peso
        self.pesoUniforme = pesoUniforme
        self.pesoPorSerie = Array(repeating: peso, count: series)
    }
}
