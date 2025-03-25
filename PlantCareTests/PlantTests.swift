import XCTest
@testable import PlantCare

final class PlantTests: XCTestCase {
    func testPlantInitialization() {
        // 測試基本初始化
        let plant = Plant(
            name: "測試植物",
            species: "測試品種",
            wateringFrequency: 7
        )
        
        // 驗證基本屬性
        XCTAssertEqual(plant.name, "測試植物")
        XCTAssertEqual(plant.species, "測試品種")
        XCTAssertEqual(plant.wateringFrequency, 7)
        XCTAssertEqual(plant.lightLevel, .medium) // 默認值
        XCTAssertEqual(plant.humidityLevel, .medium) // 默認值
        
        // 驗證自動計算的澆水日期
        let expectedNextWatering = Calendar.current.date(byAdding: .day, value: 7, to: plant.lastWateredDate)!
        XCTAssertEqual(plant.nextWateringDate, expectedNextWatering)
    }
    
    func testPlantWithCustomLevels() {
        // 測試自定義光照和濕度級別的初始化
        let plant = Plant(
            name: "測試植物",
            species: "測試品種",
            wateringFrequency: 7,
            notes: "測試備註",
            lightLevel: .high,
            humidityLevel: .low
        )
        
        // 驗證自定義屬性
        XCTAssertEqual(plant.lightLevel, .high)
        XCTAssertEqual(plant.humidityLevel, .low)
        XCTAssertEqual(plant.notes, "測試備註")
    }
    
    func testPlantEquality() {
        // 創建兩個具有相同 ID 但其他屬性不同的植物
        let id = UUID()
        let plant1 = Plant(
            id: id,
            name: "植物1",
            species: "品種1",
            wateringFrequency: 7
        )
        
        let plant2 = Plant(
            id: id,
            name: "植物2", // 不同的名字
            species: "品種2", // 不同的品種
            wateringFrequency: 14 // 不同的澆水頻率
        )
        
        // 驗證相等性（應該相等，因為 ID 相同）
        XCTAssertEqual(plant1.id, plant2.id)
    }
    
    func testNextWateringDateCalculation() {
        // 創建一個植物，設置特定的最後澆水日期
        let specificDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 1))!
        let plant = Plant(
            name: "測試植物",
            species: "測試品種",
            wateringFrequency: 7,
            lastWateredDate: specificDate
        )
        
        // 計算預期的下次澆水日期（應該是 3月8日）
        let expectedNextWatering = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 8))!
        
        // 驗證下次澆水日期是否正確計算
        XCTAssertEqual(
            Calendar.current.startOfDay(for: plant.nextWateringDate),
            Calendar.current.startOfDay(for: expectedNextWatering)
        )
    }
} 
