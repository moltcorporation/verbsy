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
    let origin: String?
    let synonyms: [String]
    let difficulty: String
    let topics: [String]
    let emotionalTone: String?
    let isPremium: Bool

    init(
        id: Int,
        slug: String,
        word: String,
        pronunciation: String,
        partOfSpeech: String,
        shortDefinition: String,
        longDefinition: String,
        example: String,
        secondExample: String?,
        useCase: String,
        origin: String? = nil,
        synonyms: [String] = [],
        difficulty: String,
        topics: [String],
        emotionalTone: String?,
        isPremium: Bool = true
    ) {
        self.id = id
        self.slug = slug
        self.word = word
        self.pronunciation = pronunciation
        self.partOfSpeech = partOfSpeech
        self.shortDefinition = shortDefinition
        self.longDefinition = longDefinition
        self.example = example
        self.secondExample = secondExample
        self.useCase = useCase
        self.origin = origin
        self.synonyms = synonyms
        self.difficulty = difficulty
        self.topics = topics
        self.emotionalTone = emotionalTone
        self.isPremium = isPremium
    }

    // Lenient decoding so the same model handles the API payload and the bundled
    // words.json (which omits `id` / `isPremium`) and survives future field additions.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        slug = try c.decode(String.self, forKey: .slug)
        id = try c.decodeIfPresent(Int.self, forKey: .id) ?? abs(slug.hashValue)
        word = try c.decode(String.self, forKey: .word)
        pronunciation = try c.decode(String.self, forKey: .pronunciation)
        partOfSpeech = try c.decode(String.self, forKey: .partOfSpeech)
        shortDefinition = try c.decode(String.self, forKey: .shortDefinition)
        longDefinition = try c.decode(String.self, forKey: .longDefinition)
        example = try c.decode(String.self, forKey: .example)
        secondExample = try c.decodeIfPresent(String.self, forKey: .secondExample)
        useCase = try c.decode(String.self, forKey: .useCase)
        origin = try c.decodeIfPresent(String.self, forKey: .origin)
        synonyms = try c.decodeIfPresent([String].self, forKey: .synonyms) ?? []
        difficulty = try c.decode(String.self, forKey: .difficulty)
        topics = try c.decodeIfPresent([String].self, forKey: .topics) ?? []
        emotionalTone = try c.decodeIfPresent(String.self, forKey: .emotionalTone)
        isPremium = try c.decodeIfPresent(Bool.self, forKey: .isPremium) ?? true
    }

    var difficultyLabel: String {
        switch difficulty {
        case "casual": return "Everyday"
        case "curious": return "Curious"
        case "advanced": return "Advanced"
        default: return difficulty.capitalized
        }
    }

    static let fallback = VerbsyWord(
        id: 0,
        slug: "sonder",
        word: "Sonder",
        pronunciation: "SAHN-der",
        partOfSpeech: "noun",
        shortDefinition: "The realization that every stranger has a life as vivid as your own.",
        longDefinition: "The sudden awareness that each passerby is living a story as complex and meaningful as yours.",
        example: "Walking through the airport, she felt a wave of sonder as each face passed with its own hidden story.",
        secondExample: "A moment of sonder made the argument feel suddenly small.",
        useCase: "Use it when empathy arrives all at once.",
        origin: "Coined by John Koenig for The Dictionary of Obscure Sorrows.",
        synonyms: ["empathy", "awareness", "perspective"],
        difficulty: "curious",
        topics: ["Mind & Psychology", "Emotions & Feelings", "Love & Relationships"],
        emotionalTone: "empathetic",
        isPremium: true
    )
}

struct VerbsyBootstrap: Codable {
    let serverDate: String
    let contentVersion: String
    let productIds: ProductIds
    let topics: [String]
    let difficulties: [String]?
    let dailyWord: VerbsyWord?
}

struct ProductIds: Codable {
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

struct WordFeedResponse: Codable {
    let words: [VerbsyWord]
    let nextOffset: Int?
}

struct QuizBatchItem: Codable, Identifiable, Hashable {
    let prompt: String
    let correctSlug: String
    let word: VerbsyWord
    let options: [VerbsyWord]

    var id: String { word.slug }
    var correctOption: VerbsyWord { options.first { $0.slug == correctSlug } ?? word }
}

struct QuizBatchResponse: Codable {
    let items: [QuizBatchItem]
    let nextOffset: Int?
}

/// Wrappers that give each scrolled card a unique, stable identity so the
/// feed/quiz can recycle words infinitely without SwiftUI id collisions.
struct FeedItem: Identifiable, Hashable {
    let id: Int
    let word: VerbsyWord
}

struct QuizEntry: Identifiable, Hashable {
    let id: Int
    let item: QuizBatchItem
}

/// Locally-stored progress. No accounts — everything lives on device.
struct LocalProgress: Codable {
    static let dailyGoal = 5

    var favoriteSlugs: Set<String> = []
    var seenSlugs: Set<String> = []            // every word fully viewed in the feed
    var seenByDate: [String: Int] = [:]        // new words seen per day (drives the ring + streak)
    var quizByDate: [String: Int] = [:]        // quiz questions answered per day
    var activeDates: Set<String> = []          // days the daily goal was met (drives the streak)
    var quizCorrect: Int = 0
    var quizAttempts: Int = 0
    var reviewResults: [String: ReviewMemory] = [:]

    var wordsLearned: Int { seenSlugs.count }
    var favoritesCount: Int { favoriteSlugs.count }
    var quizAccuracy: Double { quizAttempts > 0 ? Double(quizCorrect) / Double(quizAttempts) : 0 }
    var todaySeen: Int { seenByDate[Self.key(for: Date())] ?? 0 }

    /// Consecutive days meeting the daily goal. Today not yet active doesn't break it.
    var streak: Int {
        let calendar = Calendar.current
        var count = 0
        var cursor = calendar.startOfDay(for: Date())

        if !activeDates.contains(Self.key(for: cursor)) {
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = previous
        }
        while activeDates.contains(Self.key(for: cursor)) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    init() {}

    // Lenient decoding so progress survives renames / future field additions.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        favoriteSlugs = try c.decodeIfPresent(Set<String>.self, forKey: .favoriteSlugs) ?? []
        seenSlugs = try c.decodeIfPresent(Set<String>.self, forKey: .seenSlugs) ?? []
        seenByDate = try c.decodeIfPresent([String: Int].self, forKey: .seenByDate) ?? [:]
        quizByDate = try c.decodeIfPresent([String: Int].self, forKey: .quizByDate) ?? [:]
        activeDates = try c.decodeIfPresent(Set<String>.self, forKey: .activeDates) ?? []
        quizCorrect = try c.decodeIfPresent(Int.self, forKey: .quizCorrect) ?? 0
        quizAttempts = try c.decodeIfPresent(Int.self, forKey: .quizAttempts) ?? 0
        reviewResults = try c.decodeIfPresent([String: ReviewMemory].self, forKey: .reviewResults) ?? [:]
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
