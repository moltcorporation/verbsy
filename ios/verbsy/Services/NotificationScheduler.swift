import Foundation
import UserNotifications

enum NotificationScheduler {
    private static let center = UNUserNotificationCenter.current()
    private static let wordIdPrefix = "verbsy.word."
    private static let trialReminderId = "verbsy.trial.endsSoon"

    /// Ask for permission. Safe to call from onboarding; returns whether granted.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    /// Current system permission state, used to nudge users to enable in Settings.
    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    /// Schedule word-of-the-day notifications for the next stretch of days.
    /// iOS allows up to 64 pending notifications, so we cap and top up on launch.
    /// Each notification shows the word as the title and its short definition as
    /// the body. `perDay` reminders are spread from `startHour` toward evening.
    static func scheduleWordReminders(
        perDay: Int,
        startHour: Int,
        startMinute: Int,
        topics: [String],
        difficulties: [String]
    ) async {
        let granted = await requestAuthorization()
        guard granted else { return }

        // Build a varied, deterministic pool that respects the user's interests.
        var pool = VerbsyCatalog.feedPage(topics: topics, difficulties: difficulties, seed: "notifications", offset: 0, limit: 500)
        if pool.isEmpty { pool = VerbsyCatalog.words }
        guard !pool.isEmpty else { return }

        cancelWordReminders()

        let perDay = max(1, min(perDay, 5))
        let times = reminderTimes(startHour: startHour, startMinute: startMinute, perDay: perDay)
        let maxPending = 60
        let days = max(1, min(14, maxPending / perDay))

        let calendar = Calendar.current
        let now = Date()
        var wordIndex = (calendar.ordinality(of: .day, in: .era, for: now) ?? 0) % pool.count
        var scheduled = 0

        for dayOffset in 0..<days {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            for time in times {
                var comps = calendar.dateComponents([.year, .month, .day], from: dayDate)
                comps.hour = time.hour
                comps.minute = time.minute

                // Skip slots already in the past (e.g., earlier today).
                if let fire = calendar.date(from: comps), fire <= now { continue }

                let word = pool[wordIndex % pool.count]
                wordIndex += 1

                let content = UNMutableNotificationContent()
                content.title = word.word
                content.body = word.shortDefinition
                content.sound = .default

                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                let request = UNNotificationRequest(identifier: "\(wordIdPrefix)\(scheduled)", content: content, trigger: trigger)
                try? await center.add(request)
                scheduled += 1
            }
        }
    }

    /// Schedule a one-time reminder shortly before the free trial ends. This uses
    /// the StoreKit transaction expiration date, so sandbox renewals may be too
    /// accelerated to schedule a meaningful reminder.
    static func scheduleTrialEndingReminder(expirationDate: Date) async {
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: expirationDate) ?? expirationDate
        let now = Date()
        guard reminderDate > now.addingTimeInterval(60) else { return }

        let granted = await requestAuthorization()
        guard granted else { return }

        center.removePendingNotificationRequests(withIdentifiers: [trialReminderId])

        let content = UNMutableNotificationContent()
        content.title = "Your Verbsy Pro trial ends tomorrow"
        content.body = "Cancel anytime in Apple subscription settings before the trial ends."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminderDate.timeIntervalSince(now), repeats: false)
        let request = UNNotificationRequest(identifier: trialReminderId, content: content, trigger: trigger)
        try? await center.add(request)
    }

    static func cancelWordReminders() {
        let identifiers = (0..<160).map { "\(wordIdPrefix)\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    /// Evenly spread `perDay` reminders from the start time toward ~9pm.
    private static func reminderTimes(startHour: Int, startMinute: Int, perDay: Int) -> [(hour: Int, minute: Int)] {
        guard perDay > 1 else { return [(startHour, startMinute)] }
        let endHour = 21
        let span = max(endHour - startHour, perDay - 1)
        let step = max(1, span / (perDay - 1))
        return (0..<perDay).map { i in
            let hour = min(startHour + i * step, endHour)
            return (hour, i == 0 ? startMinute : 0)
        }
    }
}
