//
//  Rutina.swift
//  GYMNESIA
//
//  Created by Khupier on 4/1/25.
//

import Foundation
import SwiftData

@Model
final class Rutina {
    var id: UUID
    var nombre: String
    var descripcion: String
    var ejercicios: [EjercicioEnRutina]
    var fechaCreacion: Date?
    var fechaProgramada: Date?
    var recurrenciaType: RecurrenciaType
    var diasRecurrencia: [Int]
    
    init(id: UUID = UUID(),
         nombre: String,
         descripcion: String = "",
         ejercicios: [EjercicioEnRutina] = [],
         fechaCreacion: Date? = nil,
         fechaProgramada: Date? = nil,
         recurrenciaType: RecurrenciaType = .ninguna,
         diasRecurrencia: [Int] = []) {
        self.id = id
        self.nombre = nombre
        self.descripcion = descripcion
        self.ejercicios = ejercicios
        self.fechaCreacion = fechaCreacion
        self.fechaProgramada = fechaProgramada
        self.recurrenciaType = recurrenciaType
        self.diasRecurrencia = diasRecurrencia
    }
}


