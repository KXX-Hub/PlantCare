import Foundation
import SwiftUI

class PlantManager: ObservableObject {
    @Published var plants: [Plant] = []
    private let saveKey = "SavedPlants"
    private let userDefaults: UserDefaults
    private let notificationManager = NotificationManager.shared
    
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
        
        // 添加測試植物
        addTestPlants()
        
        // 監聽其他設備的更改
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange),
            name: UserDefaults.didChangeNotification,
            object: userDefaults
        )
        
        // 請求通知權限
        notificationManager.requestAuthorization()
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
        
        // 塊根植物示例
        let adenium = Plant(
            name: "沙漠玫瑰",
            species: "Adenium obesum",
            wateringFrequency: 7,
            notes: "喜歡陽光充足、排水良好的環境",
            lightLevel: .high,
            humidityLevel: .low,
            caudexType: .aboveGround,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -35, to: Date())
        )
        
        let pachypodium = Plant(
            name: "象腿樹",
            species: "Pachypodium lamerei",
            wateringFrequency: 10,
            notes: "需要充足的陽光，耐旱",
            lightLevel: .high,
            humidityLevel: .low,
            caudexType: .stem,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -25, to: Date())
        )
        
        let dioscorea = Plant(
            name: "龜甲龍",
            species: "Dioscorea elephantipes",
            wateringFrequency: 14,
            notes: "休眠期需要完全停止澆水",
            lightLevel: .medium,
            humidityLevel: .low,
            caudexType: .underground,
            growthPeriod: .dormant,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())
        )
        
        // 特殊塊根植物示例
        let dorstenia = Plant(
            name: "多肉花",
            species: "Dorstenia gigas",
            wateringFrequency: 10,
            notes: "索科特拉島特有種，樹狀多肉，需要充足陽光",
            lightLevel: .high,
            humidityLevel: .low,
            caudexType: .stem,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -20, to: Date())
        )
        
        let jatropha = Plant(
            name: "佛肚樹",
            species: "Jatropha podagrica",
            wateringFrequency: 7,
            notes: "佛肚狀莖幹，紅色花序，需要排水良好的介質",
            lightLevel: .high,
            humidityLevel: .medium,
            caudexType: .stem,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -15, to: Date())
        )
        
        let euphorbia = Plant(
            name: "玉麒麟",
            species: "Euphorbia obesa",
            wateringFrequency: 14,
            notes: "球狀多肉，需要極少澆水，避免陽光直射",
            lightLevel: .medium,
            humidityLevel: .low,
            caudexType: .stem,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -40, to: Date())
        )
        
        let adenia = Plant(
            name: "龜甲龍",
            species: "Adenia glauca",
            wateringFrequency: 10,
            notes: "藍綠色葉片，需要溫暖環境，避免過度澆水",
            lightLevel: .high,
            humidityLevel: .low,
            caudexType: .aboveGround,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())
        )
        
        let pachypodiumGeayi = Plant(
            name: "馬達加斯加棕櫚",
            species: "Pachypodium geayi",
            wateringFrequency: 12,
            notes: "樹狀多肉，需要充足陽光，耐旱",
            lightLevel: .high,
            humidityLevel: .low,
            caudexType: .stem,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -25, to: Date())
        )
        
        let fockea = Plant(
            name: "福克亞",
            species: "Fockea edulis",
            wateringFrequency: 8,
            notes: "可食用塊根，需要排水良好的介質",
            lightLevel: .high,
            humidityLevel: .medium,
            caudexType: .underground,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -35, to: Date())
        )
        
        let cyphostemma = Plant(
            name: "葡萄塊根",
            species: "Cyphostemma juttae",
            wateringFrequency: 10,
            notes: "大型塊根，需要充足陽光，耐旱",
            lightLevel: .high,
            humidityLevel: .low,
            caudexType: .stem,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -20, to: Date())
        )
        
        // 更新添加所有示例植物的陣列
        [monstera, peaceLily, snakePlant, zz, pothos, adenium, pachypodium, dioscorea, dorstenia, jatropha, euphorbia, adenia, fockea, cyphostemma, pachypodiumGeayi].forEach { addPlant($0) }
    }
    
    private func addTestPlants() {
        // 需要澆水的植物
        let wateringPlant = Plant(
            name: "測試植物-需要澆水",
            species: "測試品種",
            wateringFrequency: 7,
            lastWateredDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
            notes: "這是一個需要澆水的測試植物",
            caudexType: .none,
            growthPeriod: .active
        )
        
        // 需要施肥的塊根植物
        let fertilizingPlant = Plant(
            name: "測試塊根-需要施肥",
            species: "測試塊根品種",
            wateringFrequency: 10,
            lastWateredDate: Date(),
            notes: "這是一個需要施肥的測試塊根植物",
            caudexType: .aboveGround,
            growthPeriod: .active,
            lastFertilizedDate: Calendar.current.date(byAdding: .day, value: -35, to: Date())
        )
        
        plants.append(wateringPlant)
        plants.append(fertilizingPlant)
    }
    
    @objc private func handleDataChange() {
        loadPlants()
    }
    
    func addPlant(_ plant: Plant) {
        plants.append(plant)
        savePlants()
        notificationManager.scheduleWateringNotification(for: plant)
        if plant.isCaudexPlant {
            notificationManager.scheduleFertilizingNotification(for: plant)
        }
    }
    
    func updatePlant(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index] = plant
            savePlants()
            notificationManager.cancelNotifications(for: plant)
            notificationManager.scheduleWateringNotification(for: plant)
            if plant.isCaudexPlant {
                notificationManager.scheduleFertilizingNotification(for: plant)
            }
        }
    }
    
    func deletePlant(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        savePlants()
        notificationManager.cancelNotifications(for: plant)
    }
    
    func markAsWatered(_ plant: Plant) {
        var updatedPlant = plant
        updatedPlant.lastWateredDate = Date()
        updatedPlant.nextWateringDate = Calendar.current.date(byAdding: .day, value: plant.adjustedWateringFrequency, to: Date()) ?? Date()
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
                // 重新安排所有通知
                self.notificationManager.rescheduleAllNotifications(for: self.plants)
            }
        }
    }
    
    func getPlantsNeedingWater() -> [Plant] {
        let today = Date()
        return plants.filter { $0.nextWateringDate <= today }
    }
    
    func getPlantsNeedingFertilizer() -> [Plant] {
        return plants.filter { $0.isCaudexPlant && $0.needsFertilizer }
    }
    
    func getPlantsByLightLevel(_ level: LightLevel) -> [Plant] {
        return plants.filter { $0.lightLevel == level }
    }
    
    func getPlantsByHumidityLevel(_ level: HumidityLevel) -> [Plant] {
        return plants.filter { $0.humidityLevel == level }
    }
    
    func getCaudexPlants() -> [Plant] {
        return plants.filter { $0.isCaudexPlant }
    }
    
    func getPlantsByCaudexType(_ type: CaudexType) -> [Plant] {
        return plants.filter { $0.caudexType == type }
    }
    
    func getPlantsByGrowthPeriod(_ period: GrowthPeriod) -> [Plant] {
        return plants.filter { $0.growthPeriod == period }
    }
} 
