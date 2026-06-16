import Foundation
import Combine

@MainActor
final class VerbsyContentStore: ObservableObject {
    @Published var todayWord: VerbsyWord = .fallback
    @Published var topics: [String] = VerbsyCatalog.topics

    // Learn feed
    @Published var feedWords: [VerbsyWord] = []
    @Published var isLoadingFeed = false
    private var feedOffset = 0
    private var feedHasMore = true

    // Quiz feed
    @Published var quizItems: [QuizBatchItem] = []
    @Published var isLoadingQuiz = false
    private var quizOffset = 0
    private var quizHasMore = true

    @Published var errorMessage: String?

    private let apiBase = URL(string: "https://verbsy.app")!
    private let decoder = JSONDecoder()
    private let cacheKey = "verbsy.cached.bootstrap"
    // A per-launch seed keeps a session's feed stable while paginating, yet varies
    // the order across launches.
    private let sessionSeed = String(UInt64.random(in: .min ... .max), radix: 36)

    init() {
        loadCachedBootstrap()
        if todayWord == .fallback {
            todayWord = VerbsyCatalog.todayWord
        }
    }

    // MARK: Bootstrap / daily word

    func refresh() async {
        errorMessage = nil
        do {
            let bootstrap: VerbsyBootstrap = try await get("/api/v1/bootstrap")
            topics = bootstrap.topics.isEmpty ? topics : bootstrap.topics
            if let dailyWord = bootstrap.dailyWord {
                todayWord = dailyWord
            }
            cache(bootstrap)
            WidgetBridge.write(word: todayWord)
        } catch {
            if todayWord == .fallback {
                todayWord = VerbsyCatalog.todayWord
            }
            WidgetBridge.write(word: todayWord)
        }
    }

    // MARK: Learn feed (infinite, personalized)

    func loadFeedPage(topics: [String], difficulties: [String], reset: Bool = false) async {
        if reset {
            feedOffset = 0
            feedHasMore = true
            feedWords = []
        }
        guard feedHasMore, !isLoadingFeed else { return }
        isLoadingFeed = true
        defer { isLoadingFeed = false }

        let limit = 20
        do {
            let path = "/api/v1/feed?" + query(topics: topics, difficulties: difficulties, offset: feedOffset, limit: limit)
            let response: WordFeedResponse = try await get(path)
            appendFeed(response.words)
            if let next = response.nextOffset {
                feedOffset = next
            } else {
                feedHasMore = false
            }
        } catch {
            // Offline / API failure: fall back to the bundled corpus.
            let page = VerbsyCatalog.feedPage(topics: topics, difficulties: difficulties, seed: sessionSeed, offset: feedOffset, limit: limit)
            appendFeed(page)
            if page.count < limit {
                feedHasMore = false
            } else {
                feedOffset += limit
            }
        }
    }

    private func appendFeed(_ words: [VerbsyWord]) {
        let existing = Set(feedWords.map(\.slug))
        feedWords.append(contentsOf: words.filter { !existing.contains($0.slug) })
    }

    // MARK: Quiz feed (infinite, personalized)

    func loadQuizBatch(topics: [String], difficulties: [String], reset: Bool = false) async {
        if reset {
            quizOffset = 0
            quizHasMore = true
            quizItems = []
        }
        guard quizHasMore, !isLoadingQuiz else { return }
        isLoadingQuiz = true
        defer { isLoadingQuiz = false }

        let limit = 10
        do {
            let path = "/api/v1/quiz?" + query(topics: topics, difficulties: difficulties, offset: quizOffset, limit: limit)
            let response: QuizBatchResponse = try await get(path)
            quizItems.append(contentsOf: response.items)
            if let next = response.nextOffset {
                quizOffset = next
            } else {
                quizHasMore = false
            }
        } catch {
            let page = VerbsyCatalog.feedPage(topics: topics, difficulties: difficulties, seed: sessionSeed + "q", offset: quizOffset, limit: limit)
            quizItems.append(contentsOf: page.map { VerbsyCatalog.quizItem(for: $0, seed: sessionSeed) })
            if page.count < limit {
                quizHasMore = false
            } else {
                quizOffset += limit
            }
        }
    }

    // MARK: Lookups

    /// Resolve favorite slugs to full words, preferring the bundled corpus
    /// (always available) and falling back to anything seen this session.
    func words(for slugs: Set<String>) -> [VerbsyWord] {
        var map: [String: VerbsyWord] = [:]
        for word in VerbsyCatalog.words { map[word.slug] = word }
        for word in feedWords { map[word.slug] = word }
        return slugs.compactMap { map[$0] }.sorted { $0.word < $1.word }
    }

    // MARK: Networking helpers

    private func query(topics: [String], difficulties: [String], offset: Int, limit: Int) -> String {
        var items = [
            URLQueryItem(name: "seed", value: sessionSeed),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(limit)),
        ]
        if !topics.isEmpty {
            items.append(URLQueryItem(name: "topics", value: topics.joined(separator: ",")))
        }
        if !difficulties.isEmpty {
            items.append(URLQueryItem(name: "difficulties", value: difficulties.joined(separator: ",")))
        }
        var components = URLComponents()
        components.queryItems = items
        return components.percentEncodedQuery ?? ""
    }

    private func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: apiBase.absoluteString + path) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(T.self, from: data)
    }

    private func cache(_ bootstrap: VerbsyBootstrap) {
        guard let data = try? JSONEncoder().encode(bootstrap) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }

    private func loadCachedBootstrap() {
        guard
            let data = UserDefaults.standard.data(forKey: cacheKey),
            let bootstrap = try? decoder.decode(VerbsyBootstrap.self, from: data)
        else { return }

        topics = bootstrap.topics
        if let dailyWord = bootstrap.dailyWord {
            todayWord = dailyWord
        }
    }
}
