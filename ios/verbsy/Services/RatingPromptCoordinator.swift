import Foundation

enum RatingPromptEvent {
    case dailyGoalCompleted
    case quizCorrect
    case favoriteAdded
}

/// Decides when it is appropriate to ask for an App Store rating.
///
/// StoreKit still makes the final decision about whether the system prompt
/// appears. This gate keeps our requests tied to positive, completed actions
/// and prevents repeated asks around normal app use.
enum RatingPromptCoordinator {
    private static let stateKey = "verbsy.ratingPrompt.state"
    private static let maxRequestsPerYear = 3
    private static let minimumDaysBetweenRequests = 90

    static func requestIfEligible(
        after event: RatingPromptEvent,
        progress: LocalProgress,
        requestReview: @escaping () -> Void
    ) {
        guard isEngagedEnough(for: event, progress: progress) else { return }

        var state = loadState()
        let now = Date()
        let calendar = Calendar.current
        let oneYearAgo = calendar.date(byAdding: .day, value: -365, to: now) ?? now
        state.requestDates = state.requestDates.filter { $0 >= oneYearAgo }

        guard state.requestDates.count < maxRequestsPerYear else { return }

        if let lastRequestDate = state.requestDates.max(),
           let nextAllowedDate = calendar.date(byAdding: .day, value: minimumDaysBetweenRequests, to: lastRequestDate),
           now < nextAllowedDate {
            return
        }

        state.requestDates.append(now)
        saveState(state)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            requestReview()
        }
    }

    private static func isEngagedEnough(for event: RatingPromptEvent, progress: LocalProgress) -> Bool {
        let activeDays = progress.activeDates.count
        let engagement = progress.wordsLearned + progress.quizAttempts + progress.favoritesCount

        switch event {
        case .dailyGoalCompleted:
            return progress.todaySeen >= LocalProgress.dailyGoal
                && progress.wordsLearned >= 3
                && activeDays >= 2
        case .quizCorrect:
            return progress.quizAttempts >= 3
                && progress.quizAccuracy >= 0.6
                && engagement >= 5
        case .favoriteAdded:
            return progress.favoritesCount >= 2
                && engagement >= 5
        }
    }

    private static func loadState() -> RatingPromptState {
        guard
            let data = UserDefaults.standard.data(forKey: stateKey),
            let decoded = try? JSONDecoder().decode(RatingPromptState.self, from: data)
        else {
            return RatingPromptState()
        }
        return decoded
    }

    private static func saveState(_ state: RatingPromptState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: stateKey)
    }
}

private struct RatingPromptState: Codable {
    var requestDates: [Date] = []
}
