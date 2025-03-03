//
//  AdultoResponsable.swift
//  ReModel
//
//  Created by Khupier on 10/1/25.
//


import Foundation
import SwiftData

@Model
final class AdultoResponsable {
    var nombre: String
    var apellidos: String
    var fechaNacimiento: Date
    
    init(nombre: String, apellidos: String, fechaNacimiento: Date) {
        self.nombre = nombre
        self.apellidos = apellidos
        self.fechaNacimiento = fechaNacimiento
    }
}

