import SwiftUI

// 定義全局顏色主題
struct AppTheme {
    // 主色調
    static let primary = Color(hex: "94A89A")      // 柔和的灰綠
    static let secondary = Color(hex: "D5B8B5")    // 柔和的玫瑰色
    static let accent = Color(hex: "A7BEAE")       // 淺灰綠
    
    // 背景色
    static let background = Color(hex: "1F2124")   // 深色背景
    static let surface = Color(hex: "2A2D31")      // 淺灰表面
    static let surfaceLight = Color(hex: "383B40") // 更淺的表面色
    
    // 文字顏色
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.7)
    
    // 漸層
    static let gradient1 = LinearGradient(
        colors: [Color(hex: "94A89A"), Color(hex: "A7BEAE")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradient2 = LinearGradient(
        colors: [Color(hex: "D5B8B5"), Color(hex: "C2A8A5")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // 卡片背景
    static let cardBackground = Color(hex: "2A2D31").opacity(0.95)
    
    // 環境自適應顏色
    @ViewBuilder
    static func adaptiveBackground(_ colorScheme: ColorScheme) -> some View {
        if colorScheme == .dark {
            background
        } else {
            Color.white
        }
    }
    
    static func adaptiveSurface(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? surface : Color(hex: "F5F5F5")
    }
    
    static func adaptiveText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textPrimary : Color.black.opacity(0.85)
    }
    
    static func adaptiveSecondaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textSecondary : Color.black.opacity(0.6)
    }
    
    static func adaptiveCardBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? cardBackground : Color.white
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GlassMorphicBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
    }
}

extension View {
    func glassMorphic() -> some View {
        modifier(GlassMorphicBackground())
    }
}

struct ContentView: View {
    @StateObject private var plantManager = PlantManager()
    @State private var selectedTab = 0
    @State private var showingAddPlant = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlantListView(plantManager: plantManager, showingAddPlant: $showingAddPlant)
                .tabItem {
                    Label("我的植物", systemImage: "leaf.fill")
                }
                .tag(0)
            
            PlantCareView(plantManager: plantManager)
                .tabItem {
                    Label("照護提醒", systemImage: "bell.fill")
                }
                .badge(plantManager.getPlantsNeedingWater().count + plantManager.getPlantsNeedingFertilizer().count)
                .tag(1)
            
            PlantStatsView(plantManager: plantManager)
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
        .tint(AppTheme.accent)
        .sheet(isPresented: $showingAddPlant) {
            AddPlantView(plantManager: plantManager)
        }
        .background(AppTheme.adaptiveSurface(colorScheme))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
    }
}

struct PlantListView: View {
    @ObservedObject var plantManager: PlantManager
    @Binding var showingAddPlant: Bool
    @State private var selectedCaudexType: CaudexType?
    @State private var selectedGrowthPeriod: GrowthPeriod?
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false
    
    var filteredPlants: [Plant] {
        var plants = plantManager.plants
        
        if let caudexType = selectedCaudexType {
            plants = plants.filter { $0.caudexType == caudexType }
        }
        
        if let growthPeriod = selectedGrowthPeriod {
            plants = plants.filter { $0.growthPeriod == growthPeriod }
        }
        
        return plants
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.adaptiveBackground(colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Menu {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedCaudexType = nil
                                    }
                                }) {
                                    Label("全部", systemImage: selectedCaudexType == nil ? "checkmark" : "")
                                }
                                
                                ForEach(CaudexType.allCases, id: \.self) { type in
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            selectedCaudexType = type
                                        }
                                    }) {
                                        Label(type.rawValue, systemImage: selectedCaudexType == type ? "checkmark" : "")
                                    }
                                }
                            } label: {
                                Label(selectedCaudexType?.rawValue ?? "塊根類型", systemImage: "leaf.fill")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.adaptiveSurface(colorScheme))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Menu {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedGrowthPeriod = nil
                                    }
                                }) {
                                    Label("全部", systemImage: selectedGrowthPeriod == nil ? "checkmark" : "")
                                }
                                
                                ForEach(GrowthPeriod.allCases, id: \.self) { period in
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            selectedGrowthPeriod = period
                                        }
                                    }) {
                                        Label(period.rawValue, systemImage: selectedGrowthPeriod == period ? "checkmark" : "")
                                    }
                                }
                            } label: {
                                Label(selectedGrowthPeriod?.rawValue ?? "生長期", systemImage: "calendar")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.adaptiveSurface(colorScheme))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if filteredPlants.isEmpty {
                        ContentUnavailableView {
                            Label("尚未添加植物", systemImage: "leaf")
                                .font(.title2)
                                .foregroundColor(AppTheme.adaptiveText(colorScheme))
                        } description: {
                            Text("點擊右上角的 + 按鈕來添加植物")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                isAnimating = true
                            }
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredPlants) { plant in
                                    NavigationLink(destination: PlantDetailView(plant: plant, plantManager: plantManager)) {
                                        PlantRowView(plant: plant, plantManager: plantManager)
                                            .transition(.asymmetric(
                                                insertion: .scale.combined(with: .opacity),
                                                removal: .opacity.combined(with: .scale(scale: 0.8))
                                            ))
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("我的植物")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showingAddPlant = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(AppTheme.adaptiveText(colorScheme))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(AppTheme.adaptiveSurface(colorScheme))
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.accent : AppTheme.surface)
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .cornerRadius(12)
        }
    }
}

struct PlantStatsView: View {
    @ObservedObject var plantManager: PlantManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedSection = 0
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.adaptiveBackground(colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 總覽卡片
                        VStack(alignment: .leading, spacing: 8) {
                            Text("植物總數")
                                .font(.headline)
                                .foregroundColor(AppTheme.adaptiveText(colorScheme))
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(plantManager.plants.count)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(AppTheme.adaptiveText(colorScheme))
                                    Text("株植物")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
                                }
                                Spacer()
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.accent)
                                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            }
                        }
                        .padding()
                        .background(AppTheme.adaptiveSurface(colorScheme))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // 分類統計
                        VStack(spacing: 16) {
                            statsSection("塊根植物", data: CaudexType.allCases.filter { $0 != .none }.map { type in
                                (type.rawValue, plantManager.getPlantsByCaudexType(type).count)
                            })
                            
                            statsSection("生長期", data: GrowthPeriod.allCases.map { period in
                                (period.rawValue, plantManager.getPlantsByGrowthPeriod(period).count)
                            })
                            
                            statsSection("光照需求", data: LightLevel.allCases.map { level in
                                (level.rawValue, plantManager.getPlantsByLightLevel(level).count)
                            })
                            
                            statsSection("濕度需求", data: HumidityLevel.allCases.map { level in
                                (level.rawValue, plantManager.getPlantsByHumidityLevel(level).count)
                            })
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.spring(response: 1, dampingFraction: 0.6).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
        }
    }
    
    private func statsSection(_ title: String, data: [(String, Int)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.adaptiveText(colorScheme))
            
            ForEach(data, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .foregroundColor(AppTheme.adaptiveText(colorScheme))
                    Spacer()
                    Text("\(item.1) 株")
                        .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(AppTheme.adaptiveSurface(colorScheme))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(AppTheme.adaptiveSurface(colorScheme))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ContentView()
} 
