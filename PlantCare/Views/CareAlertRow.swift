import SwiftUI

struct CareAlertRow: View {
    let plant: Plant
    let type: CareType
    let plantManager: PlantManager
    @Environment(\.colorScheme) private var colorScheme
    
    enum CareType {
        case watering
        case fertilizing
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 植物名稱和圖標
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plant.name)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppTheme.adaptiveText(colorScheme))
                    
                    Text(plant.species)
                        .font(.system(size: 17))
                        .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
                }
                
                Spacer()
                
                // 照護類型圖標
                Image(systemName: type == .watering ? "drop.fill" : "leaf.fill")
                    .font(.system(size: 24))
                    .foregroundColor(type == .watering ? .blue : .orange)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(type == .watering ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                    )
            }
            
            // 照護資訊
            HStack(spacing: 16) {
                if type == .watering {
                    Label("需要澆水", systemImage: "drop.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                } else {
                    Label("需要施肥", systemImage: "leaf.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.orange)
                }
                
                if plant.isCaudexPlant {
                    Text("·")
                        .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
                    Text("\(plant.caudexType.rawValue) · \(plant.growthPeriod.rawValue)")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.adaptiveSecondaryText(colorScheme))
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
                .stroke(
                    type == .watering ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
} 
