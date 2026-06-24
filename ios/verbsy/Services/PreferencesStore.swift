import Foundation
import Combine

/// User content preferences — chosen topics + difficulty. No account; persisted
/// locally and used to personalize the feed and quiz. An empty `selectedTopics`
/// means "Surprise me" (all topics, fully mixed).
@MainActor
final class PreferencesStore: ObservableObject {
    @Published var selectedTopics: [String] { didSet { save() } }
    @Published var difficultyLevel: String { didSet { save() } }

    // Word-of-the-day notification settings (Pro only). Default: 1 word at 9:00am.
    @Published var wordsPerDay: Int { didSet { save() } }
    @Published var reminderHour: Int { didSet { save() } }
    @Published var reminderMinute: Int { didSet { save() } }

    nonisolated static let allDifficulties = ["casual", "curious", "advanced"]

    private let topicsKey = "verbsy.prefs.topics"
    private let difficultyLevelKey = "verbsy.prefs.difficultyLevel"
    private let wordsPerDayKey = "verbsy.prefs.wordsPerDay"
    private let reminderHourKey = "verbsy.prefs.reminderHour"
    private let reminderMinuteKey = "verbsy.prefs.reminderMinute"

    init() {
        let defaults = UserDefaults.standard
        selectedTopics = defaults.stringArray(forKey: topicsKey) ?? []
        difficultyLevel = Self.validLevel(defaults.string(forKey: difficultyLevelKey)) ?? "advanced"
        wordsPerDay = defaults.object(forKey: wordsPerDayKey) as? Int ?? 1
        reminderHour = defaults.object(forKey: reminderHourKey) as? Int ?? 9
        reminderMinute = defaults.object(forKey: reminderMinuteKey) as? Int ?? 0
    }

    /// Map an onboarding vocabulary level to an inclusive difficulty set.
    func applyLevel(_ level: String) {
        guard let level = Self.validLevel(level) else { return }
        difficultyLevel = level
    }

    /// True when no topic filter is applied — the feed is fully mixed.
    var isSurpriseMe: Bool { selectedTopics.isEmpty }

    /// Difficulties to send to the API; empty selection is treated as all.
    var effectiveDifficulties: [String] {
        switch difficultyLevel {
        case "casual": return ["casual"]
        case "curious": return ["curious", "casual"]
        case "advanced": return ["advanced", "curious", "casual"]
        default: return Self.allDifficulties
        }
    }

    func setTopics(_ topics: [String]) {
        selectedTopics = topics
    }

    func setDifficultyLevel(_ difficulty: String) {
        applyLevel(difficulty)
    }

    private static func validLevel(_ value: String?) -> String? {
        guard let value = value?.lowercased(), allDifficulties.contains(value) else { return nil }
        return value
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(selectedTopics, forKey: topicsKey)
        defaults.set(difficultyLevel, forKey: difficultyLevelKey)
        defaults.set(wordsPerDay, forKey: wordsPerDayKey)
        defaults.set(reminderHour, forKey: reminderHourKey)
        defaults.set(reminderMinute, forKey: reminderMinuteKey)
    }
}
