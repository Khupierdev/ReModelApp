//
//  WorkoutMetrics.swift
//  ReModel
//
//  Created by Khupier on 10/1/25.
//

import Foundation
import SwiftData

struct WorkoutMetrics {
    var duracionTotal: TimeInterval
    var caloriasQuemadas: Double
    var dificultadPercibida: Int // 1-5
    var rendimientoPercibido: Int // 1-5
    var fecha: Date
    var rutinaId: String
    var ejerciciosCompletados: [EjercicioMetrics]
    var autoevaluaciones: [Autoevaluacion]
    
    init(duracionTotal: TimeInterval = 0,
         caloriasQuemadas: Double = 0,
         dificultadPercibida: Int = 3,
         rendimientoPercibido: Int = 3,
         fecha: Date = Date(),
         rutinaId: String,
         ejerciciosCompletados: [EjercicioMetrics] = [],
         autoevaluaciones: [Autoevaluacion] = []) {
        self.duracionTotal = duracionTotal
        self.caloriasQuemadas = caloriasQuemadas
        self.dificultadPercibida = dificultadPercibida
        self.rendimientoPercibido = rendimientoPercibido
        self.fecha = fecha
        self.rutinaId = rutinaId
        self.ejerciciosCompletados = ejerciciosCompletados
        self.autoevaluaciones = autoevaluaciones
    }
}

struct EjercicioMetrics {
    var ejercicioId: String
    var pesoInicial: Double
    var pesoFinal: Double
    var seriesCompletadas: Int
    var repeticionesCompletadas: Int
    var duracion: TimeInterval
    var caloriasQuemadas: Double
    
    var progresoPeso: Double {
        return pesoFinal - pesoInicial
    }
}
