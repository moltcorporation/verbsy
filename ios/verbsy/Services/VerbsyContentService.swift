import Foundation
import Combine

@MainActor
final class VerbsyContentStore: ObservableObject {
    @Published var todayWord: VerbsyWord = .fallback
    @Published var words: [VerbsyWord] = VerbsyCatalog.words
    @Published var topics: [String] = VerbsyCatalog.topics
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiBase = URL(string: "https://verbsy.app")!
    private let decoder = JSONDecoder()
    private let cacheKey = "verbsy.cached.bootstrap"

    init() {
        loadCachedBootstrap()
        if todayWord == .fallback {
            todayWord = VerbsyCatalog.todayWord
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let bootstrap: VerbsyBootstrap = try await get("/api/v1/bootstrap")
            topics = bootstrap.topics.isEmpty ? topics : bootstrap.topics
            if let dailyWord = bootstrap.dailyWord {
                todayWord = dailyWord
            }
            await loadWords()
            cache(bootstrap)
            WidgetBridge.write(word: todayWord)
        } catch {
            errorMessage = "Unable to refresh today’s word."
            if words.isEmpty {
                words = VerbsyCatalog.words
            }
            if todayWord == .fallback {
                todayWord = VerbsyCatalog.todayWord
            }
            WidgetBridge.write(word: todayWord)
        }
    }

    func loadWords(topic: String? = nil) async {
        do {
            var path = "/api/v1/words?limit=50"
            if let topic, !topic.isEmpty {
                path += "&topic=\(topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? topic)"
            }
            let response: WordListResponse = try await get(path)
            words = response.words.isEmpty ? VerbsyCatalog.filtered(topic: topic) : response.words
        } catch {
            words = VerbsyCatalog.filtered(topic: topic)
        }
    }

    private func get<T: Decodable>(_ path: String) async throws -> T {
        let url = apiBase.appending(path: path)
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
