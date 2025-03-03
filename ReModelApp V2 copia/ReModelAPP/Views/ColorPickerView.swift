//
//  ColorPickerView.swift
//  GYMNESIA
//
//  Created by Khupier on 4/1/25.
//

import SwiftUI

struct ColorPickerView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var selectedColor: Color = .green
    @State private var showCustomColorPicker = false
    
    let predefinedColors: [Color] = [.green, .blue, .red, .orange, .purple]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Selecciona un color de acento")
                    .font(.headline)
                
                ForEach(predefinedColors, id: \.self) { color in
                    ColorButton(color: color, selectedColor: $selectedColor)
                }
                
                Button(action: {
                    showCustomColorPicker = true
                }) {
                    Text("Color personalizado")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
            .navigationBarItems(trailing: Button("Guardar") {
                userSettings.accentColor = selectedColor
            })
            .sheet(isPresented: $showCustomColorPicker) {
                CustomColorPicker(selectedColor: $selectedColor)
            }
        }
    }
}

struct ColorButton: View {
    let color: Color
    @Binding var selectedColor: Color
    
    var body: some View {
        Button(action: {
            selectedColor = color
        }) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .opacity(selectedColor == color ? 1 : 0)
                )
        }
    }
}

struct CustomColorPicker: View {
    @Binding var selectedColor: Color
    
    var body: some View {
        ColorPicker("Selecciona un color personalizado", selection: $selectedColor)
            .padding()
    }
}
