import Foundation

struct VerbsyWord: Codable, Identifiable, Hashable {
    let id: Int
    let slug: String
    let word: String
    let pronunciation: String
    let partOfSpeech: String
    let shortDefinition: String
    let longDefinition: String
    let example: String
    let secondExample: String?
    let useCase: String
    let difficulty: String
    let topics: [String]
    let emotionalTone: String?
    let isPremium: Bool

    static let fallback = VerbsyWord(
        id: 0,
        slug: "sonder",
        word: "Sonder",
        pronunciation: "SAHN-der",
        partOfSpeech: "noun",
        shortDefinition: "The realization that every person has a vivid inner life.",
        longDefinition: "The sudden awareness that every stranger has a private world as complex and meaningful as your own.",
        example: "Walking through the airport, she felt sonder as each face passed with its own hidden story.",
        secondExample: "A moment of sonder made the disagreement feel less personal.",
        useCase: "Use it when empathy arrives all at once.",
        difficulty: "curious",
        topics: ["Psychology", "Emotions", "Relationships"],
        emotionalTone: "empathetic",
        isPremium: true
    )
}

struct VerbsyBootstrap: Codable {
    let serverDate: String
    let contentVersion: String
    let productIds: ProductIds
    let topics: [String]
    let dailyWord: VerbsyWord?
}

struct ProductIds: Codable {
    let weekly: String
    let monthly: String
    let annual: String
}

struct DailyWordResponse: Codable {
    let date: String
    let word: VerbsyWord
}

struct WordListResponse: Codable {
    let words: [VerbsyWord]
    let nextCursor: Int?
}

struct LocalProgress: Codable {
    var savedSlugs: Set<String> = []
    var learnedSlugs: Set<String> = []
    var learnedDates: Set<String> = []
    var quizCorrect: Int = 0
    var quizAttempts: Int = 0
    var reviewResults: [String: ReviewMemory] = [:]

    var streak: Int {
        let calendar = Calendar.current
        var count = 0
        var cursor = calendar.startOfDay(for: Date())

        while learnedDates.contains(Self.key(for: cursor)) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return count
    }

    static func key(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct ReviewMemory: Codable, Hashable {
    var attempts: Int = 0
    var correct: Int = 0
    var lastReviewedAt: Date?

    var accuracy: Double {
        guard attempts > 0 else { return 0 }
        return Double(correct) / Double(attempts)
    }
}

struct ReviewQuestion: Identifiable, Hashable {
    let id = UUID()
    let word: VerbsyWord
    let choices: [VerbsyWord]
}
