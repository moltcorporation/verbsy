import Foundation
import Combine

@MainActor
final class LocalProgressStore: ObservableObject {
    @Published private(set) var progress = LocalProgress()

    private let key = "verbsy.local.progress"

    init() {
        load()
    }

    func isSaved(_ word: VerbsyWord) -> Bool {
        progress.savedSlugs.contains(word.slug)
    }

    func toggleSaved(_ word: VerbsyWord) {
        if progress.savedSlugs.contains(word.slug) {
            progress.savedSlugs.remove(word.slug)
        } else {
            progress.savedSlugs.insert(word.slug)
        }
        save()
    }

    func isLearned(_ word: VerbsyWord) -> Bool {
        progress.learnedSlugs.contains(word.slug)
    }

    func markLearned(_ word: VerbsyWord) {
        progress.learnedSlugs.insert(word.slug)
        progress.learnedDates.insert(LocalProgress.key(for: Date()))
        save()
    }

    func recordQuiz(word: VerbsyWord, correct: Bool) {
        progress.quizAttempts += 1
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
        save()
    }

    func reviewMemory(for word: VerbsyWord) -> ReviewMemory? {
        progress.reviewResults[word.slug]
    }

    func resetAll() {
        progress = LocalProgress()
        save()
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
