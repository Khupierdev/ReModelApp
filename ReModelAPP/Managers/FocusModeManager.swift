//
//  FocusModeManager.swift
//  ReModel
//
//  Created by Khupier on 14/1/25.
//

import Foundation
import Intents
import IntentsUI
import ManagedSettings
import ManagedSettingsUI
import FamilyControls

class FocusModeManager: ObservableObject {
    static let shared = FocusModeManager()
    
    @Published var availableFocusModes: [FocusMode] = []
    @Published var isLoading = false
    private let store = ManagedSettingsStore()
    
    private init() {
        loadAvailableFocusModes()
    }
    
    func loadAvailableFocusModes() {
        isLoading = true
        
        Task {
            do {
                let center = AuthorizationCenter.shared
                try await center.requestAuthorization(for: .individual)
                
                await MainActor.run {
                    self.fetchSystemFocusModes()
                    self.isLoading = false
                }
            } catch {
                print("Error requesting focus authorization: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchSystemFocusModes() {
        availableFocusModes = [
            FocusMode(name: "No molestar", systemIdentifier: "doNotDisturb"),
            FocusMode(name: "Ejercicio", systemIdentifier: "fitness"),
            FocusMode(name: "Personal", systemIdentifier: "personal")
        ]
    }
    
    func activateFocusMode(_ mode: FocusMode) {
        Task {
            if let url = URL(string: "x-apple-focus://") {
                // No necesitamos try-catch aquí ya que open no es throwing
                await UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        NotificationCenter.default.post(
                            name: Notification.Name("FocusModeActivated"),
                            object: nil,
                            userInfo: ["modeName": mode.name]
                        )
                    } else {
                        // Si falla, intentamos abrir la configuración
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                }
            }
        }
    }
    
    func getCurrentFocusStatus() -> String? {
        return nil
    }
}

// Extensión para compatibilidad
extension FocusModeManager {
    static var isSupported: Bool {
        if #available(iOS 15.0, *) {
            return true
        }
        return false
    }
} 
