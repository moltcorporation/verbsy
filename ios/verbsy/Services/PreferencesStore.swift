import Foundation
import Combine

/// User content preferences — chosen topics + difficulty. No account; persisted
/// locally and used to personalize the feed and quiz. An empty `selectedTopics`
/// means "Surprise me" (all topics, fully mixed).
@MainActor
final class PreferencesStore: ObservableObject {
    @Published var selectedTopics: [String] { didSet { save() } }
    @Published var difficulties: [String] { didSet { save() } }

    static let allDifficulties = ["casual", "curious", "advanced"]

    private let topicsKey = "verbsy.prefs.topics"
    private let difficultiesKey = "verbsy.prefs.difficulties"

    init() {
        let defaults = UserDefaults.standard
        selectedTopics = defaults.stringArray(forKey: topicsKey) ?? []
        difficulties = defaults.stringArray(forKey: difficultiesKey) ?? Self.allDifficulties
    }

    /// True when no topic filter is applied — the feed is fully mixed.
    var isSurpriseMe: Bool { selectedTopics.isEmpty }

    /// Difficulties to send to the API; empty selection is treated as all.
    var effectiveDifficulties: [String] {
        difficulties.isEmpty ? Self.allDifficulties : difficulties
    }

    func setTopics(_ topics: [String]) {
        selectedTopics = topics
    }

    func toggleDifficulty(_ difficulty: String) {
        if difficulties.contains(difficulty) {
            // Never allow an empty difficulty set; keep at least one.
            if difficulties.count > 1 { difficulties.removeAll { $0 == difficulty } }
        } else {
            difficulties.append(difficulty)
        }
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(selectedTopics, forKey: topicsKey)
        defaults.set(difficulties, forKey: difficultiesKey)
    }
}
