//
//  EjercicioEnRutina.swift
//  GYMNESIA
//
//  Created by Khupier on 5/1/25.
//


import Foundation
import SwiftData

@Model
final class EjercicioEnRutina {
    var ejercicio: Ejercicio
    var configuracion: ConfiguracionEjercicio
    
    init(ejercicio: Ejercicio, configuracion: ConfiguracionEjercicio) {
        self.ejercicio = ejercicio
        self.configuracion = configuracion
    }
}
