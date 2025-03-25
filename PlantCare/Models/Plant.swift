import Foundation

// 生長期枚舉
enum GrowthPeriod: String, Codable, CaseIterable {
    case active = "生長期"
    case dormant = "休眠期"
    case transition = "過渡期"
}

// 塊根類型枚舉
enum CaudexType: String, Codable, CaseIterable {
    case aboveGround = "地上塊根"
    case underground = "地下塊根"
    case stem = "莖膨大"
    case root = "根膨大"
    case none = "非塊根"
}

struct Plant: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var species: String
    var wateringFrequency: Int // 澆水頻率（天數）
    var lastWateredDate: Date
    var nextWateringDate: Date
    var notes: String
    var imageURL: String?
    var lightLevel: LightLevel
    var humidityLevel: HumidityLevel
    
    // 新增塊根相關屬性
    var caudexType: CaudexType
    var growthPeriod: GrowthPeriod
    var lastFertilizedDate: Date?
    var isCaudexPlant: Bool { caudexType != .none }
    
    init(id: UUID = UUID(), 
         name: String, 
         species: String, 
         wateringFrequency: Int, 
         lastWateredDate: Date = Date(), 
         notes: String = "", 
         imageURL: String? = nil, 
         lightLevel: LightLevel = .medium, 
         humidityLevel: HumidityLevel = .medium,
         caudexType: CaudexType = .none,
         growthPeriod: GrowthPeriod = .active,
         lastFertilizedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.species = species
        self.wateringFrequency = wateringFrequency
        self.lastWateredDate = lastWateredDate
        self.nextWateringDate = Calendar.current.date(byAdding: .day, value: wateringFrequency, to: lastWateredDate) ?? lastWateredDate
        self.notes = notes
        self.imageURL = imageURL
        self.lightLevel = lightLevel
        self.humidityLevel = humidityLevel
        self.caudexType = caudexType
        self.growthPeriod = growthPeriod
        self.lastFertilizedDate = lastFertilizedDate
    }
    
    // 根據生長期調整澆水頻率
    var adjustedWateringFrequency: Int {
        switch growthPeriod {
        case .active:
            return wateringFrequency
        case .dormant:
            return wateringFrequency * 2 // 休眠期澆水頻率減半
        case .transition:
            return Int(Double(wateringFrequency) * 1.5) // 過渡期稍微減少澆水
        }
    }
    
    // 判斷是否需要施肥
    var needsFertilizer: Bool {
        guard growthPeriod == .active else { return false } // 只在生長期需要施肥
        guard let lastFertilized = lastFertilizedDate else { return true }
        
        // 假設每30天需要施肥一次（在生長期）
        let daysSinceLastFertilized = Calendar.current.dateComponents([.day], from: lastFertilized, to: Date()).day ?? 0
        return daysSinceLastFertilized >= 30
    }
    
    // 實現 Equatable 協議
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        return lhs.id == rhs.id
    }
}

enum LightLevel: String, Codable, CaseIterable {
    case low = "低光照"
    case medium = "中等光照"
    case high = "強光照"
}

enum HumidityLevel: String, Codable, CaseIterable {
    case low = "低濕度"
    case medium = "中等濕度"
    case high = "高濕度"
} 
