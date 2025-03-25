import XCTest
@testable import PlantCare

final class PlantManagerTests: XCTestCase {
    var plantManager: PlantManager!
    
    override func setUp() {
        super.setUp()
        plantManager = PlantManager()
    }
    
    override func tearDown() {
        plantManager = nil
        super.tearDown()
    }
    
    func testAddPlant() {
        // 準備測試數據
        let plant = Plant(
            name: "測試植物",
            species: "測試品種",
            wateringFrequency: 7
        )
        
        // 執行要測試的操作
        plantManager.addPlant(plant)
        
        // 驗證結果
        XCTAssertEqual(plantManager.plants.count, 1)
        XCTAssertEqual(plantManager.plants.first?.name, "測試植物")
        XCTAssertEqual(plantManager.plants.first?.species, "測試品種")
    }
    
    func testDeletePlant() {
        // 準備測試數據
        let plant = Plant(
            name: "要刪除的植物",
            species: "測試品種",
            wateringFrequency: 7
        )
        plantManager.addPlant(plant)
        
        // 確認植物已經添加
        XCTAssertEqual(plantManager.plants.count, 1)
        
        // 執行刪除操作
        plantManager.deletePlant(plant)
        
        // 驗證結果
        XCTAssertEqual(plantManager.plants.count, 0)
    }
    
    func testMarkAsWatered() {
        // 準備測試數據
        let plant = Plant(
            name: "要澆水的植物",
            species: "測試品種",
            wateringFrequency: 7
        )
        plantManager.addPlant(plant)
        
        // 記錄原始的澆水日期
        let originalWaterDate = plant.lastWateredDate
        
        // 等待一小段時間以確保時間戳不同
        Thread.sleep(forTimeInterval: 1)
        
        // 執行澆水操作
        plantManager.markAsWatered(plant)
        
        // 驗證結果
        let updatedPlant = plantManager.plants.first!
        XCTAssertGreaterThan(updatedPlant.lastWateredDate, originalWaterDate)
        
        // 驗證下次澆水日期是否正確設置
        let expectedNextWatering = Calendar.current.date(byAdding: .day, value: 7, to: updatedPlant.lastWateredDate)!
        XCTAssertEqual(updatedPlant.nextWateringDate, expectedNextWatering)
    }
    
    func testGetPlantsNeedingWater() {
        // 準備測試數據：一個需要澆水的植物（下次澆水日期在過去）
        let needsWaterPlant = Plant(
            name: "需要澆水的植物",
            species: "測試品種",
            wateringFrequency: 1,
            lastWateredDate: Date().addingTimeInterval(-172800) // 2天前
        )
        
        // 一個不需要澆水的植物（下次澆水日期在未來）
        let notNeedsWaterPlant = Plant(
            name: "不需要澆水的植物",
            species: "測試品種",
            wateringFrequency: 7,
            lastWateredDate: Date() // 現在
        )
        
        plantManager.addPlant(needsWaterPlant)
        plantManager.addPlant(notNeedsWaterPlant)
        
        // 執行測試
        let plantsNeedingWater = plantManager.getPlantsNeedingWater()
        
        // 驗證結果
        XCTAssertEqual(plantsNeedingWater.count, 1)
        XCTAssertEqual(plantsNeedingWater.first?.name, "需要澆水的植物")
    }
} 
