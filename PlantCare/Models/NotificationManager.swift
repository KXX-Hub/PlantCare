import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleWateringNotification(for plant: Plant) {
        let content = UNMutableNotificationContent()
        content.title = "需要澆水"
        content.body = "\(plant.name) 需要澆水了"
        content.sound = .default
        
        // 設置通知時間（下次澆水日期）
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: plant.nextWateringDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // 創建通知請求
        let request = UNNotificationRequest(
            identifier: "watering-\(plant.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // 添加通知
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleFertilizingNotification(for plant: Plant) {
        guard plant.isCaudexPlant else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "需要施肥"
        content.body = "\(plant.name) 需要施肥了"
        content.sound = .default
        
        // 計算下次施肥日期（上次施肥後30天）
        let nextFertilizingDate = Calendar.current.date(byAdding: .day, value: 30, to: plant.lastFertilizedDate ?? Date()) ?? Date()
        
        // 設置通知時間
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextFertilizingDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // 創建通知請求
        let request = UNNotificationRequest(
            identifier: "fertilizing-\(plant.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // 添加通知
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotifications(for plant: Plant) {
        // 取消澆水通知
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["watering-\(plant.id.uuidString)"])
        
        // 取消施肥通知
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["fertilizing-\(plant.id.uuidString)"])
    }
    
    func rescheduleAllNotifications(for plants: [Plant]) {
        // 清除所有待處理的通知
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // 重新安排所有植物的通知
        for plant in plants {
            scheduleWateringNotification(for: plant)
            if plant.isCaudexPlant {
                scheduleFertilizingNotification(for: plant)
            }
        }
    }
} 
