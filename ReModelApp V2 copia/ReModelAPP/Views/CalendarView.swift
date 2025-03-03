//
//  CalendarView.swift
//  ReModel
//
//  Created by Khupier on 10/1/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Query private var rutinas: [Rutina]
    @State private var selectedDate: Date = Date()
    @State private var showingDayView = false
    
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Text(month, formatter: monthFormatter)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: nextMonth) {
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
                                selectedDate = date
                                showingDayView = true
                            }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Calendario de Rutinas")
            .sheet(isPresented: $showingDayView) {
                CalendarDayView(date: selectedDate, rutinas: rutinasForDate(selectedDate))
                    .environmentObject(userSettings)
            }
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

