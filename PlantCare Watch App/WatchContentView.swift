//
//  WatchContentView.swift
//  PlantCare Watch App
//
//  Created by 洪畤鎧 on 2025/3/25.
//

import SwiftUI

// MARK: - 輔助函數
extension Color {
    static func growthPeriodColor(_ period: GrowthPeriod) -> Color {
        switch period {
        case .active:
            return .green
        case .dormant:
            return .orange
        case .transition:
            return .yellow
        }
    }
}

@available(watchOS 10.0, *)
struct WatchContentView: View {
    @StateObject private var plantManager = PlantManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 需要澆水的植物
            wateringList
                .tag(0)
            
            // 塊根植物列表
            caudexList
                .tag(1)
            
            // 統計資訊
            statsView
                .tag(2)
        }
    }
    
    // MARK: - 子視圖
    
    private var wateringList: some View {
        List {
            ForEach(plantManager.getPlantsNeedingWater()) { plant in
                PlantWateringRow(plant: plant, plantManager: plantManager)
            }
        }
        .listStyle(.carousel)
        .tabItem {
            Label("需要澆水", systemImage: "drop.fill")
        }
    }
    
    private var caudexList: some View {
        List {
            ForEach(plantManager.getCaudexPlants()) { plant in
                PlantDetailRow(plant: plant)
            }
        }
        .listStyle(.carousel)
        .tabItem {
            Label("塊根植物", systemImage: "leaf.circle.fill")
        }
    }
    
    private var statsView: some View {
        List {
            Section("生長狀態") {
                ForEach(GrowthPeriod.allCases, id: \.self) { period in
                    HStack {
                        Text(period.rawValue)
                            .foregroundStyle(Color.growthPeriodColor(period))
                        Spacer()
                        Text("\(plantManager.getPlantsByGrowthPeriod(period).count) 株")
                    }
                }
            }
            
            Section("塊根類型") {
                ForEach(CaudexType.allCases.filter { $0 != .none }, id: \.self) { type in
                    HStack {
                        Text(type.rawValue)
                        Spacer()
                        Text("\(plantManager.getPlantsByCaudexType(type).count) 株")
                    }
                }
            }
        }
        .listStyle(.carousel)
        .tabItem {
            Label("統計", systemImage: "chart.bar.fill")
        }
    }
}

// MARK: - 輔助視圖

struct PlantWateringRow: View {
    let plant: Plant
    let plantManager: PlantManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(plant.name)
                    .font(.headline)
                Text(plant.species)
                    .font(.caption2)
                if plant.isCaudexPlant {
                    Text(plant.growthPeriod.rawValue)
                        .font(.caption2)
                        .foregroundStyle(Color.growthPeriodColor(plant.growthPeriod))
                }
            }
            
            Spacer()
            
            Button(action: {
                plantManager.markAsWatered(plant)
            }) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
    }
}

struct PlantDetailRow: View {
    let plant: Plant
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(plant.name)
                .font(.headline)
            Text(plant.species)
                .font(.caption2)
            HStack {
                Text(plant.caudexType.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.green)
                Text(plant.growthPeriod.rawValue)
                    .font(.caption2)
                    .foregroundStyle(Color.growthPeriodColor(plant.growthPeriod))
            }
            Text("下次澆水：\(plant.nextWateringDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption2)
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    if #available(watchOS 10.0, *) {
        WatchContentView()
    } else {
        Text("需要 watchOS 10.0 或更新版本")
    }
}
