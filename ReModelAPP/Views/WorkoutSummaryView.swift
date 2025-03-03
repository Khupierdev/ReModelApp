//
//  WorkoutSummaryView.swift
//  ReModel
//
//  Created by Khupier on 10/1/25.
//


import SwiftUI
import Charts

struct WorkoutSummaryView: View {
    let rutina: Rutina
    let metrics: WorkoutMetrics
    let onFinish: () -> Void // Added parameter
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Resumen General
                SummaryCard(title: "Resumen General") {
                    VStack(alignment: .leading, spacing: 12) {
                        MetricRow(title: "Duración Total",
                                value: formatDuration(metrics.duracionTotal))
                        MetricRow(title: "Calorías Quemadas Total",
                                value: String(format: "%.0f kcal", metrics.caloriasQuemadas))
                        RatingView(title: "Dificultad Percibida",
                                 rating: metrics.dificultadPercibida)
                        RatingView(title: "Rendimiento Percibido",
                                 rating: metrics.rendimientoPercibido)
                    }
                }
                
                // Progreso por Ejercicio
                SummaryCard(title: "Progreso por Ejercicio") {
                    VStack(spacing: 16) {
                        ForEach(metrics.ejerciciosCompletados, id: \.ejercicioId) { ejercicio in
                            if let ejercicioInfo = rutina.ejercicios.first(where: { $0.ejercicio.id == ejercicio.ejercicioId }) {
                                EjercicioProgressRow(
                                    nombre: ejercicioInfo.ejercicio.nombre,
                                    pesoInicial: ejercicio.pesoInicial,
                                    pesoFinal: ejercicio.pesoFinal,
                                    series: ejercicio.seriesCompletadas,
                                    repeticiones: ejercicio.repeticionesCompletadas,
                                    calorias: ejercicio.caloriasQuemadas
                                )
                            }
                        }
                    }
                }
                
                // Autoevaluación Mensual
                SummaryCard(title: "Autoevaluación Mensual") {
                    Chart {
                        ForEach(metrics.autoevaluaciones) { evaluacion in
                            BarMark(
                                x: .value("Métrica", "Energía"),
                                y: .value("Valor", evaluacion.energia)
                            )
                            BarMark(
                                x: .value("Métrica", "Motivación"),
                                y: .value("Valor", evaluacion.motivacion)
                            )
                            BarMark(
                                x: .value("Métrica", "Dolor"),
                                y: .value("Valor", evaluacion.dolor)
                            )
                            BarMark(
                                x: .value("Métrica", "Cansancio"),
                                y: .value("Valor", evaluacion.cansancio)
                            )
                        }
                    }
                    .frame(height: 200)
                }
                
                // Recomendaciones
                SummaryCard(title: "Recomendaciones") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(generateRecommendations(), id: \.self) { recommendation in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(userSettings.accentColor)
                                Text(recommendation)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                Button("Finalizar Entrenamiento") {
                    finalizarEntrenamiento()
                }
                .buttonStyle(.borderedProminent)
                .tint(userSettings.accentColor)
                .padding()
            }
            .padding()
        }
        .navigationTitle("Resumen del Entrenamiento")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        
        // Basado en la duración
        if metrics.duracionTotal < 1800 {
            recommendations.append("Considera aumentar la duración de tu entrenamiento para mejores resultados")
        }
        
        // Basado en la dificultad percibida
        if metrics.dificultadPercibida <= 2 {
            recommendations.append("El entrenamiento parece ser muy fácil. Considera aumentar los pesos o las repeticiones")
        } else if metrics.dificultadPercibida >= 4 {
            recommendations.append("El entrenamiento fue muy intenso. Asegúrate de descansar adecuadamente")
        }
        
        // Basado en el rendimiento
        if metrics.rendimientoPercibido <= 3 {
            recommendations.append("Para mejorar tu rendimiento, asegúrate de dormir bien y mantener una buena alimentación")
        }
        
        return recommendations
    }
    
    private func finalizarEntrenamiento() {
        onFinish() // Updated function
        dismiss()
    }
}

struct EjercicioProgressRow: View {
    let nombre: String
    let pesoInicial: Double
    let pesoFinal: Double
    let series: Int
    let repeticiones: Int
    let calorias: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(nombre)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Peso Inicial")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f kg", pesoInicial))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Peso Final")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f kg", pesoFinal))
                }
            }
            
            HStack {
                Text("\(series) series × \(repeticiones) repeticiones")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Calorías: \(String(format: "%.0f", calorias)) kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if pesoFinal > pesoInicial {
                Text("¡Mejora de \(String(format: "%.1f", pesoFinal - pesoInicial))kg! 🎉")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
