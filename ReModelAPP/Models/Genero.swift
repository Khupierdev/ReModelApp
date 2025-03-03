//
//  Genero.swift
//  ReModel
//
//  Created by Khupier on 10/1/25.
//


import Foundation

enum Genero: String, Codable, CaseIterable {
    case masculino = "Masculino"
    case femenino = "Femenino"
    case otro = "Otro"
}

enum FrecuenciaEjercicio: String, Codable, CaseIterable {
    case sedentario = "Sedentario"
    case ligero = "Ejercicio ligero (1-3 días/semana)"
    case moderado = "Ejercicio moderado (3-5 días/semana)"
    case activo = "Muy activo (6-7 días/semana)"
    case intenso = "Ejercicio intenso diario"
}

