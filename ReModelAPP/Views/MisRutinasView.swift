//
//  MisRutinasView.swift
//  GYMNESIA
//
//  Created by Khupier on 4/1/25.
//

import SwiftUI
import SwiftData

struct MisRutinasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rutinas: [Rutina]
    @State private var showingCrearRutina = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Mis Rutinas")) {
                    ForEach(rutinas) { rutina in
                        RutinaRow(rutina: rutina)
                    }
                    .onDelete(perform: deleteRutinas)
                }
                
                Section(header: Text("Herramientas")) {
                    NavigationLink(destination: CreatinaCalculadoraView()) {
                        Label("Calculadora de Creatina", systemImage: "function")
                    }
                    NavigationLink(destination: ProteinaCalculadoraView()) {
                        Label("Calculadora de Proteína", systemImage: "scalemass")
                    }
                    NavigationLink(destination: CronometroView()) {
                        Label("Cronómetro", systemImage: "stopwatch")
                    }
                }
            }
            .navigationTitle("Mis Rutinas y Herramientas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCrearRutina = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCrearRutina) {
                CrearRutinaView()
            }
        }
    }
    
    private func deleteRutinas(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(rutinas[index])
        }
    }
}

// Break down the complex view into smaller components
struct RutinasList: View {
    @Environment(\.modelContext) private var modelContext
    let rutinas: [Rutina]
    
    var body: some View {
        List {
            ForEach(rutinas) { rutina in
                RutinaRow(rutina: rutina)
            }
            .onDelete(perform: deleteRutinas)
        }
    }
    
    private func deleteRutinas(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(rutinas[index])
        }
    }
}

struct RutinaRow: View {
    let rutina: Rutina
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationLink(destination: DetalleRutinaView(rutina: rutina)) {
            VStack(alignment: .leading) {
                Text(rutina.nombre)
                    .font(.headline)
                Text("Ejercicios: \(rutina.ejercicios.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let fecha = rutina.fechaCreacion {
                    Text("Creada: \(fecha, formatter: itemFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Rutina.self, configurations: config)
    return MisRutinasView()
        .modelContainer(container)
}


