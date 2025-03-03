//
//  LiveActivityView.swift
//  ReModel
//
//  Created by Khupier on 15/1/25.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct LiveActivityView: View {
    // Actualizamos para recibir el contexto de ActivityKit directamente
    let context: ActivityViewContext<RutinaAttributes>
    
    init(activity: ActivityViewContext<RutinaAttributes>) {
        self.context = activity
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(context.attributes.nombre)
                .font(.headline)
                .lineLimit(1)
            
            Text(context.state.ejercicioActual)
                .font(.title3)
                .lineLimit(1)
            
            HStack {
                Gauge(value: context.state.progreso) {
                    EmptyView()
                } currentValueLabel: {
                    Text(formatTime(context.state.tiempoTranscurrido))
                        .font(.caption)
                        .monospacedDigit()
                }
                .gaugeStyle(.linearCapacity)
                .tint(.blue)
            }
            
            HStack {
                Label("Series: \(context.state.series)", systemImage: "number.circle")
                Spacer()
                Label("Reps: \(context.state.repeticiones)", systemImage: "figure.run")
            }
            .font(.caption)
        }
        .padding()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
