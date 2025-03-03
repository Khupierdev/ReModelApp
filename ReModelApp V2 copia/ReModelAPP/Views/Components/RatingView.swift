//
//  RatingView.swift
//  ReModel
//
//  Created by Khupier on 13/1/25.
//


import SwiftUI

struct RatingView: View {
    let title: String
    let rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.secondary)
            HStack {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(index <= rating ? .yellow : .gray)
                }
            }
        }
    }
}

