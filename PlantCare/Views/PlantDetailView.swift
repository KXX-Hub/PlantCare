import SwiftUI

struct PlantDetailView: View {
    let plant: Plant
    @ObservedObject var plantManager: PlantManager
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingPostponeSheet = false
    @State private var showingFertilizeSheet = false
    @State private var selectedWaterDate = Date()
    @State private var selectedFertilizeDate = Date()
    
    init(plant: Plant, plantManager: PlantManager) {
        self.plant = plant
        self._plantManager = ObservedObject(wrappedValue: plantManager)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageURL = plant.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.green)
                    }
                } else {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(plant.name)
                            .font(.title)
                            .bold()
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                plantManager.markAsWatered(plant)
                            }) {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            
                            if plant.isCaudexPlant {
                                Button(action: {
                                    plantManager.markAsFertilized(plant)
                                }) {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.orange)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    Text(plant.species)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(title: "澆水頻率", value: "\(plant.wateringFrequency)天")
                        InfoRow(title: "上次澆水", value: plant.lastWateredDate.formatted(date: .long, time: .omitted))
                        InfoRow(title: "下次澆水", value: plant.nextWateringDate.formatted(date: .long, time: .omitted))
                        InfoRow(title: "光照需求", value: plant.lightLevel.rawValue)
                        InfoRow(title: "濕度需求", value: plant.humidityLevel.rawValue)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    if plant.isCaudexPlant {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("塊根資訊")
                                .font(.headline)
                            InfoRow(title: "塊根類型", value: plant.caudexType.rawValue)
                            InfoRow(title: "生長期", value: plant.growthPeriod.rawValue)
                            if let lastFertilized = plant.lastFertilizedDate {
                                InfoRow(title: "上次施肥", value: lastFertilized.formatted(date: .long, time: .omitted))
                            }
                            if plant.needsFertilizer {
                                Text("需要施肥")
                                    .foregroundColor(.orange)
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    if !plant.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("備註")
                                .font(.headline)
                            Text(plant.notes)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
                              selection: $selectedWaterDate,
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
                            updatedPlant.nextWateringDate = selectedWaterDate
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

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
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
