//
//  AgregarEjercicioView.swift
//  GYMNESIA
//
//  Created by Khupier on 9/1/25.
//


import SwiftUI
import SwiftData

struct AgregarEjercicioView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var ejercicios: [Ejercicio]
    @Bindable var rutina: Rutina
    @State private var filtroZonaMusculares = "Todos"
    @State private var filtroMusculosEspecificos = "Todos"
    @State private var showingConfiguracion = false
    @State private var ejercicioSeleccionado: Ejercicio?
    
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
                // Filtros
                Picker("Zona Muscular", selection: $filtroZonaMusculares) {
                    ForEach(zonasMusculares, id: \.self) { zona in
                        Text(zona)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Picker("Músculo Específico", selection: $filtroMusculosEspecificos) {
                    ForEach(musculosEspecificos, id: \.self) { musculo in
                        Text(musculo)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)
                
                // Lista de ejercicios
                List(ejerciciosFiltrados) { ejercicio in
                    Button(action: {
                        ejercicioSeleccionado = ejercicio
                        showingConfiguracion = true
                    }) {
                        VStack(alignment: .leading) {
                            Text(ejercicio.nombre)
                                .font(.headline)
                            Text(ejercicio.zonaMusculares.joined(separator: ", "))
                                .font(.subheadline)
                            Text(ejercicio.musculosEspecificos.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Agregar Ejercicio")
            .navigationBarItems(trailing: Button("Cancelar") { dismiss() })
            .sheet(isPresented: $showingConfiguracion) {
                if let ejercicio = ejercicioSeleccionado {
                    ConfigurarEjercicioView(rutina: rutina, ejercicio: ejercicio, dismiss: dismiss)
                }
            }
        }
    }
}

struct ConfigurarEjercicioView: View {
    var rutina: Rutina
    var ejercicio: Ejercicio
    var dismiss: DismissAction
    
    @State private var series = 3
    @State private var repeticiones = 12
    @State private var peso: Double = 0
    @State private var pesoUniforme = true
    @State private var pesoPorSerie: [Double] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuración básica")) {
                    Stepper("Series: \(series)", value: $series, in: 1...10)
                    Stepper("Repeticiones: \(repeticiones)", value: $repeticiones, in: 1...30)
                    
                    Toggle("Peso uniforme", isOn: $pesoUniforme)
                    
                    if pesoUniforme {
                        HStack {
                            Text("Peso (kg)")
                            TextField("Peso", value: $peso, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    } else {
                        ForEach(0..<series, id: \.self) { index in
                            HStack {
                                Text("Peso serie \(index + 1) (kg)")
                                TextField("Peso", value: $pesoPorSerie[index], format: .number)
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Configurar Ejercicio")
            .navigationBarItems(
                leading: Button("Cancelar") { dismiss() },
                trailing: Button("Guardar") {
                    guardarEjercicio()
                    dismiss()
                }
            )
            .onAppear {
                // Inicializar pesoPorSerie si es necesario
                if pesoPorSerie.isEmpty {
                    pesoPorSerie = Array(repeating: 0.0, count: series)
                }
            }
        }
    }
    
    private func guardarEjercicio() {
        let configuracion = ConfiguracionEjercicio()
        configuracion.series = series
        configuracion.repeticiones = repeticiones
        configuracion.peso = peso
        configuracion.pesoUniforme = pesoUniforme
        if !pesoUniforme {
            configuracion.pesoPorSerie = pesoPorSerie
        }
        
        let ejercicioEnRutina = EjercicioEnRutina(ejercicio: ejercicio, configuracion: configuracion)
        rutina.ejercicios.append(ejercicioEnRutina)
    }
}

