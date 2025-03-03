//
//  ReModelApp.swift
//  ReModel
//
//  Created by Khupier on 4/1/25.
//

import SwiftUI
import SwiftData
import ActivityKit

@main
struct ReModelApp: App {
    @StateObject private var userSettings = UserSettings()
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var focusModeManager = FocusModeManager.shared
    @StateObject private var dynamicIslandManager = DynamicIslandManager.shared
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                User.self,
                AdultoResponsable.self,
                Rutina.self,
                Ejercicio.self,
                ConfiguracionEjercicio.self,
                EjercicioEnRutina.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // Seed initial data
            DataManager.seedInitialData(modelContext: modelContainer.mainContext)
            
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSettings)
                .environmentObject(healthKitManager)
                .environmentObject(focusModeManager)
                .environmentObject(dynamicIslandManager)
        }
        .modelContainer(modelContainer)
    }
}



func generarEjercicios() -> [Ejercicio] {
    return [
        Ejercicio(nombre: "Sentadillas", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Flexiones", zonaMusculares: ["Superior"], musculosEspecificos: ["Pectorales", "Tríceps"]),
        Ejercicio(nombre: "Plancha", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales", "Lumbares"]),
        Ejercicio(nombre: "Peso muerto", zonaMusculares: ["Inferior"], musculosEspecificos: ["Isquiotibiales", "Espalda baja"]),
        Ejercicio(nombre: "Press de banca", zonaMusculares: ["Superior"], musculosEspecificos: ["Pectorales", "Tríceps"]),
        Ejercicio(nombre: "Dominadas", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Bíceps"]),
        Ejercicio(nombre: "Zancadas", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Elevaciones laterales", zonaMusculares: ["Superior"], musculosEspecificos: ["Deltoides laterales"]),
        Ejercicio(nombre: "Crunch abdominal", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales"]),
        Ejercicio(nombre: "Remo con barra", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Trapecios"]),
        Ejercicio(nombre: "Hip thrust", zonaMusculares: ["Inferior"], musculosEspecificos: ["Glúteos", "Isquiotibiales"]),
        Ejercicio(nombre: "Fondos en paralelas", zonaMusculares: ["Superior"], musculosEspecificos: ["Tríceps", "Pectorales"]),
        Ejercicio(nombre: "Puente de glúteos", zonaMusculares: ["Inferior"], musculosEspecificos: ["Glúteos", "Lumbares"]),
        Ejercicio(nombre: "Curl de bíceps", zonaMusculares: ["Superior"], musculosEspecificos: ["Bíceps"]),
        Ejercicio(nombre: "Extensiones de tríceps", zonaMusculares: ["Superior"], musculosEspecificos: ["Tríceps"]),
        Ejercicio(nombre: "Mountain climbers", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales", "Cuádriceps"]),
        Ejercicio(nombre: "Elevación de gemelos", zonaMusculares: ["Inferior"], musculosEspecificos: ["Gemelos"]),
        Ejercicio(nombre: "Press militar", zonaMusculares: ["Superior"], musculosEspecificos: ["Deltoides", "Tríceps"]),
        Ejercicio(nombre: "Burpees", zonaMusculares: ["Full Body"], musculosEspecificos: ["Pectorales", "Cuádriceps", "Abdominales"]),
        Ejercicio(nombre: "Remo en máquina", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Trapecios"]),
        Ejercicio(nombre: "Prensa de piernas", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Elevaciones frontales", zonaMusculares: ["Superior"], musculosEspecificos: ["Deltoides frontales"]),
        Ejercicio(nombre: "Ab wheel rollout", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales"]),
        Ejercicio(nombre: "Face pulls", zonaMusculares: ["Superior"], musculosEspecificos: ["Deltoides posteriores", "Trapecios"]),
        Ejercicio(nombre: "Dominadas asistidas", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Bíceps"]),
        Ejercicio(nombre: "Farmer's walk", zonaMusculares: ["Full Body"], musculosEspecificos: ["Trapecios", "Antebrazos", "Core"]),
        Ejercicio(nombre: "Step-ups", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Rotaciones rusas", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales oblicuos"]),
        Ejercicio(nombre: "Flexiones inclinadas", zonaMusculares: ["Superior"], musculosEspecificos: ["Pectorales superiores", "Tríceps"]),
        Ejercicio(nombre: "Press inclinado con mancuernas", zonaMusculares: ["Superior"], musculosEspecificos: ["Pectorales", "Tríceps"]),
        Ejercicio(nombre: "Goblet squat", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Press de hombros con mancuernas", zonaMusculares: ["Superior"], musculosEspecificos: ["Deltoides", "Tríceps"]),
        Ejercicio(nombre: "Dragon flags", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales", "Lumbares"]),
        Ejercicio(nombre: "Remo con polea baja", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Bíceps"]),
        Ejercicio(nombre: "Curl de martillo", zonaMusculares: ["Superior"], musculosEspecificos: ["Bíceps", "Antebrazos"]),
        Ejercicio(nombre: "Pull-through", zonaMusculares: ["Inferior"], musculosEspecificos: ["Glúteos", "Lumbares"]),
        Ejercicio(nombre: "Sprint en cinta", zonaMusculares: ["Cardio"], musculosEspecificos: ["Cuádriceps", "Gemelos"]),
        Ejercicio(nombre: "Jalón al pecho", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Bíceps"]),
        Ejercicio(nombre: "Extensión de piernas", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps"]),
        Ejercicio(nombre: "Plancha lateral", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales oblicuos", "Lumbares"]),
        Ejercicio(nombre: "Levantamiento turco", zonaMusculares: ["Full Body"], musculosEspecificos: ["Hombros", "Core"]),
        Ejercicio(nombre: "Press de pecho con máquina", zonaMusculares: ["Superior"], musculosEspecificos: ["Pectorales", "Tríceps"]),
        Ejercicio(nombre: "Sentadilla búlgara", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Battle ropes", zonaMusculares: ["Full Body"], musculosEspecificos: ["Hombros", "Core", "Cardio"]),
        Ejercicio(nombre: "Remo invertido", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Trapecios"]),
        Ejercicio(nombre: "Press Arnold", zonaMusculares: ["Superior"], musculosEspecificos: ["Deltoides", "Tríceps"]),
        Ejercicio(nombre: "Good mornings", zonaMusculares: ["Inferior"], musculosEspecificos: ["Lumbares", "Isquiotibiales"]),
        Ejercicio(nombre: "Skipping", zonaMusculares: ["Cardio"], musculosEspecificos: ["Gemelos", "Cuádriceps"]),
        Ejercicio(nombre: "Flexiones diamante", zonaMusculares: ["Superior"], musculosEspecificos: ["Tríceps", "Pectorales"]),
        Ejercicio(nombre: "Cable crunch", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales"]),
        Ejercicio(nombre: "Extensión de espalda", zonaMusculares: ["Core"], musculosEspecificos: ["Lumbares"]),
        Ejercicio(nombre: "Encogimientos de hombros", zonaMusculares: ["Superior"], musculosEspecificos: ["Trapecios"]),
        Ejercicio(nombre: "Jump squats", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Flexiones declinadas", zonaMusculares: ["Superior"], musculosEspecificos: ["Pectorales inferiores", "Tríceps"]),
        Ejercicio(nombre: "Saltos al cajón", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "V-ups", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales"]),
        Ejercicio(nombre: "Remo con mancuerna", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Trapecios"]),
        Ejercicio(nombre: "Overhead squat", zonaMusculares: ["Full Body"], musculosEspecificos: ["Cuádriceps", "Deltoides"]),
        Ejercicio(nombre: "Bicicleta abdominal", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales oblicuos"]),
        Ejercicio(nombre: "Flexiones arqueras", zonaMusculares: ["Superior"], musculosEspecificos: ["Pectorales", "Tríceps"]),
        Ejercicio(nombre: "Peso muerto rumano", zonaMusculares: ["Inferior"], musculosEspecificos: ["Isquiotibiales", "Glúteos"]),
        Ejercicio(nombre: "Lunge lateral", zonaMusculares: ["Inferior"], musculosEspecificos: ["Aductores", "Glúteos"]),
        Ejercicio(nombre: "Clean and press", zonaMusculares: ["Full Body"], musculosEspecificos: ["Hombros", "Piernas"]),
        Ejercicio(nombre: "Plancha con elevación de brazo", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales", "Deltoides"]),
        Ejercicio(nombre: "Pull-up grip neutral", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Bíceps"]),
        Ejercicio(nombre: "Kickbacks de tríceps", zonaMusculares: ["Superior"], musculosEspecificos: ["Tríceps"]),
        Ejercicio(nombre: "Press inclinado en máquina", zonaMusculares: ["Superior"], musculosEspecificos: ["Pectorales superiores", "Tríceps"]),
        Ejercicio(nombre: "Squat hold", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Flutter kicks", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales"]),
        Ejercicio(nombre: "Jalón tras nuca", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Trapecios"]),
        Ejercicio(nombre: "Caminata lateral con banda", zonaMusculares: ["Inferior"], musculosEspecificos: ["Glúteos", "Cuádriceps"]),
        Ejercicio(nombre: "Press con kettlebell", zonaMusculares: ["Superior"], musculosEspecificos: ["Deltoides", "Tríceps"]),
        Ejercicio(nombre: "Bear crawl", zonaMusculares: ["Full Body"], musculosEspecificos: ["Hombros", "Core"]),
        Ejercicio(nombre: "Pike push-up", zonaMusculares: ["Superior"], musculosEspecificos: ["Deltoides", "Tríceps"]),
        Ejercicio(nombre: "Kettlebell swing", zonaMusculares: ["Full Body"], musculosEspecificos: ["Glúteos", "Hombros"]),
        Ejercicio(nombre: "Sentadilla con salto", zonaMusculares: ["Inferior"], musculosEspecificos: ["Cuádriceps", "Glúteos"]),
        Ejercicio(nombre: "Snatch con mancuerna", zonaMusculares: ["Full Body"], musculosEspecificos: ["Hombros", "Piernas"]),
        Ejercicio(nombre: "Plank jacks", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales"]),
        Ejercicio(nombre: "Remo con barra T", zonaMusculares: ["Superior"], musculosEspecificos: ["Dorsales", "Trapecios"]),
        Ejercicio(nombre: "Leg raises", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales"]),
        Ejercicio(nombre: "Salto estrella", zonaMusculares: ["Full Body"], musculosEspecificos: ["Hombros", "Cardio"]),
        Ejercicio(nombre: "Step lateral", zonaMusculares: ["Inferior"], musculosEspecificos: ["Aductores", "Cuádriceps"]),
        Ejercicio(nombre: "Remo renegado", zonaMusculares: ["Full Body"], musculosEspecificos: ["Dorsales", "Core"]),
        Ejercicio(nombre: "High knees", zonaMusculares: ["Cardio"], musculosEspecificos: ["Cuádriceps", "Core"]),
        Ejercicio(nombre: "Lateral plank walk", zonaMusculares: ["Core"], musculosEspecificos: ["Abdominales", "Deltoides"]),
        Ejercicio(nombre: "Russian kettlebell swing", zonaMusculares: ["Full Body"], musculosEspecificos: ["Glúteos", "Hombros"]),
    ]
}

