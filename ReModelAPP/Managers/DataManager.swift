//
//  DataManager.swift
//  ReModel
//
//  Created by Khupier on 17/1/25.
//


//
//  DataManager.swift
//  ReModel
//
//  Created by Khupier on 17/1/25.
//

import SwiftData
import Foundation

class DataManager {
    static func seedInitialData(modelContext: ModelContext) {
        // Check if we already have data
        let userDescriptor = FetchDescriptor<User>()
        let ejerciciosDescriptor = FetchDescriptor<Ejercicio>()
        
        guard (try? modelContext.fetch(userDescriptor))?.isEmpty ?? true ||
              (try? modelContext.fetch(ejerciciosDescriptor))?.isEmpty ?? true else {
            return
        }
        
        // Seed ejercicios
        let ejercicios: [Ejercicio] = [
            Ejercicio(nombre: "Press de Banca", 
                     zonaMusculares: ["Superior"], 
                     musculosEspecificos: ["Pectorales", "Tríceps", "Hombros"]),
            Ejercicio(nombre: "Sentadillas", 
                     zonaMusculares: ["Inferior"], 
                     musculosEspecificos: ["Cuádriceps", "Glúteos", "Isquiotibiales"]),
            Ejercicio(nombre: "Peso Muerto", 
                     zonaMusculares: ["Inferior", "Core"], 
                     musculosEspecificos: ["Espalda baja", "Isquiotibiales", "Glúteos"]),
            Ejercicio(nombre: "Dominadas", 
                     zonaMusculares: ["Superior"], 
                     musculosEspecificos: ["Espalda", "Bíceps"]),
            Ejercicio(nombre: "Plancha", 
                     zonaMusculares: ["Core"], 
                     musculosEspecificos: ["Abdominales", "Oblicuos"])
        ]
        
        for ejercicio in ejercicios {
            modelContext.insert(ejercicio)
        }
        
        try? modelContext.save()
    }
}

