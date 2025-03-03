//
//  MainMenuView.swift
//  ReModel
//
//  Created by Khupier on 14/1/25.
//

import SwiftUI
import SwiftData

struct MainMenuView: View {
    @StateObject private var focusModeManager = FocusModeManager.shared
    @EnvironmentObject var userSettings: UserSettings
    @Query private var rutinas: [Rutina]
    @State private var showingFocusModeAlert = false
    @State private var currentDate = Date()
    @State private var selectedDate = Date()
    @State private var showingDayView = false
    @State private var timer: Timer?
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
    
    private var month: Date {
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        return calendar.date(from: components) ?? selectedDate
    }
    
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDates(for: dateInterval)
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Fecha y hora
                    VStack(alignment: .leading, spacing: 5) {
                        Text(dateFormatter.string(from: currentDate))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue) // Updated color
                        
                        Text(timeFormatter.string(from: currentDate))
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(userSettings.accentColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Rutinas del día
                    DailyRoutinesCard(rutinas: rutinasForDate(currentDate))
                    
                    // Resumen de rendimiento
                    PerformanceSummaryCard()
                    
                    // IMC
                    BMICard()
                    
                    // Botón de modo concentración
                    Button(action: {
                        withAnimation { // Added animation
                            activateFocusMode()
                        }
                    }) {
                        HStack {
                            Image(systemName: "moon.stars.fill")
                            Text("Activar modo concentración")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(userSettings.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                    
                    // Calendario
                    VStack(spacing: 20) {
                        HStack {
                            Button(action: {
                                withAnimation { // Added animation
                                    previousMonth()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            
                            Text(month, formatter: monthFormatter)
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                withAnimation { // Added animation
                                    nextMonth()
                                }
                            }) {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            ForEach(daysInWeek, id: \.self) { day in
                                Text(day)
                                    .frame(maxWidth: .infinity)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                            ForEach(days, id: \.self) { date in
                                DayView(date: date,
                                       isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                       isCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month),
                                       rutinas: rutinasForDate(date))
                                    .onTapGesture {
                                        withAnimation { // Added animation
                                            selectedDate = date
                                            showingDayView = true
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
            }
            .navigationTitle("Principal")
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .sheet(isPresented: $showingDayView) {
                CalendarDayView(date: selectedDate, rutinas: rutinasForDate(selectedDate))
            }
            .alert("Modo concentración activado", isPresented: $showingFocusModeAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentDate = Date()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func activateFocusMode() {
        if let selectedModeId = userSettings.selectedFocusModeId,
           let selectedMode = focusModeManager.availableFocusModes.first(where: { $0.id == selectedModeId }) {
            focusModeManager.activateFocusMode(selectedMode)
            showingFocusModeAlert = true
        }
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func rutinasForDate(_ date: Date) -> [Rutina] {
        rutinas.filter { rutina in
            if let fechaProgramada = rutina.fechaProgramada {
                switch rutina.recurrenciaType {
                case .ninguna:
                    return calendar.isDate(fechaProgramada, inSameDayAs: date)
                case .semanal:
                    let weekday = (calendar.component(.weekday, from: date) + 5) % 7 + 1 // 1-7, Lunes-Domingo
                    return rutina.diasRecurrencia.contains(weekday) &&
                    (fechaProgramada <= date || calendar.isDate(fechaProgramada, inSameDayAs: date))
                case .mensual:
                    let dayOfMonth = calendar.component(.day, from: date)
                    return rutina.diasRecurrencia.contains(dayOfMonth) &&
                    (fechaProgramada <= date || calendar.isDate(fechaProgramada, inSameDayAs: date))
                case .bimensual:
                    let dayOfMonth = calendar.component(.day, from: date)
                    let monthDifference = calendar.dateComponents([.month], from: fechaProgramada, to: date).month ?? 0
                    return rutina.diasRecurrencia.contains(dayOfMonth) &&
                    (fechaProgramada <= date || calendar.isDate(fechaProgramada, inSameDayAs: date)) &&
                    monthDifference % 2 == 0
                }
            }
            return false
        }
    }
}

private struct DayView: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let rutinas: [Rutina]
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
            
            VStack {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16))
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isCurrentMonth ? .primary : .secondary)
                
                if !rutinas.isEmpty {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(height: 45)
    }
}

struct DailyRoutinesCard: View {
    let rutinas: [Rutina]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Rutinas de hoy")
                .font(.title3)
                .fontWeight(.bold)
            
            if rutinas.isEmpty {
                Text("No hay rutinas programadas para hoy")
                    .foregroundColor(.secondary)
            } else {
                ForEach(rutinas) { rutina in
                    NavigationLink(destination: DetalleRutinaView(rutina: rutina)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(rutina.nombre)
                                    .font(.headline)
                                Text("\(rutina.ejercicios.count) ejercicios")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct PerformanceSummaryCard: View {
    @Query private var rutinas: [Rutina]
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    private var totalRutinas: Int {
        rutinas.count
    }
    
    private var totalEjercicios: Int {
        rutinas.reduce(0) { $0 + $1.ejercicios.count }
    }
    
    private var totalTiempo: TimeInterval {
        // Por ahora devolvemos un valor estimado
        TimeInterval(totalEjercicios) * 300 // 5 minutos por ejercicio
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Resumen de rendimiento")
                .font(.title3)
                .fontWeight(.bold)
            
            HStack {
                StatisticView(title: "Rutinas", value: "\(totalRutinas)")
                StatisticView(title: "Ejercicios", value: "\(totalEjercicios)")
                StatisticView(title: "Tiempo", value: formatTime(totalTiempo))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds / 3600)
        return "\(hours)h"
    }
}

struct BMICard: View {
    @Query private var users: [User]
    
    private var imc: Double {
        guard let user = users.first else { return 0 }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("IMC")
                .font(.title3)
                .fontWeight(.bold)
            
            if let user = users.first {
                HStack {
                    Text(String(format: "%.1f", imc))
                        .font(.system(size: 36, weight: .bold))
                    
                    VStack(alignment: .leading) {
                        Text(clasificacionIMC.0)
                            .foregroundColor(clasificacionIMC.1)
                            .fontWeight(.medium)
                        Text("Último registro: \(formatDate(user.historialPeso.last?.fecha ?? Date()))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("No hay datos disponibles")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct StatisticView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()

private extension Calendar {
    func generateDates(for dateInterval: DateInterval) -> [Date] {
        var dates: [Date] = []
        var date = dateInterval.start
        
        while date < dateInterval.end {
            dates.append(date)
            guard let newDate = self.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        
        return dates
    }
}

#Preview {
    MainMenuView()
        .environmentObject(UserSettings())
        .environmentObject(HealthKitManager.shared)
}
