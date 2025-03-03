//
//  CreatinaCalculadoraView.swift
//  GYMNESIA
//
//  Created by Khupier on 4/1/25.
//

import SwiftUI

struct CreatinaCalculadoraView: View {
    @State private var peso: String = ""
    @State private var fase: FaseCreatina = .carga
    @State private var resultado: (dosis: Double, agua: Double)?
    
    enum FaseCreatina: String, CaseIterable {
        case carga = "Fase de carga"
        case mantenimiento = "Fase de mantenimiento"
    }
    
    var body: some View {
        Form {
            Section(header: Text("Datos personales")) {
                TextField("Peso (kg)", text: $peso)
                    .keyboardType(.decimalPad)
                
                Picker("Fase", selection: $fase) {
                    ForEach(FaseCreatina.allCases, id: \.self) { fase in
                        Text(fase.rawValue).tag(fase)
                    }
                }
            }
            
            Section {
                Button("Calcular") {
                    calcularCreatina()
                }
            }
            
            if let resultado = resultado {
                Section(header: Text("Resultado")) {
                    Text("Dosis diaria de creatina: \(String(format: "%.1f", resultado.dosis)) gramos")
                    Text("Agua recomendada: \(String(format: "%.1f", resultado.agua)) ml")
                }
            }
        }
        .navigationTitle("Calculadora de Creatina")
    }
    
    func calcularCreatina() {
        guard let pesoKg = Double(peso) else { return }
        
        var dosisCreatina: Double
        var aguaRecomendada: Double
        
        switch fase {
        case .carga:
            // Fase de carga: 0.3 g/kg de peso corporal por día
            dosisCreatina = pesoKg * 0.3
            // Recomendación de agua: 1 gramo de creatina por cada 100 ml de agua
            aguaRecomendada = dosisCreatina * 100
        case .mantenimiento:
            // Fase de mantenimiento: 3-5 g por día, usaremos 4 g como promedio
            dosisCreatina = 4
            // Recomendación de agua: 1 gramo de creatina por cada 100 ml de agua
            aguaRecomendada = dosisCreatina * 100
        }
        
        resultado = (dosis: dosisCreatina, agua: aguaRecomendada)
    }
}

struct CreatinaCalculadoraView_Previews: PreviewProvider {
    static var previews: some View {
        CreatinaCalculadoraView()
    }
}

