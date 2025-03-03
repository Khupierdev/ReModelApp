//
//  DetalleEjercicioView.swift
//  GYMNESIA
//
//  Created by Khupier on 5/1/25.
//


import SwiftUI

struct DetalleEjercicioView: View {
    @Binding var ejercicioEnRutina: EjercicioEnRutina
    @Environment(\.dismiss) private var dismiss
    
    @State private var series: Int
    @State private var repeticiones: Int
    @State private var peso: Double
    @State private var pesoUniforme: Bool
    
    init(ejercicioEnRutina: Binding<EjercicioEnRutina>) {
        self._ejercicioEnRutina = ejercicioEnRutina
        self._series = State(initialValue: ejercicioEnRutina.wrappedValue.configuracion.series)
        self._repeticiones = State(initialValue: ejercicioEnRutina.wrappedValue.configuracion.repeticiones)
        self._peso = State(initialValue: ejercicioEnRutina.wrappedValue.configuracion.peso)
        self._pesoUniforme = State(initialValue: ejercicioEnRutina.wrappedValue.configuracion.pesoUniforme)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del ejercicio")) {
                    Text(ejercicioEnRutina.ejercicio.nombre)
                        .font(.headline)
                    Text("Zona: \(ejercicioEnRutina.ejercicio.zonaMusculares.joined(separator: ", "))")
                    Text("Músculos: \(ejercicioEnRutina.ejercicio.musculosEspecificos.joined(separator: ", "))")
                }
                
                Section(header: Text("Configuración")) {
                    Stepper("Series: \(series)", value: $series, in: 1...10)
                    Stepper("Repeticiones: \(repeticiones)", value: $repeticiones, in: 1...30)
                    
                    Toggle("Peso uniforme", isOn: $pesoUniforme)
                    
                    if pesoUniforme {
                        HStack {
                            Text("Peso (kg):")
                            TextField("Peso", value: $peso, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                        }
                    } else {
                        ForEach(0..<series, id: \.self) { index in
                            HStack {
                                Text("Peso serie \(index + 1) (kg):")
                                TextField("Peso", value: Binding(
                                    get: { self.peso },
                                    set: { self.peso = $0 }
                                ), formatter: NumberFormatter())
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
                    guardarCambios()
                    dismiss()
                }
            )
        }
    }
    
    private func guardarCambios() {
        ejercicioEnRutina.configuracion.series = series
        ejercicioEnRutina.configuracion.repeticiones = repeticiones
        ejercicioEnRutina.configuracion.peso = peso
        ejercicioEnRutina.configuracion.pesoUniforme = pesoUniforme
    }
}
