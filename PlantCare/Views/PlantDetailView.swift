import SwiftUI

struct PlantDetailView: View {
    let plant: Plant
    @ObservedObject var plantManager: PlantManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingPostponeSheet = false
    @State private var showingFertilizeSheet = false
    @State private var selectedDate = Date()
    @State private var selectedFertilizeDate = Date()
    @State private var isWateringPressed = false
    @State private var isFertilizingPressed = false
    
    init(plant: Plant, plantManager: PlantManager) {
        self.plant = plant
        self._plantManager = ObservedObject(wrappedValue: plantManager)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 頂部英雄區域
                ZStack(alignment: .bottom) {
                    // 背景漸層
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.7),
                            AppTheme.adaptiveBackground(colorScheme)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 300)
                    
                    // 植物圖示
                    VStack {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 120))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .padding(.top, 40)
                        
                        // 植物名稱和學名
                        VStack(spacing: 8) {
                            Text(plant.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(plant.species)
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.bottom, 30)
                    }
                }
                
                // 主要內容區域
                VStack(spacing: 25) {
                    // 快速操作按鈕
                    HStack(spacing: 30) {
                        // 澆水按鈕
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                isWateringPressed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                plantManager.markAsWatered(plant)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isWateringPressed = false
                                }
                            }
                        }) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.gradient1)
                                        .frame(width: 70, height: 70)
                                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(isWateringPressed ? 0.9 : 1.0)
                                
                                Text("澆水")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.adaptiveText(colorScheme))
                            }
                        }
                        
                        // 施肥按鈕
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                isFertilizingPressed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                plantManager.markAsFertilized(plant)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isFertilizingPressed = false
                                }
                            }
                        }) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.gradient2)
                                        .frame(width: 70, height: 70)
                                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                                    
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(isFertilizingPressed ? 0.9 : 1.0)
                                
                                Text("施肥")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.adaptiveText(colorScheme))
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // 資訊卡片區域
                    VStack(spacing: 16) {
                        // 澆水資訊卡片
                        InfoCard(title: "澆水資訊", icon: "drop.fill", color: .blue) {
                            InfoRow(title: "澆水頻率", value: "\(plant.wateringFrequency)天", color: .blue)
                            InfoRow(title: "上次澆水", value: plant.lastWateredDate.formatted(date: .abbreviated, time: .omitted))
                            InfoRow(title: "下次澆水", value: plant.nextWateringDate.formatted(date: .abbreviated, time: .omitted), color: .blue)
                        }
                        
                        // 施肥資訊卡片
                        InfoCard(title: "施肥資訊", icon: "leaf.fill", color: .orange) {
                            InfoRow(title: "施肥週期", value: "30天", color: .orange)
                            if let lastFertilizedDate = plant.lastFertilizedDate {
                                InfoRow(title: "上次施肥", value: lastFertilizedDate.formatted(date: .abbreviated, time: .omitted))
                                let nextFertilizeDate = Calendar.current.date(byAdding: .day, value: 30, to: lastFertilizedDate) ?? Date()
                                InfoRow(title: "下次施肥", value: nextFertilizeDate.formatted(date: .abbreviated, time: .omitted), color: .orange)
                            } else {
                                InfoRow(title: "上次施肥", value: "尚未施肥", color: .secondary)
                                InfoRow(title: "下次施肥", value: "請先施肥", color: .secondary)
                            }
                        }
                        
                        // 生長資訊卡片
                        InfoCard(title: "生長資訊", icon: "sparkles", color: .purple) {
                            if plant.isCaudexPlant {
                                InfoRow(title: "塊根類型", value: plant.caudexType.rawValue)
                                InfoRow(title: "生長期", value: plant.growthPeriod.rawValue)
                            }
                            InfoRow(title: "光照需求", value: plant.lightLevel.rawValue)
                            InfoRow(title: "濕度需求", value: plant.humidityLevel.rawValue)
                        }
                        
                        // 備註卡片
                        if !plant.notes.isEmpty {
                            InfoCard(title: "備註", icon: "note.text", color: .gray) {
                                Text(plant.notes)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.adaptiveBackground(colorScheme))
        .toolbar {
            Menu {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Label("編輯", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    showingDeleteAlert = true
                }) {
                    Label("刪除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPlantView(plant: plant, plantManager: plantManager)
        }
        .sheet(isPresented: $showingPostponeSheet) {
            NavigationView {
                Form {
                    DatePicker("選擇日期",
                              selection: $selectedDate,
                              in: Date()...,
                              displayedComponents: .date)
                }
                .navigationTitle("調整澆水時間")
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
                .navigationTitle("調整施肥時間")
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
        .alert("刪除植物", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("刪除", role: .destructive) {
                plantManager.deletePlant(plant)
            }
        } message: {
            Text("確定要刪除「\(plant.name)」嗎？此動作無法復原。")
        }
    }
}

// 資訊卡片元件
struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme
    
    init(title: String, icon: String, color: Color = .blue, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題列
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.adaptiveSurface(colorScheme))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// 資訊列元件
struct InfoRow: View {
    let title: String
    let value: String
    let color: Color?
    
    init(title: String, value: String, color: Color? = nil) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(color ?? .primary)
                .fontWeight(.medium)
        }
        .font(.system(size: 16))
    }
}

struct EditPlantView: View {
    @Environment(\.dismiss) private var dismiss
    let plant: Plant
    @ObservedObject var plantManager: PlantManager
    
    @State private var name: String
    @State private var species: String
    @State private var wateringFrequency: Int
    @State private var notes: String
    @State private var lightLevel: LightLevel
    @State private var humidityLevel: HumidityLevel
    @State private var caudexType: CaudexType
    @State private var growthPeriod: GrowthPeriod
    @State private var lastFertilizedDate: Date?
    
    init(plant: Plant, plantManager: PlantManager) {
        self.plant = plant
        self.plantManager = plantManager
        _name = State(initialValue: plant.name)
        _species = State(initialValue: plant.species)
        _wateringFrequency = State(initialValue: plant.wateringFrequency)
        _notes = State(initialValue: plant.notes)
        _lightLevel = State(initialValue: plant.lightLevel)
        _humidityLevel = State(initialValue: plant.humidityLevel)
        _caudexType = State(initialValue: plant.caudexType)
        _growthPeriod = State(initialValue: plant.growthPeriod)
        _lastFertilizedDate = State(initialValue: plant.lastFertilizedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本資訊") {
                    TextField("植物名稱", text: $name)
                    TextField("品種", text: $species)
                    Stepper("澆水頻率：\(wateringFrequency)天", value: $wateringFrequency, in: 1...30)
                }
                
                Section("塊根資訊") {
                    Picker("塊根類型", selection: $caudexType) {
                        ForEach(CaudexType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("生長期", selection: $growthPeriod) {
                        ForEach(GrowthPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    
                    if caudexType != .none {
                        DatePicker("最後施肥日期", selection: Binding(
                            get: { lastFertilizedDate ?? Date() },
                            set: { lastFertilizedDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                Section("照護需求") {
                    Picker("光照需求", selection: $lightLevel) {
                        ForEach(LightLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("濕度需求", selection: $humidityLevel) {
                        ForEach(HumidityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                Section("備註") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("編輯植物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || species.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedPlant = plant
        updatedPlant.name = name
        updatedPlant.species = species
        updatedPlant.wateringFrequency = wateringFrequency
        updatedPlant.notes = notes
        updatedPlant.lightLevel = lightLevel
        updatedPlant.humidityLevel = humidityLevel
        updatedPlant.caudexType = caudexType
        updatedPlant.growthPeriod = growthPeriod
        updatedPlant.lastFertilizedDate = lastFertilizedDate
        
        plantManager.updatePlant(updatedPlant)
        dismiss()
    }
}

#Preview {
    NavigationView {
        PlantDetailView(
            plant: Plant(
                name: "測試植物",
                species: "測試品種",
                wateringFrequency: 7,
                notes: "這是一個測試植物的備註。",
                caudexType: .aboveGround,
                growthPeriod: .active,
                lastFertilizedDate: Date()
            ),
            plantManager: PlantManager()
        )
    }
} 
