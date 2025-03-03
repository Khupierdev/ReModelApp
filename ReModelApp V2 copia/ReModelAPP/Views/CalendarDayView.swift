//
//  CalendarDayView.swift
//  ReModel
//
//  Created by Khupier on 10/1/25.
//

import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let rutinas: [Rutina]
    @State private var selectedRutina: Rutina?
    @State private var showingDetalleRutina = false
    
    private let diasSemana = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(date, style: .date)) {
                    if rutinas.isEmpty {
                        Text("No hay rutinas programadas para este día")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(rutinas) { rutina in
                            Button(action: {
                                selectedRutina = rutina
                                showingDetalleRutina = true
                            }) {
                                VStack(alignment: .leading) {
                                    Text(rutina.nombre)
                                        .font(.headline)
                                    Text("\(rutina.ejercicios.count) ejercicios")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(descripcionRecurrencia(rutina))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rutinas del día")
            .sheet(item: $selectedRutina) { rutina in
                NavigationView {
                    DetalleRutinaView(rutina: rutina)
                }
            }
        }
    }
    
    private func descripcionRecurrencia(_ rutina: Rutina) -> String {
        switch rutina.recurrenciaType {
        case .ninguna:
            return "No se repite"
        case .semanal:
            let dias = rutina.diasRecurrencia.map { diasSemana[$0 - 1] }.joined(separator: ", ")
            return "Se repite cada: \(dias)"
        case .mensual:
            if let dia = rutina.diasRecurrencia.first {
                return "Se repite el día \(dia) de cada mes"
            }
            return "Se repite mensualmente"
        case .bimensual:
            if let dia = rutina.diasRecurrencia.first {
                return "Se repite el día \(dia) cada dos meses"
            }
            return "Se repite cada dos meses"
        }
    }
}

