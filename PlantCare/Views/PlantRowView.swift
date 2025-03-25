import SwiftUI

struct PlantRowView: View {
    let plant: Plant
    let plantManager: PlantManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingPostponeSheet = false
    @State private var showingFertilizeSheet = false
    @State private var selectedDate = Date()
    @State private var selectedFertilizeDate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 植物名稱
            Text(plant.name)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.adaptiveText(colorScheme))
            
            // 學名
            Text(plant.species)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
            
            HStack(spacing: 12) {
                // 下次澆水日期
                HStack(spacing: 4) {
                    Text("下次澆水：")
                        .font(.system(size: 16, weight: .medium))
                    Text(plant.nextWateringDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                if plant.isCaudexPlant {
                    // 塊根類型和生長期
                    HStack(spacing: 4) {
                        Text(plant.caudexType.rawValue)
                            .font(.system(size: 16, weight: .medium))
                        Text("·")
                        Text(plant.growthPeriod.rawValue)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Menu {
                    Button(action: {
                        plantManager.markAsWatered(plant)
                    }) {
                        Label("現在澆水", systemImage: "drop.fill")
                    }
                    
                    Button(action: {
                        var updatedPlant = plant
                        updatedPlant.nextWateringDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                        plantManager.updatePlant(updatedPlant)
                    }) {
                        Label("明天再澆", systemImage: "calendar.badge.plus")
                    }
                    
                    Button(action: {
                        showingPostponeSheet = true
                    }) {
                        Label("延後澆水", systemImage: "calendar")
                    }
                } label: {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                }
                
                if plant.isCaudexPlant {
                    Menu {
                        Button(action: {
                            plantManager.markAsFertilized(plant)
                        }) {
                            Label("現在施肥", systemImage: "leaf.fill")
                        }
                        
                        Button(action: {
                            var updatedPlant = plant
                            updatedPlant.lastFertilizedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                            plantManager.updatePlant(updatedPlant)
                        }) {
                            Label("明天施肥", systemImage: "calendar.badge.plus")
                        }
                        
                        Button(action: {
                            showingFertilizeSheet = true
                        }) {
                            Label("延後施肥", systemImage: "calendar")
                        }
                    } label: {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.adaptiveSurface(colorScheme))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .sheet(isPresented: $showingPostponeSheet) {
            NavigationView {
                Form {
                    DatePicker("選擇日期",
                              selection: $selectedDate,
                              in: Date()...,
                              displayedComponents: .date)
                }
                .navigationTitle("延後澆水")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showingPostponeSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("確定") {
                            var updatedPlant = plant
                            updatedPlant.nextWateringDate = selectedDate
                            plantManager.updatePlant(updatedPlant)
                            showingPostponeSheet = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingFertilizeSheet) {
            NavigationView {
                Form {
                    DatePicker("選擇日期",
                              selection: $selectedFertilizeDate,
                              in: Date()...,
                              displayedComponents: .date)
                }
                .navigationTitle("延後施肥")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showingFertilizeSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("確定") {
                            var updatedPlant = plant
                            updatedPlant.lastFertilizedDate = selectedFertilizeDate
                            plantManager.updatePlant(updatedPlant)
                            showingFertilizeSheet = false
                        }
                    }
                }
            }
        }
    }
} 
