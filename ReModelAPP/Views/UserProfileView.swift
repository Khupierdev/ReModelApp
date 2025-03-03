//
//  UserProfileView.swift
//  GYMNESIA
//
//  Created by Khupier on 8/1/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct UserProfileView: View {
    @Bindable var user: User
    @State private var profileImage: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var isEditingProfile = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation = false
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) private var dismiss
    var onUserDeleted: () -> Void

    init(user: User, onUserDeleted: @escaping () -> Void) {
        self._user = Bindable(wrappedValue: user)
        self.onUserDeleted = onUserDeleted
        if let imageData = user.imagenPerfil, let uiImage = UIImage(data: imageData) {
            _profileImage = State(initialValue: Image(uiImage: uiImage))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Foto de Perfil")) {
                    HStack {
                        Spacer()
                        if let profileImage = profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 10)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Cambiar Foto de Perfil", systemImage: "photo")
                    }
                }
                
                Section(header: Text("Información Personal")) {
                    if isEditingProfile {
                        TextField("Nombre", text: $user.nombre)
                        TextField("Apellidos", text: $user.apellidos)
                        DatePicker("Fecha de Nacimiento", selection: $user.fechaNacimiento, displayedComponents: .date)
                        
                        Picker("Género", selection: $user.genero) {
                            ForEach(Genero.allCases, id: \.self) { genero in
                                Text(genero.rawValue).tag(genero)
                            }
                        }
                    } else {
                        Text("Nombre: \(user.nombre)")
                        Text("Apellidos: \(user.apellidos)")
                        Text("Fecha de Nacimiento: \(formattedDate(user.fechaNacimiento))")
                        Text("Género: \(user.genero.rawValue)")
                    }
                }
                
                Section(header: Text("Datos Físicos")) {
                    if isEditingProfile {
                        HStack {
                            Text("Altura (cm)")
                            TextField("Altura", value: $user.altura, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Peso (kg)")
                            TextField("Peso", value: $user.peso, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                        }
                        .onChange(of: user.peso) { oldValue, newValue in
                            if oldValue != newValue {
                                user.historialPeso.append(RegistroPeso(peso: newValue, fecha: Date()))
                            }
                        }
                        
                        Picker("Frecuencia de ejercicio", selection: $user.frecuenciaEjercicio) {
                            ForEach(FrecuenciaEjercicio.allCases, id: \.self) { frecuencia in
                                Text(frecuencia.rawValue).tag(frecuencia)
                            }
                        }
                    } else {
                        Text("Altura: \(String(format: "%.0f cm", user.altura))")
                        Text("Peso: \(String(format: "%.1f kg", user.peso))")
                        Text("Frecuencia de ejercicio: \(user.frecuenciaEjercicio.rawValue)")
                    }
                }
                
                Section(header: Text("Apariencia")) {
                    NavigationLink(destination: ColorPickerView()) {
                        HStack {
                            Text("Color de acento")
                            Spacer()
                            Circle()
                                .fill(userSettings.accentColor)
                                .frame(width: 20, height: 20)
                        }
                    }
                }

                if let adultoResponsable = user.adultoResponsable {
                    Section(header: Text("Información del Adulto Responsable")) {
                        Text("Nombre: \(adultoResponsable.nombre)")
                        Text("Apellidos: \(adultoResponsable.apellidos)")
                        Text("Fecha de Nacimiento: \(formattedDate(adultoResponsable.fechaNacimiento))")
                    }
                }
                
                Section {
                    Button(action: {
                        if isEditingProfile {
                            do {
                                try modelContext.save()
                            } catch {
                                alertMessage = "Error al guardar los cambios: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                        isEditingProfile.toggle()
                    }) {
                        Text(isEditingProfile ? "Guardar Cambios" : "Editar Perfil")
                    }
                    
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Eliminar Usuario")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Perfil de Usuario")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Aviso"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .actionSheet(isPresented: $showDeleteConfirmation) {
                ActionSheet(
                    title: Text("Eliminar Usuario"),
                    message: Text("¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer."),
                    buttons: [
                        .destructive(Text("Eliminar")) {
                            deleteUser()
                        },
                        .cancel()
                    ]
                )
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            profileImage = Image(uiImage: uiImage)
                            user.imagenPerfil = data
                            do {
                                try modelContext.save()
                            } catch {
                                alertMessage = "Error al guardar la imagen: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func deleteUser() {
        modelContext.delete(user)
        do {
            try modelContext.save()
            onUserDeleted()
        } catch {
            alertMessage = "Error al eliminar el usuario: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
