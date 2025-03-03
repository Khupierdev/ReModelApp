//
//  FocusModeSettingsView.swift
//  ReModel
//
//  Created by Khupier on 14/1/25.
//


import SwiftUI

struct FocusModeSettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    @StateObject private var focusModeManager = FocusModeManager.shared
    
    var body: some View {
        List {
            Section(header: Text("Modo de concentración para entrenamiento")) {
                if focusModeManager.isLoading {
                    ProgressView()
                } else {
                    ForEach(focusModeManager.availableFocusModes) { mode in
                        HStack {
                            Text(mode.name)
                            Spacer()
                            if userSettings.selectedFocusModeId == mode.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            userSettings.selectedFocusModeId = mode.id
                        }
                    }
                }
            }
            
            Section(footer: Text("El modo seleccionado se activará automáticamente al iniciar un entrenamiento")) {
                EmptyView()
            }
        }
        .navigationTitle("Modo de concentración")
    }
}

