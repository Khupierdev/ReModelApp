//
//  ProgressView.swift
//  ReModel
//
//  Created by Khupier on 10/1/25.
//

import SwiftUI
import SwiftData
import Charts
import HealthKit

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var healthKit: HealthKitManager
    @State private var selectedZonaMusculares = "Todos"
    @State private var showingHealthKitAuth = false
    @State private var showingError = false
    @Query(sort: \Rutina.fechaCreacion) private var rutinas: [Rutina]
    @Query private var users: [User]
    @Query(sort: \Autoevaluacion.fecha) private var autoevaluaciones: [Autoevaluacion]
    @State private var showOnboarding = false
    @State private var errorMessage: String = ""
    
    private var rutinasHoy: [Rutina] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return rutinas.filter { rutina in
            guard let fechaCreacion = rutina.fechaCreacion else { return false }
            return calendar.isDate(calendar.startOfDay(for: fechaCreacion), inSameDayAs: today)
        }
    }
    
    var body: some View {
        NavigationView {
            if let user = users.first {
                ScrollView {
                    VStack(spacing: 20) {
                        CondicionFisicaCard(user: user, onUserDeleted: {
                            showOnboarding = true
                        })
                        ProgresoZonaMuscularCard(selectedZona: $selectedZonaMusculares)
                        CaloriasQuemadasCard(rutinasHoy: rutinasHoy)
                        AutoevaluacionesChart(autoevaluaciones: autoevaluaciones.map { $0 })
                        CaloriasQuemadasChart()
                        IMCAnualChart(registros: user.historialPeso)
                    }
                    .padding()
                }
                .navigationTitle("Progreso")
                .onAppear {
                    checkHealthKitAuthorization()
                }
                .alert("Acceso a HealthKit", isPresented: $showingHealthKitAuth) {
                    Button("Autorizar") {
                        requestHealthKitAuthorization()
                    }
                    Button("Cancelar", role: .cancel) { }
                } message: {
                    Text("Para un mejor seguimiento de tu progreso, necesitamos acceso a tus datos de salud.")
                }
                .alert("Error", isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView { _ in
                        showOnboarding = false
                    }
                }
            } else {
                ContentUnavailableView("No se encontró ningún usuario",
                                       systemImage: "person.crop.circle.badge.exclamationmark",
                                       description: Text("Por favor, completa el proceso de registro"))
            }
        }
    }
    
    private func checkHealthKitAuthorization() {
        healthKit.checkAuthorizationStatus()
        if healthKit.authorizationStatus == .notDetermined {
            showingHealthKitAuth = true
        }
    }
    
    private func requestHealthKitAuthorization() {
        healthKit.requestAuthorization { success, error in
            DispatchQueue.main.async {
                if !success {
                    errorMessage = error?.localizedDescription ?? "Error desconocido al acceder a HealthKit"
                    showingError = true
                }
            }
        }
    }
}

struct CondicionFisicaCard: View {
    @Bindable var user: User
    @State private var isEditingAltura = false
    @State private var isEditingPeso = false
    @State private var tempAltura = ""
    @State private var tempPeso = ""
    var onUserDeleted: () -> Void
    
    private var imc: Double {
        let alturaEnMetros = user.altura / 100
        return user.peso / (alturaEnMetros * alturaEnMetros)
    }
    
    private var clasificacionIMC: (String, Color) {
        switch imc {
        case ..<18.5:
            return ("Bajo peso", .orange)
        case 18.5..<25:
            return ("Peso saludable", .green)
        case 25..<30:
            return ("Sobrepeso", .yellow)
        default:
            return ("Obesidad", .red)
        }
    }
    
    private var recomendaciones: String {
        switch clasificacionIMC.0 {
        case "Bajo peso":
            return "Considera aumentar tu ingesta calórica y realizar ejercicios de fuerza."
        case "Peso saludable":
            return "¡Mantén tus buenos hábitos! Continúa con tu rutina de ejercicio regular."
        case "Sobrepeso":
            return "Enfócate en ejercicio cardiovascular y una dieta equilibrada."
        default:
            return "Consulta con un profesional de la salud para un plan personalizado."
        }
    }
    
