//
//  PlantCareApp.swift
//  PlantCare Watch App
//
//  Created by 洪畤鎧 on 2025/3/25.
//

import SwiftUI

@main
struct PlantCare_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(watchOS 10.0, *) {
                WatchContentView()
            } else {
                Text("需要 watchOS 10.0 或更新版本")
            }
        }
    }
}
