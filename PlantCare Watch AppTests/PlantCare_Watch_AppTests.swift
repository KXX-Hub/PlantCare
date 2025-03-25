//
//  PlantCare_Watch_AppTests.swift
//  PlantCare Watch AppTests
//
//  Created by 洪畤鎧 on 2025/3/25.
//

import Testing
import XCTest
@testable import PlantCare_Watch_App

struct PlantCare_Watch_AppTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

final class PlantCare_Watch_AppTests: XCTestCase {
    func testWatchContentViewCreation() {
        if #available(watchOS 10.0, *) {
            // 創建視圖
            let contentView = WatchContentView()
            
            // 驗證視圖已創建
            XCTAssertNotNil(contentView)
            
            // 驗證 PlantManager 已初始化
            let mirror = Mirror(reflecting: contentView)
            let plantManager = mirror.children.first { $0.label == "_plantManager" }
            XCTAssertNotNil(plantManager)
        }
    }
}
