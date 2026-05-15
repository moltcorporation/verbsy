import Foundation
import UserNotifications

enum NotificationScheduler {
    static func scheduleDailyWordReminder() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else { return }

            center.removePendingNotificationRequests(withIdentifiers: ["verbsy.daily.word"])

            var date = DateComponents()
            date.hour = 8
            date.minute = 30

            let content = UNMutableNotificationContent()
            content.title = "Your Verbsy word is ready"
            content.body = "Take one minute to add a sharper word to your day."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let request = UNNotificationRequest(identifier: "verbsy.daily.word", content: content, trigger: trigger)
            try await center.add(request)
        } catch {
            // Notification permission is optional for the MVP.
        }
    }
}
