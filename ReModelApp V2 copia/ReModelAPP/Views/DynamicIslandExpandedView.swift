//
//  DynamicIslandExpandedView.swift
//  ReModel
//
//  Created by Khupier on 15/1/25.
//

import SwiftUI
import ActivityKit

struct DynamicIslandExpandedView: View {
    let context: Activity<RutinaAttributes>.ContentState
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(context.ejercicioActual)
                .font(.headline)
            
            Text("Tiempo: \(formatTime(context.tiempoTranscurrido))")
            
            HStack {
                Text("Series:")
                Spacer()
                Text("\(context.series)")
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 8)
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * context.progreso, height: 8)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
        .padding()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#if DEBUG
struct DynamicIslandExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicIslandExpandedView(
            context: RutinaAttributes.ContentState(
                ejercicioActual: "Press de banca",
                tiempoTranscurrido: 65,
                progreso: 0.5,
                series: 2,
                repeticiones: 12
            )
        )
    }
}
#endif
