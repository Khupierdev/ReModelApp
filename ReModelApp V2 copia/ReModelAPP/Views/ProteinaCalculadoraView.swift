//
//  ProteinaCalculadoraView.swift
//  GYMNESIA
//
//  Created by Khupier on 4/1/25.
//


import SwiftUI

struct ProteinaCalculadoraView: View {
    @State private var peso: String = ""
    @State private var nivelActividad: Double = 1.2
    @State private var resultado: Double?
    
    let actividadOptions = [
        (1.2, "Sedentario"),
        (1.375, "Ligera actividad"),
        (1.55, "Actividad moderada"),
        (1.725, "Actividad intensa"),
        (1.9, "Actividad muy intensa")
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Datos personales")) {
                TextField("Peso (kg)", text: $peso)
                    .keyboardType(.decimalPad)
                
                Picker("Nivel de actividad", selection: $nivelActividad) {
                    ForEach(actividadOptions, id: \.0) { value, label in
                        Text(label).tag(value)
                    }
                }
            }
            
            Section {
                Button("Calcular") {
                    calcularProteina()
                }
            }
            
            if let resultado = resultado {
                Section(header: Text("Resultado")) {
                    Text("Consumo diario recomendado de proteína: \(String(format: "%.1f", resultado)) gramos")
                }
            }
        }
        .navigationTitle("Calculadora de Proteína")
    }
    
    func calcularProteina() {
        guard let pesoKg = Double(peso) else { return }
        
        // Fórmula basada en las recomendaciones de la Organización Mundial de la Salud (OMS)
        // y ajustada según el nivel de actividad física
        let proteinaBase = pesoKg * 0.8 // 0.8 g/kg es la recomendación base de la OMS
        resultado = proteinaBase * nivelActividad
    }
}

struct ProteinaCalculadoraView_Previews: PreviewProvider {
    static var previews: some View {
        ProteinaCalculadoraView()
    }
}

