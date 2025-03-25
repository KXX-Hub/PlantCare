import SwiftUI
import PhotosUI

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var plantManager: PlantManager
    
    @State private var name = ""
    @State private var species = ""
    @State private var wateringFrequency = 7
    @State private var notes = ""
    @State private var lightLevel = LightLevel.medium
    @State private var humidityLevel = HumidityLevel.medium
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    @State private var caudexType = CaudexType.none
    @State private var growthPeriod = GrowthPeriod.active
    @State private var lastFertilizedDate: Date?
    
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
                
                Section("照片") {
                    PhotosPicker(selection: $selectedItem,
                               matching: .images) {
                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        } else {
                            ContentUnavailableView("選擇照片", systemImage: "photo.badge.plus")
                        }
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
            .navigationTitle("新增植物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("新增") {
                        savePlant()
                    }
                    .disabled(name.isEmpty || species.isEmpty)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    private func savePlant() {
        let plant = Plant(
            name: name,
            species: species,
            wateringFrequency: wateringFrequency,
            notes: notes,
            lightLevel: lightLevel,
            humidityLevel: humidityLevel,
            caudexType: caudexType,
            growthPeriod: growthPeriod,
            lastFertilizedDate: lastFertilizedDate
        )
        
        plantManager.addPlant(plant)
        dismiss()
    }
}

#Preview {
    AddPlantView(plantManager: PlantManager())
} 
