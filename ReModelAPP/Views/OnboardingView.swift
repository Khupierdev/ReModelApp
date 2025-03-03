//
//  OnboardingView.swift
//  GYMNESIA
//
//  Created by Khupier on 6/1/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var logoPosition: CGPoint = .zero
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOpacity: Double = 0.0
    @State private var formOpacity: Double = 0.0
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: Image?
    
    // Datos del usuario
    @State private var nombre = ""
    @State private var apellidos = ""
    @State private var fechaNacimiento = Date()
    @State private var imagenPerfilData: Data?
    @State private var genero: Genero = .masculino
    @State private var altura: Double = 170
    @State private var peso: Double = 70
    @State private var frecuenciaEjercicio: FrecuenciaEjercicio = .sedentario
    
    @Environment(\.modelContext) private var modelContext
    var onComplete: (User) -> Void
    
    init(onComplete: @escaping (User) -> Void) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Logo
                    Text("ReModel")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .position(logoPosition)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    // Contenido principal
                    VStack {
                        if currentStep == 0 {
                            registroUsuarioView
                        } else {
                            seleccionImagenView
                        }
                    }
                    .opacity(formOpacity)
                }
            }
            .onAppear {
                // Posición inicial del logo
                logoPosition = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Animación de aparición del logo
                withAnimation(.easeIn(duration: 1.0)) {
                    logoOpacity = 1.0
                }
                
                // Animación de brillo
                withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                    logoScale = 1.1
                }
                
                // Mover el logo y mostrar el formulario después de 2 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        logoPosition = CGPoint(x: geometry.size.width / 2, y: geometry.safeAreaInsets.top + 40)
                        logoScale = 0.7
                    }
                    withAnimation(.easeIn(duration: 0.5)) {
                        formOpacity = 1.0
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    var registroUsuarioView: some View {
        VStack(spacing: 25) {
            Group {
                TextField("Nombre", text: $nombre)
                TextField("Apellidos", text: $apellidos)
                
                DatePicker("Fecha de nacimiento", selection: $fechaNacimiento, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                
                Picker("Género", selection: $genero) {
                    ForEach(Genero.allCases, id: \.self) { genero in
                        Text(genero.rawValue).tag(genero)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(10)
            
            Group {
                HStack {
                    Text("Altura")
                    Slider(value: $altura, in: 100...250, step: 1)
                    Text("\(Int(altura)) cm")
                }
                
                HStack {
                    Text("Peso")
                    Slider(value: $peso, in: 30...200, step: 0.5)
                    Text(String(format: "%.1f kg", peso))
                }
            }
            
            Picker("Frecuencia de ejercicio", selection: $frecuenciaEjercicio) {
                ForEach(FrecuenciaEjercicio.allCases, id: \.self) { frecuencia in
                    Text(frecuencia.rawValue).tag(frecuencia)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(10)
            
            Button(action: { withAnimation { currentStep = 1 } }) {
                Text("Siguiente")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(nombre.isEmpty || apellidos.isEmpty)
            .opacity(nombre.isEmpty || apellidos.isEmpty ? 0.6 : 1)
        }
        .padding()
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    
    var seleccionImagenView: some View {
        VStack(spacing: 30) { // Aumentado el espaciado de 20 a 30
            Spacer().frame(height: 50) // Añadido un espaciador en la parte superior
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .foregroundColor(.gray)
                }
            }
            .transition(.scale.combined(with: .opacity))
            
            PhotosPicker(selection: $selectedImage, matching: .images) {
                Text("Seleccionar foto de perfil")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: guardarUsuario) {
                Text("Finalizar")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            Spacer() // Añadido un espaciador al final para empujar el contenido hacia arriba
        }
        .padding()
        .transition(.move(edge: .trailing).combined(with: .opacity))
        .onChange(of: selectedImage) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        withAnimation {
                            profileImage = Image(uiImage: uiImage)
                        }
                        imagenPerfilData = data
                    }
                }
            }
        }
    }
    
    private func guardarUsuario() {
        let usuario = User(nombre: nombre,
                           apellidos: apellidos,
                           fechaNacimiento: fechaNacimiento,
                           altura: altura,
                           peso: peso,
                           genero: genero,
                           frecuenciaEjercicio: frecuenciaEjercicio)
        
        usuario.imagenPerfil = imagenPerfilData
        
        modelContext.insert(usuario)
        
        do {
            try modelContext.save()
            onComplete(usuario)
        } catch {
            print("Error al guardar el usuario: \(error.localizedDescription)")
        }
    }
}
