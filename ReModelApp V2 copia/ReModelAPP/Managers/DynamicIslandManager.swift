//
//  DynamicIslandManager.swift
//  ReModel
//
//  Created by Khupier on 15/1/25.
//

import ActivityKit
import Foundation
import SwiftUI

@Observable
final class DynamicIslandManager: ObservableObject {
    // Singleton instance
    static let shared = DynamicIslandManager()
    
    // Private backing storage
    private var backingActivityID: String?
    private var backingCurrentActivity: Activity<RutinaAttributes>?
    
    // Public interface
    var activityID: String? {
        get { backingActivityID }
        set { backingActivityID = newValue }
    }
    
    var currentActivity: Activity<RutinaAttributes>? {
        get { backingCurrentActivity }
        set { backingCurrentActivity = newValue }
    }
    
    // Private initializer for singleton pattern
    private init() {}
    
    func startRutinaActivity(rutina: Rutina, ejercicioActual: EjercicioEnRutina) {
        let attributes = RutinaAttributes(
            nombre: rutina.nombre,
            descripcion: rutina.descripcion,
            totalEjercicios: rutina.ejercicios.count
        )
        
        let contentState = RutinaAttributes.ContentState(
            ejercicioActual: ejercicioActual.ejercicio.nombre,
            tiempoTranscurrido: 0,
            progreso: 0.0,
            series: 0,
            repeticiones: ejercicioActual.configuracion.repeticiones
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: contentState, staleDate: nil)
            )
            backingCurrentActivity = activity
            backingActivityID = activity.id
            objectWillChange.send()
        } catch {
            print("Error starting live activity: \(error.localizedDescription)")
        }
    }
    
    func updateRutinaActivity(tiempoTranscurrido: TimeInterval, ejercicioActual: EjercicioEnRutina, seriesCompletadas: Int) {
        guard let activity = currentActivity else { return }
        
        let contentState = RutinaAttributes.ContentState(
            ejercicioActual: ejercicioActual.ejercicio.nombre,
            tiempoTranscurrido: tiempoTranscurrido,
            progreso: Double(seriesCompletadas) / Double(ejercicioActual.configuracion.series),
            series: seriesCompletadas,
            repeticiones: ejercicioActual.configuracion.repeticiones
        )
        
        Task {
            await activity.update(ActivityContent(state: contentState, staleDate: nil))
        }
    }
    
    func endRutinaActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(
                ActivityContent(state: activity.content.state, staleDate: nil),
                dismissalPolicy: .immediate
            )
            await MainActor.run {
                backingActivityID = nil
                backingCurrentActivity = nil
                objectWillChange.send()
            }
        }
    }
}

