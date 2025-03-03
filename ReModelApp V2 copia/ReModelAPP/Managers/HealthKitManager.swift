//
//  HealthKitManager.swift
//  ReModel
//
//  Created by Khupier on 10/1/25.
//

import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private var healthStore: HKHealthStore?
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined
    @Published var authorizationError: String?
    
    // New enum for more detailed authorization status
    enum HealthKitAuthorizationStatus {
        case notDetermined
        case sharingDenied
        case sharingAuthorized
    }
    
    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            checkAuthorizationStatus()
        }
    }
    
    // Updated method to check authorization status
    func checkAuthorizationStatus() {
        guard let healthStore = healthStore else {
            handleHealthKitError(NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit no está disponible en este dispositivo"]))
            return
        }
        
        let typesToCheck: [HKObjectType] = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType()
        ]
        
        for type in typesToCheck {
            let status = healthStore.authorizationStatus(for: type)
            if status != .sharingAuthorized {
                DispatchQueue.main.async {
                    self.isAuthorized = false
                    self.authorizationStatus = .sharingDenied
                }
                return
            }
        }
        
        DispatchQueue.main.async {
            self.isAuthorized = true
            self.authorizationStatus = .sharingAuthorized
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let healthStore = healthStore else {
            handleHealthKitError(NSError(domain: "HealthKitManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit no está disponible en este dispositivo"]))
            completion(false, nil)
            return
        }
        
        // Types to read
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.workoutType()
        ]
        
        // Types to write
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ]
        
        // Request authorization
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.checkAuthorizationStatus()
                    self.authorizationError = nil
                    self.enableBackgroundDelivery()
                    self.scheduleHealthKitUpdates()
                } else {
                    self.handleHealthKitError(error ?? NSError(domain: "HealthKitManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Error desconocido al solicitar autorización"]))
                }
                completion(success, error)
            }
        }
    }
    
    // New method for handling HealthKit errors
    private func handleHealthKitError(_ error: Error) {
        DispatchQueue.main.async {
            self.authorizationError = error.localizedDescription
            // You might want to implement a notification system here to inform the UI
        }
    }
    
    // New method for enabling background delivery
    private func enableBackgroundDelivery() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        healthStore?.enableBackgroundDelivery(for: stepCountType, frequency: .immediate) { (success, error) in
            if let error = error {
                self.handleHealthKitError(error)
            }
        }
    }
    
    // New method for scheduling regular HealthKit updates
    private func scheduleHealthKitUpdates() {
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.fetchLatestHealthData()
        }
    }
    
    // Placeholder method for fetching latest health data
    private func fetchLatestHealthData() {
        // Implement fetching of various health data types here
        fetchDailySteps { _, _ in }
        // Add more data fetching as needed
    }
    
    func fetchDailySteps(completion: @escaping (Double?, Error?) -> Void) {
        guard let healthStore = healthStore,
              let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            handleHealthKitError(NSError(domain: "HealthKitManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "No autorizado o tipo de datos no disponible"]))
            completion(nil, nil)
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.handleHealthKitError(error ?? NSError(domain: "HealthKitManager", code: 5, userInfo: [NSLocalizedDescriptionKey: "Error al obtener los pasos diarios"]))
                    completion(nil, error)
                }
                return
            }
            
            let steps = sum.doubleValue(for: .count())
            DispatchQueue.main.async {
                completion(steps, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    func calculateCaloriesBurned(rutina: Rutina, duration: TimeInterval) -> Double {
        let avgMET = 5.0
        let hours = duration / 3600.0
        let weight = 70.0 // Average weight in kg, adjust based on user
        return avgMET * weight * hours
    }
    
    // New method for unit conversion
    func convertToPreferredUnits(_ quantity: HKQuantity, for typeIdentifier: HKQuantityTypeIdentifier) -> Double {
        let unit = preferredUnit(for: typeIdentifier)
        return quantity.doubleValue(for: unit)
    }
    
    // Helper method to determine preferred units
    private func preferredUnit(for typeIdentifier: HKQuantityTypeIdentifier) -> HKUnit {
        switch typeIdentifier {
        case .stepCount:
            return .count()
        case .activeEnergyBurned:
            return .kilocalorie()
        case .heartRate:
            return .count().unitDivided(by: .minute())
        case .height:
            return .meter()
        case .bodyMass:
            return .gramUnit(with: .kilo)
        default:
            fatalError("Unhandled quantity type")
        }
    }
    
    // New method for data synchronization
    func syncDataWithHealthKit() {
        fetchLatestWeight()
        fetchLatestHeight()
        // Add more synchronization methods as needed
    }
    
    private func fetchLatestWeight() {
        // Implement fetching latest weight data
    }
    
    private func fetchLatestHeight() {
        // Implement fetching latest height data
    }
    
    // Add this method to your existing HealthKitManager class
    func fetchCaloriesBurned(from startDate: Date, to endDate: Date, completion: @escaping ([(fecha: Date, calorias: Double)]?, Error?) -> Void) {
        guard let healthStore = healthStore,
              let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, NSError(domain: "HealthKitManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "No autorizado o tipo de datos no disponible"]))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: caloriesType,
                                              quantitySamplePredicate: predicate,
                                              options: .cumulativeSum,
                                              anchorDate: startDate,
                                              intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            var caloriasData: [(fecha: Date, calorias: Double)] = []
            
            results.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let calorias = quantity.doubleValue(for: .kilocalorie())
                    caloriasData.append((fecha: statistics.startDate, calorias: calorias))
                }
            }
            
            DispatchQueue.main.async {
                completion(caloriasData, nil)
            }
        }
        
        healthStore.execute(query)
    }
}

