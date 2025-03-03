//
//  UserSettings.swift
//  GYMNESIA
//
//  Created by Khupier on 4/1/25.
//

import SwiftUI

class UserSettings: ObservableObject {
    @AppStorage("accentColorString") var accentColorString: String = "green"
    
    @Published var selectedFocusModeId: String? {
        didSet {
            UserDefaults.standard.set(selectedFocusModeId, forKey: "selectedFocusModeId")
        }
    }
    
    var accentColor: Color {
        get {
            Color(hex: accentColorString) ?? .green
        }
        set {
            accentColorString = newValue.toHex() ?? "green"
        }
    }
    
    init() {
        self.selectedFocusModeId = UserDefaults.standard.string(forKey: "selectedFocusModeId")
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            .sRGB,
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0,
            opacity: 1.0
        )
    }
    
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let hex = String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return hex
    }
}


