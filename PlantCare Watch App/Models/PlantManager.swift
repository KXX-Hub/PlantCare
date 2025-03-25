import Foundation
import SwiftUI

class PlantManager: ObservableObject {
    @Published var plants: [Plant] = []
    private let saveKey = "SavedPlants"
    private let userDefaults: UserDefaults
    
    init() {
        // 使用 App Group 來共享數據
        if let groupUserDefaults = UserDefaults(suiteName: "group.com.hongzhikai.PlantCare") {
            self.userDefaults = groupUserDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }
        
        loadPlants()
        
        // 如果沒有植物數據，添加示例植物
        if plants.isEmpty {
            addSamplePlants()
        }
        
        // 監聽其他設備的更改
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange),
            name: UserDefaults.didChangeNotification,
            object: userDefaults
        )
    }
    
    private func addSamplePlants() {
        // 添加一些需要澆水的植物（設置較早的最後澆水日期）
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        // 需要澆水的植物
        let monstera = Plant(
            name: "龜背芋",
            species: "Monstera deliciosa",
            wateringFrequency: 7,
            lastWateredDate: weekAgo,
            notes: "喜歡濕潤的環境，但不要過度澆水",
            lightLevel: .medium,
            humidityLevel: .high
        )
        
        let peaceLily = Plant(
            name: "白鶴芋",
            species: "Spathiphyllum",
            wateringFrequency: 3,
            lastWateredDate: twoDaysAgo,
            notes: "葉子下垂時就需要澆水",
            lightLevel: .low,
            humidityLevel: .high
        )
        
        // 不需要立即澆水的植物
        let snakePlant = Plant(
            name: "虎尾蘭",
            species: "Sansevieria trifasciata",
            wateringFrequency: 14,
            notes: "耐旱植物，容易照顧",
            lightLevel: .low,
            humidityLevel: .low
        )
        
        let zz = Plant(
            name: "金錢樹",
            species: "Zamioculcas zamiifolia",
            wateringFrequency: 10,
            notes: "耐陰植物，少澆水即可",
            lightLevel: .low,
            humidityLevel: .low
        )
        
        let pothos = Plant(
            name: "黃金葛",
            species: "Epipremnum aureum",
            wateringFrequency: 7,
            notes: "適應能力強，好養護",
            lightLevel: .medium,
            humidityLevel: .medium
        )
        
        // 添加所有示例植物
        [monstera, peaceLily, snakePlant, zz, pothos].forEach { addPlant($0) }
    }
    
    @objc private func handleDataChange() {
        loadPlants()
    }
    
    func addPlant(_ plant: Plant) {
        plants.append(plant)
        savePlants()
    }
    
    func updatePlant(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
            savePlants()
        }
    }
    
    func deletePlant(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        savePlants()
    }
    
    func markAsWatered(_ plant: Plant) {
        var updatedPlant = plant
        updatedPlant.lastWateredDate = Date()
        updatedPlant.nextWateringDate = Calendar.current.date(
            byAdding: .day,
            value: plant.adjustedWateringFrequency,
            to: Date()
        ) ?? Date()
        updatePlant(updatedPlant)
    }
    
    func markAsFertilized(_ plant: Plant) {
        var updatedPlant = plant
        updatedPlant.lastFertilizedDate = Date()
        updatePlant(updatedPlant)
    }
    
    private func savePlants() {
        if let encoded = try? JSONEncoder().encode(plants) {
            userDefaults.set(encoded, forKey: saveKey)
            userDefaults.synchronize()
        }
    }
    
    private func loadPlants() {
        if let data = userDefaults.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            DispatchQueue.main.async {
                self.plants = decoded
            }
        }
    }
    
    func getPlantsNeedingWater() -> [Plant] {
        let today = Date()
        return plants.filter { $0.nextWateringDate <= today }
    }
    
    func getPlantsByGrowthPeriod(_ period: GrowthPeriod) -> [Plant] {
        return plants.filter { $0.growthPeriod == period }
    }
    
    func getPlantsNeedingFertilizer() -> [Plant] {
        return plants.filter { $0.needsFertilizer }
    }
    
    func getCaudexPlants() -> [Plant] {
        return plants.filter { $0.isCaudexPlant }
    }
    
    func getPlantsByCaudexType(_ type: CaudexType) -> [Plant] {
        return plants.filter { $0.caudexType == type }
    }
    
    func getPlantsByLightLevel(_ level: LightLevel) -> [Plant] {
        return plants.filter { $0.lightLevel == level }
    }
    
    func getPlantsByHumidityLevel(_ level: HumidityLevel) -> [Plant] {
        return plants.filter { $0.humidityLevel == level }
    }
} 
