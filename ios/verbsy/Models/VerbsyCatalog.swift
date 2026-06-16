import Foundation

/// Offline / first-launch word source. Loads the bundled `words.json` (the same
/// canonical corpus the API serves) so the Learn feed and Quiz work instantly
/// without a network call. The API remains authoritative when reachable.
enum VerbsyCatalog {
    static let words: [VerbsyWord] = loadBundled()

    static var topics: [String] {
        Array(Set(words.flatMap(\.topics))).sorted()
    }

    static var todayWord: VerbsyWord {
        guard !words.isEmpty else { return .fallback }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return words[day % words.count]
    }

    static func filtered(topics: [String], difficulties: [String]) -> [VerbsyWord] {
        words.filter { word in
            let topicOk = topics.isEmpty || !Set(word.topics).isDisjoint(with: topics)
            let diffOk = difficulties.isEmpty || difficulties.contains(word.difficulty)
            return topicOk && diffOk
        }
    }

    /// Deterministically shuffled local page — mirrors the server feed for offline use.
    static func feedPage(topics: [String], difficulties: [String], seed: String, offset: Int, limit: Int) -> [VerbsyWord] {
        let pool = filtered(topics: topics, difficulties: difficulties)
            .sorted { lhs, rhs in
                stableHash(lhs.slug + seed) < stableHash(rhs.slug + seed)
            }
        guard offset < pool.count else { return [] }
        return Array(pool[offset..<min(offset + limit, pool.count)])
    }

    /// Build a local quiz item with three distractors for a given word.
    static func quizItem(for word: VerbsyWord, seed: String) -> QuizBatchItem {
        let distractors = words
            .filter { $0.slug != word.slug }
            .sorted { stableHash($0.slug + word.slug + seed) < stableHash($1.slug + word.slug + seed) }
            .prefix(3)
        let options = ([word] + distractors).sorted { $0.word < $1.word }
        return QuizBatchItem(
            prompt: "What does \"\(word.word)\" mean?",
            correctSlug: word.slug,
            word: word,
            options: options
        )
    }

    private static func stableHash(_ value: String) -> UInt64 {
        // FNV-1a — deterministic across launches (unlike Swift's hashValue).
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }

    private static func loadBundled() -> [VerbsyWord] {
        guard
            let url = Bundle.main.url(forResource: "words", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([VerbsyWord].self, from: data),
            !decoded.isEmpty
        else {
            return [.fallback]
        }
        return decoded
    }
}
