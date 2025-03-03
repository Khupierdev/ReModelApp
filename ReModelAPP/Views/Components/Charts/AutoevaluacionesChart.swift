//
//  AutoevaluacionesChart.swift
//  ReModel
//
//  Created by Khupier on 13/1/25.
//


import SwiftUI
import Charts

struct AutoevaluacionesChart: View {
    let autoevaluaciones: [Autoevaluacion]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Autoevaluaciones del Mes")
                .font(.headline)
            
            if !autoevaluaciones.isEmpty {
                Chart {
                    ForEach(autoevaluaciones) { evaluacion in
                        LineMark(
                            x: .value("Fecha", evaluacion.fecha),
                            y: .value("Energía", evaluacion.energia),
                            series: .value("Métrica", "Energía")
                        )
                        .foregroundStyle(.blue)
                        
                        LineMark(
                            x: .value("Fecha", evaluacion.fecha),
                            y: .value("Motivación", evaluacion.motivacion),
                            series: .value("Métrica", "Motivación")
                        )
                        .foregroundStyle(.green)
                        
                        LineMark(
                            x: .value("Fecha", evaluacion.fecha),
                            y: .value("Dolor", evaluacion.dolor),
                            series: .value("Métrica", "Dolor")
                        )
                        .foregroundStyle(.red)
                        
                        LineMark(
                            x: .value("Fecha", evaluacion.fecha),
                            y: .value("Cansancio", evaluacion.cansancio),
                            series: .value("Métrica", "Cansancio")
                        )
                        .foregroundStyle(.orange)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if value.as(Date.self) != nil {
                            AxisValueLabel(format: .dateTime.day())
                        }
                    }
                }
            } else {
                Text("No hay datos de autoevaluación este mes")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}


