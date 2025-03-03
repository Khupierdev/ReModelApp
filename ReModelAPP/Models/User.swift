//
//  User.swift
//  GYMNESIA
//
//  Created by Khupier on 6/1/25.
//

import Foundation
import SwiftData

@Model
final class User {
    var nombre: String
    var apellidos: String
    var fechaNacimiento: Date
    var esMenorDeEdad: Bool
    var adultoResponsable: AdultoResponsable?
    var imagenPerfil: Data?
    
    var altura: Double // en centímetros
    var peso: Double // en kilogramos
    var genero: Genero
    var frecuenciaEjercicio: FrecuenciaEjercicio
    var historialPeso: [RegistroPeso]
    
    init(nombre: String,
         apellidos: String,
         fechaNacimiento: Date,
         altura: Double = 170,
         peso: Double = 70,
         genero: Genero = .otro,
         frecuenciaEjercicio: FrecuenciaEjercicio = .sedentario) {
        self.nombre = nombre
        self.apellidos = apellidos
        self.fechaNacimiento = fechaNacimiento
        self.esMenorDeEdad = User.calcularEdad(fechaNacimiento: fechaNacimiento) < 16
        self.adultoResponsable = nil
        self.imagenPerfil = nil
        self.altura = altura
        self.peso = peso
        self.genero = genero
        self.frecuenciaEjercicio = frecuenciaEjercicio
        self.historialPeso = [RegistroPeso(peso: peso, fecha: Date())]
    }
    
    static func calcularEdad(fechaNacimiento: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: fechaNacimiento, to: Date())
        return ageComponents.year ?? 0
    }
}

@Model
final class RegistroPeso {
    var peso: Double
    var fecha: Date
    
    init(peso: Double, fecha: Date) {
        self.peso = peso
        self.fecha = fecha
    }
}


