//
//  LiveActivityConfiguration.swift
//  ReModel
//
//  Created by Khupier on 16/1/25.
//

import SwiftUI
import ActivityKit
import WidgetKit

struct LiveActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RutinaAttributes.self) { context in
            LiveActivityContentView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.nombre)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatTime(context.state.tiempoTranscurrido))
                        .font(.caption)
                        .monospacedDigit()
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.ejercicioActual)
                        .font(.system(.body, design: .rounded))
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Gauge(value: context.state.progreso) {
                            EmptyView()
                        }
                        .gaugeStyle(.linearCapacity)
                        .tint(.blue)
                        
                        HStack {
                            Label("Series: \(context.state.series)", systemImage: "number.circle")
                            Spacer()
                            Label("Reps: \(context.state.repeticiones)", systemImage: "figure.run")
                        }
                        .font(.caption2)
                    }
                }
            } compactLeading: {
                Text(context.attributes.nombre)
                    .font(.caption2)
                    .lineLimit(1)
            } compactTrailing: {
                Text(formatTime(context.state.tiempoTranscurrido))
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Text("\(Int(context.state.progreso * 100))%")
                    .font(.caption2)
            }
        }
    }
}

struct LiveActivityContentView: View {
    let context: ActivityViewContext<RutinaAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            Text(context.attributes.nombre)
                .font(.headline)
            
            Text(context.state.ejercicioActual)
                .font(.title3)
            
            CustomProgressView(progress: context.state.progreso, timeElapsed: context.state.tiempoTranscurrido)
            
            HStack {
                Label("Series: \(context.state.series)", systemImage: "number.circle")
                Spacer()
                Label("Reps: \(context.state.repeticiones)", systemImage: "figure.run")
            }
        }
        .padding()
    }
}

struct CustomProgressView: View {
    let progress: Double
    let timeElapsed: TimeInterval
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 8)
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
            
            Text(formatTime(timeElapsed))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private func formatTime(_ timeInterval: TimeInterval) -> String {
    let minutes = Int(timeInterval) / 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}
