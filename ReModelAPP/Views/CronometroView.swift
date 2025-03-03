//
//  CronometroView.swift
//  GYMNESIA
//
//  Created by Khupier on 4/1/25.
//

import SwiftUI

struct CronometroView: View {
    @State private var mode: TimerMode = .stopwatch
    @State private var timeElapsed: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var countdownDuration: TimeInterval = 60
    
    enum TimerMode {
        case stopwatch, countdown
    }
    
    var body: some View {
        VStack {
            Picker("Modo", selection: $mode) {
                Text("Cronómetro").tag(TimerMode.stopwatch)
                Text("Temporizador").tag(TimerMode.countdown)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if mode == .countdown {
                Stepper(value: $countdownDuration, in: 1...3600, step: 15) {
                    Text("Duración: \(Int(countdownDuration)) segundos")
                }
                .padding()
            }
            
            Text(timeString(from: mode == .stopwatch ? timeElapsed : (countdownDuration - timeElapsed)))
                .font(.system(size: 70, weight: .bold, design: .monospaced))
                .padding()
            
            HStack {
                Button(action: startStop) {
                    Text(isRunning ? "Detener" : "Iniciar")
                        .padding()
                        .background(isRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: reset) {
                    Text("Reiniciar")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle(mode == .stopwatch ? "Cronómetro" : "Temporizador")
    }
    
    func startStop() {
        if isRunning {
            timer?.invalidate()
            isRunning = false
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if mode == .stopwatch {
                    timeElapsed += 0.1
                } else {
                    if timeElapsed < countdownDuration {
                        timeElapsed += 0.1
                    } else {
                        timer?.invalidate()
                        isRunning = false
                    }
                }
            }
            isRunning = true
        }
    }
    
    func reset() {
        timer?.invalidate()
        timeElapsed = 0
        isRunning = false
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let tenths = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}

struct CronometroView_Previews: PreviewProvider {
    static var previews: some View {
        CronometroView()
    }
}

