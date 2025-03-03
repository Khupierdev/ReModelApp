//
//  RutinaEnProgresoView.swift
//  GYMNESIA
//
//  Created by Khupier on 9/1/25.
//

import SwiftUI
import SwiftData

struct RutinaEnProgresoView: View {
    let rutina: Rutina
    @State private var isPaused = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentExerciseIndex = 0
    @State private var showingSummary = false
    @State private var workoutMetrics: WorkoutMetrics
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var healthKitManager: HealthKitManager
    @Environment(\.dynamicIslandManager) private var dynamicIslandManager
    
    private var currentExercise: EjercicioEnRutina { rutina.ejercicios[currentExerciseIndex] }
    private var isLastExercise: Bool { currentExerciseIndex == rutina.ejercicios.count - 1 }
    private var isFirstExercise: Bool { currentExerciseIndex == 0 }
    
    init(rutina: Rutina) {
        self.rutina = rutina
        _workoutMetrics = State(initialValue: WorkoutMetrics(rutinaId: rutina.id.uuidString))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                progressBar
                timerAndPauseButton
                exerciseDetails
                navigationButtons
            }
            .navigationTitle("Rutina en progreso")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton)
            .onAppear(perform: setupWorkout)
            .onDisappear(perform: cleanupWorkout)
            .fullScreenCover(isPresented: $showingSummary) {
                WorkoutSummaryView(rutina: rutina, metrics: workoutMetrics, onFinish: finishAndDismiss)
            }
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(userSettings.accentColor)
                    .frame(width: geometry.size.width * CGFloat(currentExerciseIndex + 1) / CGFloat(rutina.ejercicios.count), height: 8)
                    .cornerRadius(4)
            }
        }
        .frame(height: 8)
        .padding(.horizontal)
    }
    
    private var timerAndPauseButton: some View {
        HStack {
            Text(timeString(from: elapsedTime))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(userSettings.accentColor)
            
            Spacer()
            
            Button(action: togglePause) {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(userSettings.accentColor)
            }
        }
        .padding(.horizontal)
    }
    
    private var exerciseDetails: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(currentExercise.ejercicio.nombre)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(userSettings.accentColor)
                
                InfoCard(title: "Series", value: "\(currentExercise.configuracion.series)")
                InfoCard(title: "Repeticiones", value: "\(currentExercise.configuracion.repeticiones)")
                
                if currentExercise.configuracion.pesoUniforme {
                    InfoCard(title: "Peso", value: "\(String(format: "%.1f", currentExercise.configuracion.peso)) kg")
                } else {
                    weightPerSeriesView
                }
                
                InfoCard(title: "Músculos trabajados", value: currentExercise.ejercicio.musculosEspecificos.joined(separator: ", "))
            }
            .padding()
        }
    }
    
    private var weightPerSeriesView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Peso por serie:")
                .font(.headline)
            ForEach(0..<currentExercise.configuracion.series, id: \.self) { index in
                HStack {
                    Text("Serie \(index + 1):")
                    Spacer()
                    Text("\(String(format: "%.1f", currentExercise.configuracion.pesoPorSerie[index])) kg")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            Button(action: previousExercise) {
                Text("Anterior")
                    .buttonStyle(complementaryColor: userSettings.accentColor)
            }
            .disabled(isFirstExercise)
            .opacity(isFirstExercise ? 0.5 : 1)
            
            Button(action: nextOrFinishExercise) {
                Text(isLastExercise ? "Finalizar" : "Siguiente")
                    .buttonStyle(color: isLastExercise ? .red : userSettings.accentColor)
            }
        }
        .padding()
    }
    
    private var cancelButton: some View {
        Button("Cancelar") {
            dynamicIslandManager.endRutinaActivity()
            dismiss()
        }
    }
    
    private func setupWorkout() {
        workoutMetrics = WorkoutMetrics(rutinaId: rutina.id.uuidString)
        dynamicIslandManager.startRutinaActivity(rutina: rutina, ejercicioActual: currentExercise)
        startTimer()
    }
    
    private func cleanupWorkout() {
        stopTimer()
        dynamicIslandManager.endRutinaActivity()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if !isPaused {
                elapsedTime += 0.1
                updateDynamicIsland()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func togglePause() {
        isPaused.toggle()
    }
    
    private func updateDynamicIsland() {
        dynamicIslandManager.updateRutinaActivity(
            tiempoTranscurrido: elapsedTime,
            ejercicioActual: currentExercise,
            seriesCompletadas: currentExercise.configuracion.series
        )
    }
    
    private func previousExercise() {
        withAnimation {
            finishCurrentExercise(completed: false)
            currentExerciseIndex -= 1
        }
    }
    
    private func nextOrFinishExercise() {
        finishCurrentExercise(completed: true)
        if isLastExercise {
            finishWorkout()
        } else {
            withAnimation {
                currentExerciseIndex += 1
            }
        }
    }
    
    private func finishCurrentExercise(completed: Bool) {
        if completed {
            let duration = elapsedTime - (workoutMetrics.ejerciciosCompletados.last?.duracion ?? 0)
            let metrics = EjercicioMetrics(
                ejercicioId: currentExercise.ejercicio.id,
                pesoInicial: currentExercise.configuracion.peso,
                pesoFinal: currentExercise.configuracion.peso,
                seriesCompletadas: currentExercise.configuracion.series,
                repeticionesCompletadas: currentExercise.configuracion.repeticiones,
                duracion: duration,
                caloriasQuemadas: 0
            )
            workoutMetrics.ejerciciosCompletados.append(metrics)
        }
    }
    
    private func finishWorkout() {
        workoutMetrics.duracionTotal = elapsedTime
        workoutMetrics.caloriasQuemadas = healthKitManager.calculateCaloriesBurned(rutina: rutina, duration: elapsedTime)
        dynamicIslandManager.endRutinaActivity()
        showingSummary = true
    }
    
    private func finishAndDismiss() {
        showingSummary = false
        dynamicIslandManager.endRutinaActivity()
        dismiss()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        let tenths = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 10)
        
        return hours > 0 ? String(format: "%02d:%02d:%02d.%d", hours, minutes, seconds, tenths)
                         : String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}

extension View {
    func buttonStyle(color: Color) -> some View {
        self.font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(12)
    }
    
    func buttonStyle(complementaryColor: Color) -> some View {
        let uiColor = UIColor(complementaryColor)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let complementary = Color(UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha))
        return self.buttonStyle(color: complementary)
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

