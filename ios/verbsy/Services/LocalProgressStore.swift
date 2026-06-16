import Foundation
import Combine

@MainActor
final class LocalProgressStore: ObservableObject {
    @Published private(set) var progress = LocalProgress()

    private let key = "verbsy.local.progress"

    init() {
        load()
    }

    // MARK: Favorites

    func isFavorite(_ word: VerbsyWord) -> Bool {
        progress.favoriteSlugs.contains(word.slug)
    }

    func toggleFavorite(_ word: VerbsyWord) {
        if progress.favoriteSlugs.contains(word.slug) {
            progress.favoriteSlugs.remove(word.slug)
        } else {
            progress.favoriteSlugs.insert(word.slug)
        }
        save()
    }

    // MARK: Learning activity (drives stats + streak)

    /// Call when a feed card becomes the active full-screen card.
    func recordSeen(_ word: VerbsyWord) {
        guard !progress.seenSlugs.contains(word.slug) else { return }
        let today = LocalProgress.key(for: Date())
        progress.seenSlugs.insert(word.slug)
        progress.seenByDate[today, default: 0] += 1
        refreshActive(for: today)
        save()
    }

    func recordQuiz(word: VerbsyWord, correct: Bool) {
        let today = LocalProgress.key(for: Date())
        progress.quizAttempts += 1
        progress.quizByDate[today, default: 0] += 1
        if correct {
            progress.quizCorrect += 1
        }
        var memory = progress.reviewResults[word.slug] ?? ReviewMemory()
        memory.attempts += 1
        if correct {
            memory.correct += 1
        }
        memory.lastReviewedAt = Date()
        progress.reviewResults[word.slug] = memory
        refreshActive(for: today)
        save()
    }

    func reviewMemory(for word: VerbsyWord) -> ReviewMemory? {
        progress.reviewResults[word.slug]
    }

    func resetAll() {
        progress = LocalProgress()
        save()
    }

    // A day counts toward the streak once the user has met the daily goal,
    // through new words seen or quiz questions answered.
    private func refreshActive(for day: String) {
        let seen = progress.seenByDate[day] ?? 0
        let quizzed = progress.quizByDate[day] ?? 0
        if seen >= LocalProgress.dailyGoal || quizzed >= LocalProgress.dailyGoal {
            progress.activeDates.insert(day)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode(LocalProgress.self, from: data)
        else { return }
        progress = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
