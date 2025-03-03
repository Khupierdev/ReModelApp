import SwiftUI
import SwiftData
import HealthKit

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings
    @StateObject private var healthKit = HealthKitManager.shared
    @EnvironmentObject var focusModeManager: FocusModeManager
    @State private var selectedTab = 0
    @Query private var users: [User]
    @State private var showOnboarding = false
    @State private var showWelcomeBack = false
    @State private var showHealthKitPrompt = false
    
    var body: some View {
        Group {
            if let user = users.first {
                mainView(for: user)
                    .environmentObject(healthKit)
            } else {
                OnboardingView { newUser in
                    showOnboarding = false
                    showWelcomeBack = true
                    checkHealthKitAuthorization()
                }
                .environmentObject(healthKit)
            }
        }
        .onAppear {
            if users.isEmpty {
                showOnboarding = true
            } else {
                checkHealthKitAuthorization()
            }
        }
        .alert("Vincular con Apple Health", isPresented: $showHealthKitPrompt) {
            Button("Vincular ahora") {
                requestHealthKitAuthorization()
            }
            Button("Más tarde", role: .cancel) {}
        } message: {
            Text("Para un mejor seguimiento de tu progreso, necesitamos acceso a tus datos de salud.")
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView { newUser in
                showOnboarding = false
                showWelcomeBack = true
                checkHealthKitAuthorization()
            }
            .environmentObject(healthKit)
        }
        .environmentObject(HealthKitManager.shared) // Added line
    }
    
    @ViewBuilder
    private func mainView(for user: User) -> some View {
        TabView(selection: $selectedTab) {
            MainMenuView()
                .tabItem {
                    Label("Principal", systemImage: "house.fill")
                }
                .tag(0)
            
            MisRutinasView()
                .tabItem {
                    Label("Mis Rutinas", systemImage: "figure.run")
                }
                .tag(1)
            
            ProgressView()
                .tabItem {
                    Label("Progreso", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            UserProfileView(user: user, onUserDeleted: {
                selectedTab = 0
                showOnboarding = true
            })
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(userSettings.accentColor)
        .fullScreenCover(isPresented: $showWelcomeBack) {
            WelcomeBackView(usuario: user, isPresented: $showWelcomeBack)
        }
    }
    
    private func checkHealthKitAuthorization() {
        if healthKit.authorizationStatus == .notDetermined {
            showHealthKitPrompt = true
        }
    }
    
    private func requestHealthKitAuthorization() {
        healthKit.requestAuthorization { success, error in
            if !success {
                print("Error al solicitar autorización de HealthKit: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
            .environmentObject(FocusModeManager.shared)
            .modelContainer(for: User.self, inMemory: true)
    }
}

