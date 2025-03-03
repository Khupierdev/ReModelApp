//
//  DetalleRutinaView.swift
//  GYMNESIA
//
//  Created by Khupier on 8/1/25.
//

import SwiftUI
import SwiftData

struct DetalleRutinaView: View {
    @Bindable var rutina: Rutina
    @State private var showingAddEjercicio = false
    @State private var showingRutinaEnProgreso = false
    @State private var isEditingDate = false
    @State private var tempFechaProgramada: Date?
    @State private var isProgramada: Bool
    @State private var recurrenciaType: RecurrenciaType
    @State private var diasSeleccionados: Set<Int> = []
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.modelContext) private var modelContext
    
    init(rutina: Rutina) {
        self._rutina = Bindable(wrappedValue: rutina)
        _isProgramada = State(initialValue: rutina.fechaProgramada != nil)
        _tempFechaProgramada = State(initialValue: rutina.fechaProgramada)
        _recurrenciaType = State(initialValue: rutina.recurrenciaType)
        _diasSeleccionados = State(initialValue: Set(rutina.diasRecurrencia))
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Programación")) {
                    if !isEditingDate {
                        HStack {
                            VStack(alignment: .leading) {
                                if let fecha = rutina.fechaProgramada {
                                    Text(fecha, style: .date)
                                    Text(descripcionRecurrencia())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("No programada")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                isEditingDate = true
                                tempFechaProgramada = rutina.fechaProgramada ?? Date()
                            }) {
                                Image(systemName: "calendar.badge.plus")
                            }
                        }
                    } else {
                        Toggle("Programar rutina", isOn: $isProgramada)
                        if isProgramada {
                            DatePicker("Fecha de inicio", selection: Binding(
                                get: { tempFechaProgramada ?? Date() },
                                set: { tempFechaProgramada = $0 }
                            ), displayedComponents: .date)
                            
                            Picker("Tipo de recurrencia", selection: $recurrenciaType) {
                                Text("Sin recurrencia").tag(RecurrenciaType.ninguna)
                                Text("Semanal").tag(RecurrenciaType.semanal)
                                Text("Mensual").tag(RecurrenciaType.mensual)
                                Text("Bimensual").tag(RecurrenciaType.bimensual)
                            }
                            
                            if recurrenciaType == .semanal {
                                VStack(alignment: .leading) {
                                    Text("Repetir cada:")
                                    HStack {
                                        ForEach(0..<7) { day in
                                            Button(action: {
                                                toggleDay(day)
                                            }) {
                                                Text(String(Calendar.current.shortWeekdaySymbols[day].prefix(1)))
                                                    .padding(8)
                                                    .background(diasSeleccionados.contains(day) ? Color.blue : Color.gray.opacity(0.3))
                                                    .clipShape(Circle())
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            } else if recurrenciaType == .mensual || recurrenciaType == .bimensual {
                                Picker("Repetir el día", selection: Binding(
                                    get: { self.diasSeleccionados.first ?? 1 },
                                    set: { self.diasSeleccionados = [$0] }
                                )) {
                                    ForEach(1...31, id: \.self) { day in
                                        Text("\(day)").tag(day)
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Button("Guardar") {
                                guardarConfiguracion()
                            }
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button("Cancelar") {
                                cancelarEdicion()
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("Ejercicios")) {
                    ForEach(rutina.ejercicios) { ejercicioEnRutina in
                        NavigationLink(destination: DetalleEjercicioView(ejercicioEnRutina: Binding(
                            get: { ejercicioEnRutina },
                            set: { _ in }
                        ))) {
                            Text(ejercicioEnRutina.ejercicio.nombre)
                        }
                    }
                    .onMove(perform: moveEjercicios)
                    .onDelete(perform: deleteEjercicios)
                    
                    Button(action: { showingAddEjercicio = true }) {
                        Label("Añadir Ejercicio", systemImage: "plus.circle.fill")
                    }
                }
            }
            
            Button(action: {
                showingRutinaEnProgreso = true
            }) {
                Text("Iniciar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(userSettings.accentColor)
                    .cornerRadius(12)
            }
            .padding()
            .disabled(rutina.ejercicios.isEmpty)
        }
        .navigationTitle(rutina.nombre)
        .navigationBarItems(trailing: EditButton())
        .sheet(isPresented: $showingAddEjercicio) {
            AgregarEjercicioView(rutina: rutina)
        }
        .fullScreenCover(isPresented: $showingRutinaEnProgreso) {
            RutinaEnProgresoView(rutina: rutina)
        }
    }
    
    private func toggleDay(_ day: Int) {
        if diasSeleccionados.contains(day) {
            diasSeleccionados.remove(day)
        } else {
            diasSeleccionados.insert(day)
        }
    }
    
    private func guardarConfiguracion() {
        rutina.fechaProgramada = isProgramada ? tempFechaProgramada : nil
        rutina.recurrenciaType = recurrenciaType
        rutina.diasRecurrencia = Array(diasSeleccionados)
        
        do {
            try modelContext.save()
        } catch {
            print("Error al guardar la configuración: \(error.localizedDescription)")
        }
        
        isEditingDate = false
    }
    
    private func cancelarEdicion() {
        tempFechaProgramada = rutina.fechaProgramada
        isProgramada = rutina.fechaProgramada != nil
        recurrenciaType = rutina.recurrenciaType
        diasSeleccionados = Set(rutina.diasRecurrencia)
        isEditingDate = false
    }
    
    private func descripcionRecurrencia() -> String {
        switch rutina.recurrenciaType {
        case .ninguna:
            return "No se repite"
        case .semanal:
            let dias = rutina.diasRecurrencia.map { Calendar.current.shortWeekdaySymbols[$0] }
            return "Se repite cada: \(dias.joined(separator: ", "))"
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
    
    private func moveEjercicios(from source: IndexSet, to destination: Int) {
        rutina.ejercicios.move(fromOffsets: source, toOffset: destination)
    }
    
    private func deleteEjercicios(offsets: IndexSet) {
        withAnimation {
            rutina.ejercicios.remove(atOffsets: offsets)
        }
    }
}
