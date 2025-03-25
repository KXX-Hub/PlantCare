import SwiftUI

struct PlantCareView: View {
    @ObservedObject var plantManager: PlantManager
    @State private var selectedFilter: CareFilter = .all
    @State private var isButtonPressed = false
    @State private var isAnimating = false
    @State private var selectedPlantId: String?
    @Environment(\.colorScheme) private var colorScheme
    
    enum CareFilter: String, CaseIterable {
        case all = "全部"
        case watering = "需要澆水"
        case fertilizing = "需要施肥"
    }
    
    var filteredPlants: [Plant] {
        switch selectedFilter {
        case .all:
            return plantManager.getPlantsNeedingWater() + plantManager.getPlantsNeedingFertilizer()
        case .watering:
            return plantManager.getPlantsNeedingWater()
        case .fertilizing:
            return plantManager.getPlantsNeedingFertilizer()
        }
    }
    
    var buttonTitle: String {
        switch selectedFilter {
        case .watering: return "一鍵澆水"
        case .fertilizing: return "一鍵施肥"
        case .all: return "一鍵照護"
        }
    }
    
    var buttonIcon: String {
        switch selectedFilter {
        case .watering: return "drop.fill"
        case .fertilizing: return "leaf.fill"
        case .all: return "wand.and.stars"
        }
    }
    
    var buttonBackground: LinearGradient {
        switch selectedFilter {
        case .watering: return AppTheme.gradient1
        case .fertilizing: return AppTheme.gradient2
        case .all: return LinearGradient(colors: [AppTheme.primary, AppTheme.accent],
                                       startPoint: .leading,
                                       endPoint: .trailing)
        }
    }
    
    var emptyStateMessage: String {
        switch selectedFilter {
        case .watering: return "沒有需要澆水的植物"
        case .fertilizing: return "沒有需要施肥的植物"
        case .all: return "目前沒有照護提醒"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.adaptiveBackground(colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    filterPicker
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -20)
                    
                    if !filteredPlants.isEmpty {
                        quickCareButton
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                    }
                    
                    if filteredPlants.isEmpty {
                        emptyStateView
                            .opacity(isAnimating ? 1 : 0)
                            .scaleEffect(isAnimating ? 1 : 0.8)
                    } else {
                        plantList
                            .opacity(isAnimating ? 1 : 0)
                    }
                }
            }
            .navigationTitle("照護提醒")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppTheme.adaptiveSurface(colorScheme))
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isAnimating = true
                }
            }
            .onDisappear {
                isAnimating = false
            }
        }
    }
    
    private var filterPicker: some View {
        Picker("照護類型", selection: $selectedFilter) {
            ForEach(CareFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue)
                    .font(.headline)
                    .foregroundColor(AppTheme.adaptiveText(colorScheme))
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top)
        .onChange(of: selectedFilter) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                // 重置選中的植物
                selectedPlantId = nil
            }
        }
    }
    
    private var quickCareButton: some View {
        Button(action: performQuickCare) {
            Label(buttonTitle, systemImage: buttonIcon)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(
                    buttonBackground
                        .overlay(
                            Color.white
                                .opacity(isButtonPressed ? 0.2 : 0)
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.1),
                       radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.2 : 0.1),
                               lineWidth: 1)
                )
        }
        .scaleEffect(isButtonPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isButtonPressed)
        .padding(.horizontal)
    }
    
    private var plantList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredPlants) { plant in
                    NavigationLink(destination: PlantDetailView(plant: plant, plantManager: plantManager)) {
                        CareAlertRow(
                            plant: plant,
                            type: getCareType(for: plant),
                            plantManager: plantManager
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(emptyStateMessage, systemImage: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(AppTheme.adaptiveText(colorScheme))
        } description: {
            Text("所有植物都已經得到照顧了")
                .font(.subheadline)
                .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
        }
    }
    
    private func getCareType(for plant: Plant) -> CareAlertRow.CareType {
        switch selectedFilter {
        case .fertilizing:
            return .fertilizing
        case .watering:
            return .watering
        case .all:
            return plant.needsFertilizer ? .fertilizing : .watering
        }
    }
    
    private func performQuickCare() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isButtonPressed = true
            
            // 為每個植物添加延遲動畫
            for (index, plant) in filteredPlants.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if selectedFilter == .watering || selectedFilter == .all {
                            plantManager.markAsWatered(plant)
                        }
                        if (selectedFilter == .fertilizing || selectedFilter == .all) && plant.isCaudexPlant {
                            plantManager.markAsFertilized(plant)
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isButtonPressed = false
            }
        }
    }
}

#Preview {
    PlantCareView(plantManager: PlantManager())
} 