    private var nivelActividad: String {
        switch user.frecuenciaEjercicio {
        case .sedentario:
            return "Considera aumentar tu nivel de actividad física."
        case .ligero:
            return "Buen comienzo. Intenta aumentar gradualmente tu actividad."
        case .moderado:
            return "¡Excelente nivel de actividad! Mantén el ritmo."
        case .activo, .intenso:
            return "¡Nivel de actividad óptimo! Asegúrate de descansar adecuadamente."
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Condición Física")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink(destination: UserProfileView(user: user, onUserDeleted: onUserDeleted)) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("IMC")
                        .font(.headline)
                    Text(String(format: "%.1f", imc))
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Clasificación")
                        .font(.headline)
                    Text(clasificacionIMC.0)
                        .font(.title3)
                        .foregroundColor(clasificacionIMC.1)
                        .fontWeight(.semibold)
                }
            }
            
            HStack {
                editableDataItem(title: "Altura", value: String(format: "%.0f cm", user.altura), isEditing: $isEditingAltura, tempValue: $tempAltura) {
                    if let newAltura = Double(tempAltura) {
                        user.altura = newAltura
                    }
                    isEditingAltura = false
                }
                Divider()
                editableDataItem(title: "Peso", value: String(format: "%.1f kg", user.peso), isEditing: $isEditingPeso, tempValue: $tempPeso) {
                    if let newPeso = Double(tempPeso) {
                        user.peso = newPeso
                        user.historialPeso.append(RegistroPeso(peso: newPeso, fecha: Date()))
                    }
                    isEditingPeso = false
                }
                Divider()
                DataItem(title: "Actividad", value: user.frecuenciaEjercicio.rawValue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Recomendaciones")
                    .font(.headline)
                Text(recomendaciones)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(nivelActividad)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            EvolucionPesoChart(registros: user.historialPeso)
                .frame(height: 200)
                .padding(.top)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private func editableDataItem(title: String, value: String, isEditing: Binding<Bool>, tempValue: Binding<String>, onCommit: @escaping () -> Void) -> some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            if isEditing.wrappedValue {
                TextField("", text: tempValue, onCommit: onCommit)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
            } else {
                Text(value)
                    .font(.callout)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        tempValue.wrappedValue = value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        isEditing.wrappedValue = true
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProgresoZonaMuscularCard: View {
    @Binding var selectedZona: String
    @Query private var rutinas: [Rutina]
    let zonasMusculares = ["Todos", "Superior", "Inferior", "Core"]
    @State private var progressData: [ProgressData] = []
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Progreso por Zona Muscular")
                .font(.headline)
            
            Picker("Zona Muscular", selection: $selectedZona) {
                ForEach(zonasMusculares, id: \.self) { zona in
                    Text(zona).tag(zona)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedZona) { oldValue, newValue in
                calculateProgressData()
            }
            
            if !progressData.isEmpty {
                Chart {
                    ForEach(progressData) { item in
                        if let fecha = item.fecha {
                            LineMark(
                                x: .value("Fecha", fecha),
                                y: .value("Peso", item.peso)
                            )
                            .interpolationMethod(.catmullRom)
                            
                            PointMark(
                                x: .value("Fecha", fecha),
                                y: .value("Peso", item.peso)
                            )
                        }
                    }
                }
                .frame(height: 200)
            } else {
                Text("No hay datos suficientes para esta zona muscular")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .onAppear {
            calculateProgressData()
        }
    }
    
    private func calculateProgressData() {
        var data: [ProgressData] = []
        let calendar = Calendar.current
        let today = Date()
        guard let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) else { return }
        
        let rutinasCompletadas = rutinas.filter { rutina in
            guard let fecha = rutina.fechaCreacion else { return false }
            return fecha >= thirtyDaysAgo && fecha <= today
        }
        
        for rutina in rutinasCompletadas {
            let ejerciciosFiltrados = rutina.ejercicios.filter { ejercicio in
                if selectedZona == "Todos" {
                    return true
                }
                return ejercicio.ejercicio.zonaMusculares.contains(selectedZona)
            }
            
            if !ejerciciosFiltrados.isEmpty {
                let pesoPromedio = ejerciciosFiltrados.reduce(0.0) { sum, ejercicio in
                    sum + ejercicio.configuracion.peso
                } / Double(ejerciciosFiltrados.count)
                
                data.append(ProgressData(fecha: rutina.fechaCreacion, peso: pesoPromedio))
            }
        }
        
        progressData = data.sorted { ($0.fecha ?? Date.distantPast) < ($1.fecha ?? Date.distantPast) }
    }
}

struct CaloriasQuemadasChart: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @State private var caloriasData: [(fecha: Date, calorias: Double)] = []
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Calorías Quemadas (Mes Actual)")
                .font(.headline)
            
            if !caloriasData.isEmpty {
                Chart {
                    ForEach(caloriasData, id: \.fecha) { dato in
                        LineMark(
                            x: .value("Fecha", dato.fecha),
                            y: .value("Calorías", dato.calorias)
                        )
                        .foregroundStyle(.orange)
                        
                        PointMark(
                            x: .value("Fecha", dato.fecha),
                            y: .value("Calorías", dato.calorias)
                        )
                        .foregroundStyle(.orange)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
            } else {
                Text("No hay datos de calorías disponibles")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .onAppear {
            fetchCaloriasData()
        }
    }
    
    private func fetchCaloriasData() {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return
        }
        
        healthKitManager.fetchCaloriesBurned(from: startOfMonth, to: endOfMonth) { calorias, error in
            if let error = error {
                print("Error fetching calories: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.caloriasData = calorias ?? []
            }
        }
    }
}

struct IMCAnualChart: View {
    let registros: [RegistroPeso]
    
    var registrosPorMes: [(mes: Date, imc: Double)] {
        let calendar = Calendar.current
        let añoActual = calendar.component(.year, from: Date())
        
        return registros
            .filter { calendar.component(.year, from: $0.fecha) == añoActual }
            .reduce(into: [String: [Double]]()) { result, registro in
                let mes = calendar.date(from: calendar.dateComponents([.year, .month], from: registro.fecha))!
                result[mes.description, default: []].append(registro.peso)
            }
            .map { (mes, pesos) in
                let pesoPromedio = pesos.reduce(0, +) / Double(pesos.count)
                return (mes: Date(timeIntervalSince1970: TimeInterval(mes.hashValue)), imc: pesoPromedio)
            }
            .sorted { $0.mes < $1.mes }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Evolución Anual del IMC")
                .font(.headline)
            
            if !registrosPorMes.isEmpty {
                Chart {
                    ForEach(registrosPorMes, id: \.mes) { registro in
                        LineMark(
                            x: .value("Mes", registro.mes),
                            y: .value("IMC", registro.imc)
                        )
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Mes", registro.mes),
                            y: .value("IMC", registro.imc)
                        )
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) {
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
            } else {
                Text("No hay datos suficientes para mostrar la evolución anual")
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

struct CaloriasQuemadasCard: View {
    let rutinasHoy: [Rutina]
    @EnvironmentObject private var healthKit: HealthKitManager
    @State private var caloriasQuemadas: Double = 0
    @State private var pasos: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Actividad de Hoy")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Calorías")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f", caloriasQuemadas))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack {
                    Text("Pasos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f", pasos))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("pasos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !rutinasHoy.isEmpty {
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Rutinas Completadas Hoy")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(rutinasHoy) { rutina in
                        HStack {
                            Text(rutina.nombre)
                            Spacer()
                            Text("\(rutina.ejercicios.count) ejercicios")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .onAppear {
            fetchHealthData()
        }
    }
    
    private func fetchHealthData() {
        healthKit.fetchDailySteps { steps, error in
            if let error = error {
                print("Error fetching steps: \(error.localizedDescription)")
                return
            }
            if let steps = steps {
                self.pasos = steps
            }
        }
        
        // Calculate calories for today's workouts
        let totalCalorias = rutinasHoy.reduce(0.0) { total, rutina in
            // Assuming an average workout duration of 1 hour for this example
            total + healthKit.calculateCaloriesBurned(rutina: rutina, duration: 3600)
        }
        self.caloriasQuemadas = totalCalorias
    }
}

struct DataItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.callout)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EvolucionPesoChart: View {
    let registros: [RegistroPeso]
    
    var body: some View {
        VStack {
            Text("Evolución del Peso")
                .font(.headline)
                .padding(.bottom, 8)
            
            Chart {
                ForEach(registros.sorted(by: { $0.fecha < $1.fecha }), id: \.fecha) { registro in
                    LineMark(
                        x: .value("Fecha", registro.fecha),
                        y: .value("Peso", registro.peso)
                    )
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Fecha", registro.fecha),
                        y: .value("Peso", registro.peso)
                    )
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, configurations: config)
    let user = User(nombre: "Test", apellidos: "User", fechaNacimiento: Date())
    container.mainContext.insert(user)
    return ProgressView()
        .modelContainer(container)
        .environmentObject(HealthKitManager.shared)
}
