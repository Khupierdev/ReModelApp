//
//  MetricRow.swift
//  ReModel
//
//  Created by Khupier on 13/1/25.
//


import SwiftUI

struct MetricRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}

