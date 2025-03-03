//
//  CrearRutinaView.swift
//  GYMNESIA
//
//  Created by Khupier on 8/1/25.
//


import SwiftUI
import SwiftData

struct CrearRutinaView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var nombreRutina = ""
    @State private var ejerciciosSeleccionados: [EjercicioEnRutina] = []
    @State private var showingEjerciciosPicker = false
    @State private var fechaProgramada: Date = Date()
    @State private var isProgramada = false
    @State private var recurrenciaType: RecurrenciaType = .ninguna
    @State private var diasSeleccionados: Set<Int> = []
    
    let diasSemana = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nombre de la Rutina")) {
                    TextField("Nombre", text: $nombreRutina)
                }
                
                Section(header: Text("Ejercicios")) {
                    ForEach(ejerciciosSeleccionados) { ejercicio in
                        Text(ejercicio.ejercicio.nombre)
                    }
                    .onDelete(perform: deleteEjercicio)
                    
                    Button("Añadir Ejercicio") {
                        showingEjerciciosPicker = true
                    }
                }
                
                Section(header: Text("Programar Rutina")) {
                    Toggle("Programar para una fecha", isOn: $isProgramada)
                    if isProgramada {
                        DatePicker("Fecha de inicio", selection: $fechaProgramada, displayedComponents: .date)
                        
                        Picker("Tipo de recurrencia", selection: $recurrenciaType) {
                            Text("Sin recurrencia").tag(RecurrenciaType.ninguna)
                            Text("Semanal").tag(RecurrenciaType.semanal)
                            Text("Mensual").tag(RecurrenciaType.mensual)
                            Text("Bimensual").tag(RecurrenciaType.bimensual)
                        }
                        
                        if recurrenciaType == .semanal {
                            ForEach(diasSemana.indices, id: \.self) { index in
                                Toggle(diasSemana[index], isOn: Binding(
                                    get: { diasSeleccionados.contains(index + 1) },
                                    set: { newValue in
                                        if newValue {
                                            diasSeleccionados.insert(index + 1)
                                        } else {
                                            diasSeleccionados.remove(index + 1)
                                        }
                                    }
                                ))
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
                }
            }
            .navigationTitle("Crear Rutina")
            .navigationBarItems(
                leading: Button("Cancelar") { dismiss() },
                trailing: Button("Guardar") {
                    guardarRutina()
                    dismiss()
                }.disabled(nombreRutina.isEmpty || ejerciciosSeleccionados.isEmpty)
            )
            .sheet(isPresented: $showingEjerciciosPicker) {
                EjerciciosPickerView(ejerciciosSeleccionados: $ejerciciosSeleccionados)
            }
        }
    }
    
    private func deleteEjercicio(at offsets: IndexSet) {
        ejerciciosSeleccionados.remove(atOffsets: offsets)
    }
    
    private func guardarRutina() {
        let nuevaRutina = Rutina(nombre: nombreRutina, fechaProgramada: isProgramada ? fechaProgramada : nil)
        nuevaRutina.ejercicios = ejerciciosSeleccionados
        nuevaRutina.recurrenciaType = recurrenciaType
        nuevaRutina.diasRecurrencia = Array(diasSeleccionados)
        modelContext.insert(nuevaRutina)
        
        do {
            try modelContext.save()
        } catch {
            print("Error al guardar la rutina: \(error.localizedDescription)")
        }
    }
}

struct EjerciciosPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var ejercicios: [Ejercicio]
    @Binding var ejerciciosSeleccionados: [EjercicioEnRutina]
    @State private var filtroZonaMusculares = "Todos"
    @State private var filtroMusculosEspecificos = "Todos"
    
    let zonasMusculares = ["Todos", "Superior", "Inferior", "Core"]
    let musculosEspecificos = ["Todos", "Pectorales", "Espalda", "Hombros", "Bíceps", "Tríceps", "Cuádriceps", "Isquiotibiales", "Glúteos", "Pantorrillas", "Abdominales", "Oblicuos"]
    
    var ejerciciosFiltrados: [Ejercicio] {
        ejercicios.filter { ejercicio in
            (filtroZonaMusculares == "Todos" || ejercicio.zonaMusculares.contains(filtroZonaMusculares)) &&
            (filtroMusculosEspecificos == "Todos" || ejercicio.musculosEspecificos.contains(filtroMusculosEspecificos))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Zona Muscular", selection: $filtroZonaMusculares) {
                    ForEach(zonasMusculares, id: \.self) { zona in
                        Text(zona)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Músculo Específico", selection: $filtroMusculosEspecificos) {
                    ForEach(musculosEspecificos, id: \.self) { musculo in
                        Text(musculo)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                List(ejerciciosFiltrados) { ejercicio in
                    Button(action: {
                        seleccionarEjercicio(ejercicio)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(ejercicio.nombre)
                                    .font(.headline)
                                Text(ejercicio.zonaMusculares.joined(separator: ", "))
                                    .font(.subheadline)
                                Text(ejercicio.musculosEspecificos.joined(separator: ", "))
                                    .font(.caption)
                            }
                            Spacer()
                            if ejerciciosSeleccionados.contains(where: { $0.ejercicio.id == ejercicio.id }) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar Ejercicios")
            .navigationBarItems(trailing: Button("Listo") { dismiss() })
        }
    }
    
    private func seleccionarEjercicio(_ ejercicio: Ejercicio) {
        if let index = ejerciciosSeleccionados.firstIndex(where: { $0.ejercicio.id == ejercicio.id }) {
            ejerciciosSeleccionados.remove(at: index)
        } else {
            let nuevoEjercicioEnRutina = EjercicioEnRutina(ejercicio: ejercicio, configuracion: ConfiguracionEjercicio())
            ejerciciosSeleccionados.append(nuevoEjercicioEnRutina)
        }
    }
}

struct CrearRutinaView_Previews: PreviewProvider {
    static var previews: some View {
        CrearRutinaView()
            .modelContainer(for: [Rutina.self, Ejercicio.self, EjercicioEnRutina.self], inMemory: true)
    }
}



