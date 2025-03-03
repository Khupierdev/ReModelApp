//
//  WelcomeBackView.swift
//  GYMNESIA
//
//  Created by Khupier on 6/1/25.
//

import SwiftUI

struct WelcomeBackView: View {
    let usuario: User
    @Binding var isPresented: Bool
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if let imageData = usuario.imagenPerfil,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)
                }
                
                Text("Bienvenido de nuevo")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(usuario.nombre)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 1)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isPresented = false
                }
            }
        }
    }
}

