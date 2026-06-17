import Foundation
import Combine

/// Fully on-device content store. The app ships its entire word corpus in
/// `words.json` (see VerbsyCatalog) and serves the feed, quiz, and daily word
/// locally — no network, no API, no accounts. Content updates ship with app
/// updates.
@MainActor
final class VerbsyContentStore: ObservableObject {
    @Published var todayWord: VerbsyWord = VerbsyCatalog.todayWord
    @Published var topics: [String] = VerbsyCatalog.topics

    // Learn feed (recycles infinitely through reshuffled passes)
    @Published var feedItems: [FeedItem] = []
    @Published var isLoadingFeed = false
    private var feedCounter = 0
    private var feedPass = 0
    private var feedOffset = 0

    // Quiz feed
    @Published var quizEntries: [QuizEntry] = []
    @Published var isLoadingQuiz = false
    private var quizCounter = 0
    private var quizPass = 0
    private var quizOffset = 0

    // A per-launch seed varies the order between sessions.
    private let sessionSeed = String(UInt64.random(in: .min ... .max), radix: 36)

    private let feedPageSize = 20
    private let quizPageSize = 10

    init() {
        WidgetBridge.write(word: todayWord)
    }

    /// Refresh the on-device daily word and sync it to the widget.
    func refresh() async {
        todayWord = VerbsyCatalog.todayWord
        WidgetBridge.write(word: todayWord)
    }

    /// Push the widget's rotation pool (respecting the user's topics/difficulty).
    func syncWidget(topics: [String], difficulties: [String]) {
        let rotation = VerbsyCatalog.feedPage(topics: topics, difficulties: difficulties, seed: "widget-rotation", offset: 0, limit: 40)
        WidgetBridge.write(words: rotation.isEmpty ? Array(VerbsyCatalog.words.prefix(40)) : rotation)
        WidgetBridge.write(word: todayWord)
    }

    // MARK: Learn feed

    func loadFeedPage(topics: [String], difficulties: [String], reset: Bool = false) async {
        if reset {
            feedItems = []
            feedCounter = 0
            feedPass = 0
            feedOffset = 0
        }
        guard let page = nextPage(
            topics: topics,
            difficulties: difficulties,
            pass: &feedPass,
            offset: &feedOffset,
            size: feedPageSize,
            seedPrefix: "feed"
        ) else { return }

        for word in page {
            feedItems.append(FeedItem(id: feedCounter, word: word))
            feedCounter += 1
        }
    }

    // MARK: Quiz feed

    func loadQuizBatch(topics: [String], difficulties: [String], reset: Bool = false) async {
        if reset {
            quizEntries = []
            quizCounter = 0
            quizPass = 0
            quizOffset = 0
        }
        guard let page = nextPage(
            topics: topics,
            difficulties: difficulties,
            pass: &quizPass,
            offset: &quizOffset,
            size: quizPageSize,
            seedPrefix: "quiz"
        ) else { return }

        for word in page {
            let item = VerbsyCatalog.quizItem(for: word, seed: sessionSeed)
            quizEntries.append(QuizEntry(id: quizCounter, item: item))
            quizCounter += 1
        }
    }

    // MARK: Lookups

    /// Resolve favorite slugs to full words from the bundled corpus.
    func words(for slugs: Set<String>) -> [VerbsyWord] {
        var map: [String: VerbsyWord] = [:]
        for word in VerbsyCatalog.words { map[word.slug] = word }
        return slugs.compactMap { map[$0] }.sorted { $0.word < $1.word }
    }

    /// Ensure a specific word exists in the Learn feed and return its card id so
    /// a deep link can scroll directly to it.
    func focusWord(slug: String) -> Int? {
        if let existing = feedItems.first(where: { $0.word.slug == slug }) {
            return existing.id
        }
        guard let word = VerbsyCatalog.words.first(where: { $0.slug == slug }) else {
            return nil
        }
        let focusedItem = FeedItem(id: feedCounter, word: word)
        feedCounter += 1
        feedItems.insert(focusedItem, at: 0)
        return focusedItem.id
    }

    // MARK: Paging

    /// Returns the next page from a deterministically shuffled pass of the
    /// filtered corpus. When a pass is exhausted it reshuffles and continues,
    /// so the feed never runs dry. Returns nil only if no words match at all.
    private func nextPage(
        topics: [String],
        difficulties: [String],
        pass: inout Int,
        offset: inout Int,
        size: Int,
        seedPrefix: String
    ) -> [VerbsyWord]? {
        let seed = "\(sessionSeed)-\(seedPrefix)-\(pass)"
        var page = VerbsyCatalog.feedPage(topics: topics, difficulties: difficulties, seed: seed, offset: offset, limit: size)
        if page.isEmpty {
            // Reached the end of this shuffle pass — start a fresh one.
            pass += 1
            offset = 0
            let nextSeed = "\(sessionSeed)-\(seedPrefix)-\(pass)"
            page = VerbsyCatalog.feedPage(topics: topics, difficulties: difficulties, seed: nextSeed, offset: 0, limit: size)
            if page.isEmpty { return nil } // no matching words at all
        }
        offset += size
        return page
    }
}
