import SwiftUI

struct MainAppView: View {
    @Binding var selectedTab: Int
    @Binding var showPaywall: Bool

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(showPaywall: $showPaywall)
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
                .tag(0)

            ReviewView(showPaywall: $showPaywall)
                .tabItem { Label("Review", systemImage: "checkmark.seal.fill") }
                .tag(1)

            LibraryView(showPaywall: $showPaywall)
                .tabItem { Label("Library", systemImage: "books.vertical.fill") }
                .tag(2)
        }
        .tint(VerbsyDesign.ink)
    }
}

private struct TodayView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var progress: LocalProgressStore
    @Binding var showPaywall: Bool
    @State private var showLearnedConfirmation = false
    @State private var showSettings = false

    private var isLearnedToday: Bool {
        progress.progress.learnedDates.contains(LocalProgress.key(for: Date()))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today")
                                .font(.system(size: 36, weight: .black, design: .rounded))
                            Text(progress.progress.streak == 0 ? "Start your streak" : "\(progress.progress.streak)-day streak")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(VerbsyDesign.muted)
                        }
                        Spacer()
                        VerbsyLogo(size: 48)
                    }

                    WordDetailCard(word: content.todayWord, isSaved: progress.isSaved(content.todayWord)) {
                        Haptics.selection()
                        progress.toggleSaved(content.todayWord)
                    }

                    Button {
                        Haptics.success()
                        progress.markLearned(content.todayWord)
                        withAnimation(.smooth(duration: 0.25)) {
                            showLearnedConfirmation = true
                        }
                    } label: {
                        Label(isLearnedToday ? "Learned Today" : "Mark Learned", systemImage: isLearnedToday ? "checkmark.seal.fill" : "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(isLearnedToday ? VerbsyDesign.sage : VerbsyDesign.ink)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    if showLearnedConfirmation || isLearnedToday {
                        DailyProgressCard(
                            streak: progress.progress.streak,
                            learnedCount: progress.progress.learnedSlugs.count,
                            savedCount: progress.progress.savedSlugs.count
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    WidgetUpsellCard(isPro: purchases.isPro) {
                        showPaywall = true
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
            }
            .background(VerbsyDesign.background.ignoresSafeArea())
            .refreshable { await content.refresh() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(VerbsyDesign.ink)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(showPaywall: $showPaywall)
                    .environmentObject(purchases)
                    .environmentObject(progress)
                    .presentationDetents([.large])
            }
        }
    }
}

private struct ReviewView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var progress: LocalProgressStore
    @Binding var showPaywall: Bool
    @State private var question: ReviewQuestion?
    @State private var selectedSlug: String?
    @State private var answeredCorrectly: Bool?

    private var reviewPool: [VerbsyWord] {
        let learned = content.words.filter { progress.progress.learnedSlugs.contains($0.slug) }
        let saved = content.words.filter { progress.progress.savedSlugs.contains($0.slug) }
        let merged = Array(Set(learned + saved + [content.todayWord]))
        return merged.isEmpty ? Array(content.words.prefix(8)) : merged
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Review")
                        .font(.system(size: 36, weight: .black, design: .rounded))

                    if purchases.isPro {
                        ReviewStatsCard(
                            correct: progress.progress.quizCorrect,
                            attempts: progress.progress.quizAttempts,
                            learned: progress.progress.learnedSlugs.count
                        )

                        if let question {
                            ReviewQuestionCard(
                                question: question,
                                selectedSlug: selectedSlug,
                                answeredCorrectly: answeredCorrectly,
                                onSelect: answer,
                                onNext: nextQuestion
                            )
                        } else {
                            EmptyReviewCard {
                                nextQuestion()
                            }
                        }
                    } else {
                        LockedFeatureCard(
                            title: "Review is part of Verbsy Pro",
                            detail: "Turn daily words into words you can actually use.",
                            action: { showPaywall = true }
                        )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
            }
            .background(VerbsyDesign.background.ignoresSafeArea())
            .task {
                await content.loadWords()
                if question == nil {
                    nextQuestion()
                }
            }
        }
    }

    private func answer(_ choice: VerbsyWord) {
        guard selectedSlug == nil, let question else { return }
        selectedSlug = choice.slug
        let isCorrect = choice.slug == question.word.slug
        answeredCorrectly = isCorrect
        progress.recordQuiz(word: question.word, correct: isCorrect)
        isCorrect ? Haptics.success() : Haptics.selection()
    }

    private func nextQuestion() {
        let pool = reviewPool.isEmpty ? VerbsyCatalog.words : reviewPool
        guard let target = pool.randomElement() else { return }
        let distractors = content.words
            .filter { $0.slug != target.slug }
            .shuffled()
            .prefix(3)
        question = ReviewQuestion(word: target, choices: ([target] + distractors).shuffled())
        selectedSlug = nil
        answeredCorrectly = nil
    }
}

private struct LibraryView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var progress: LocalProgressStore
    @Binding var showPaywall: Bool
    @State private var selectedTopic = ""
    @State private var query = ""
    @State private var selectedWord: VerbsyWord?

    private var visibleWords: [VerbsyWord] {
        content.words.filter { word in
            let matchesTopic = selectedTopic.isEmpty || word.topics.contains(selectedTopic)
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesQuery = trimmedQuery.isEmpty
                || word.word.localizedCaseInsensitiveContains(trimmedQuery)
                || word.shortDefinition.localizedCaseInsensitiveContains(trimmedQuery)
                || word.topics.contains { $0.localizedCaseInsensitiveContains(trimmedQuery) }
            return matchesTopic && matchesQuery
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Library")
                        .font(.system(size: 36, weight: .black, design: .rounded))

                    SearchField(text: $query)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            topicButton("All")
                            ForEach(content.topics, id: \.self) { topic in topicButton(topic) }
                        }
                    }

                    if purchases.isPro {
                        ForEach(visibleWords, id: \.slug) { word in
                            CompactWordRow(
                                word: word,
                                isSaved: progress.isSaved(word),
                                isLearned: progress.isLearned(word)
                            ) {
                                selectedWord = word
                            }
                        }

                        if visibleWords.isEmpty {
                            EmptyLibraryCard()
                        }
                    } else {
                        CompactWordRow(
                            word: content.todayWord,
                            isSaved: progress.isSaved(content.todayWord),
                            isLearned: progress.isLearned(content.todayWord)
                        ) {
                            selectedWord = content.todayWord
                        }
                        LockedFeatureCard(
                            title: "Unlock the full word archive",
                            detail: "Explore words by topic, save favorites, and review them later.",
                            action: { showPaywall = true }
                        )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
            }
            .background(VerbsyDesign.background.ignoresSafeArea())
            .task { await content.loadWords(topic: selectedTopic == "All" ? nil : selectedTopic) }
            .onChange(of: selectedTopic) { _, newValue in
                Task { await content.loadWords(topic: newValue == "All" ? nil : newValue) }
            }
            .sheet(item: $selectedWord) { word in
                WordDetailSheet(word: word)
                    .environmentObject(progress)
            }
        }
    }

    private func topicButton(_ topic: String) -> some View {
        Button {
            selectedTopic = topic == "All" ? "" : topic
        } label: {
            Text(topic)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle((selectedTopic.isEmpty && topic == "All") || selectedTopic == topic ? .white : VerbsyDesign.ink)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background((selectedTopic.isEmpty && topic == "All") || selectedTopic == topic ? VerbsyDesign.ink : .white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct WordDetailCard: View {
    let word: VerbsyWord
    let isSaved: Bool
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(word.word)
                        .font(.system(size: 52, weight: .black, design: .rounded))
                    Text("\(word.pronunciation) · \(word.partOfSpeech)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(VerbsyDesign.sage)
                }
                Spacer()
                Button(action: onSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(VerbsyDesign.ink)
                        .frame(width: 52, height: 52)
                        .background(VerbsyDesign.panel)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Text(word.longDefinition)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(VerbsyDesign.ink)
                .lineSpacing(4)

            Divider()

            Text(word.example)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(VerbsyDesign.muted)
                .lineSpacing(4)

            Text(word.useCase)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(VerbsyDesign.ink)
                .padding(.top, 4)
        }
        .padding(26)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(VerbsyDesign.line))
        .shadow(color: .black.opacity(0.06), radius: 22, x: 0, y: 14)
    }
}

private struct WidgetUpsellCard: View {
    let isPro: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Word of the Day Widget", systemImage: "rectangle.on.rectangle")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                Spacer()
                Text(isPro ? "Active" : "Pro")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(isPro ? VerbsyDesign.sage : VerbsyDesign.ink)
                    .clipShape(Capsule())
            }

            HStack(spacing: 14) {
                WidgetPreviewMini()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Put a sharper word on your Home Screen and Lock Screen.")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    if !isPro {
                        Button("Unlock widgets", action: action)
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(VerbsyDesign.ink)
                    }
                }
            }
        }
        .padding(20)
        .background(VerbsyDesign.panel)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct WidgetPreviewMini: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Lucid")
                .font(.system(size: 21, weight: .black, design: .rounded))
            Text("Clear and easy to understand.")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(VerbsyDesign.muted)
                .lineLimit(3)
        }
        .frame(width: 104, height: 104, alignment: .topLeading)
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct DailyProgressCard: View {
    let streak: Int
    let learnedCount: Int
    let savedCount: Int

    var body: some View {
        HStack(spacing: 12) {
            metric("Streak", value: "\(streak)", symbol: "flame.fill")
            metric("Learned", value: "\(learnedCount)", symbol: "checkmark.seal.fill")
            metric("Saved", value: "\(savedCount)", symbol: "bookmark.fill")
        }
    }

    private func metric(_ title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(VerbsyDesign.sage)
            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(VerbsyDesign.ink)
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(VerbsyDesign.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(VerbsyDesign.line))
    }
}

private struct ReviewStatsCard: View {
    let correct: Int
    let attempts: Int
    let learned: Int

    private var accuracyText: String {
        guard attempts > 0 else { return "New" }
        return "\(Int((Double(correct) / Double(attempts) * 100).rounded()))%"
    }

    var body: some View {
        HStack(spacing: 12) {
            stat("Accuracy", accuracyText)
            stat("Reviewed", "\(attempts)")
            stat("Learned", "\(learned)")
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundStyle(VerbsyDesign.ink)
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(VerbsyDesign.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(VerbsyDesign.line))
    }
}

private struct ReviewQuestionCard: View {
    let question: ReviewQuestion
    let selectedSlug: String?
    let answeredCorrectly: Bool?
    let onSelect: (VerbsyWord) -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose the best meaning")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(VerbsyDesign.sage)
                    .textCase(.uppercase)

                Text(question.word.word)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(VerbsyDesign.ink)

                Text("\(question.word.pronunciation) · \(question.word.partOfSpeech)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(VerbsyDesign.muted)
            }

            ForEach(question.choices, id: \.slug) { choice in
                Button {
                    onSelect(choice)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Text(choice.shortDefinition)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(VerbsyDesign.ink)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        answerIcon(for: choice)
                    }
                    .padding(18)
                    .background(background(for: choice))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(border(for: choice), lineWidth: selectedSlug == choice.slug ? 2 : 1))
                }
                .buttonStyle(.plain)
                .disabled(selectedSlug != nil)
            }

            if let answeredCorrectly {
                VStack(alignment: .leading, spacing: 10) {
                    Text(answeredCorrectly ? "Correct" : "Not quite")
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(answeredCorrectly ? VerbsyDesign.sage : VerbsyDesign.ink)

                    Text(question.word.example)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(VerbsyDesign.muted)
                        .lineSpacing(3)

                    Button("Next word", action: onNext)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(VerbsyDesign.ink)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
        }
        .padding(22)
        .background(VerbsyDesign.panel)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    @ViewBuilder
    private func answerIcon(for choice: VerbsyWord) -> some View {
        if selectedSlug != nil && choice.slug == question.word.slug {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(VerbsyDesign.sage)
                .font(.system(size: 23, weight: .bold))
        } else if selectedSlug == choice.slug {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 23, weight: .bold))
        }
    }

    private func background(for choice: VerbsyWord) -> Color {
        guard selectedSlug != nil else { return .white }
        if choice.slug == question.word.slug { return VerbsyDesign.sage.opacity(0.12) }
        if selectedSlug == choice.slug { return Color.red.opacity(0.08) }
        return .white
    }

    private func border(for choice: VerbsyWord) -> Color {
        guard selectedSlug != nil else { return VerbsyDesign.line }
        if choice.slug == question.word.slug { return VerbsyDesign.sage }
        if selectedSlug == choice.slug { return .red.opacity(0.7) }
        return VerbsyDesign.line
    }
}

private struct SettingsView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var progress: LocalProgressStore
    @Environment(\.dismiss) private var dismiss
    @Binding var showPaywall: Bool
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Settings")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(VerbsyDesign.ink)
                        Text("Manage Verbsy Pro, support, privacy, and local progress.")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(VerbsyDesign.muted)
                    }

                    settingsSection("Verbsy Pro") {
                        SettingsRow(
                            symbol: purchases.isPro ? "checkmark.seal.fill" : "sparkles",
                            title: purchases.isPro ? "Verbsy Pro is active" : "Upgrade to Verbsy Pro",
                            detail: purchases.isPro ? "Widgets, review, topics, and the full word archive are unlocked." : "Unlock widgets, review, topics, and the full word archive."
                        ) {
                            if !purchases.isPro {
                                dismiss()
                                showPaywall = true
                            }
                        }

                        Button {
                            Task { await purchases.restore() }
                        } label: {
                            SettingsRowContent(symbol: "arrow.clockwise", title: "Restore Purchases", detail: "Restore an existing App Store subscription.")
                        }
                        .buttonStyle(.plain)

                        Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                            SettingsRowContent(symbol: "person.crop.circle", title: "Manage Subscription", detail: "Open Apple subscription settings.")
                        }
                    }

                    settingsSection("Support and legal") {
                        Link(destination: URL(string: "https://verbsy.app/support")!) {
                            SettingsRowContent(symbol: "questionmark.circle.fill", title: "Support", detail: "Contact support@verbsy.app.")
                        }
                        Link(destination: URL(string: "https://verbsy.app/privacy")!) {
                            SettingsRowContent(symbol: "hand.raised.fill", title: "Privacy Policy", detail: "See how Verbsy handles data.")
                        }
                        Link(destination: URL(string: "https://verbsy.app/terms")!) {
                            SettingsRowContent(symbol: "doc.text.fill", title: "Terms of Use", detail: "Review subscription and app terms.")
                        }
                    }

                    settingsSection("Local progress") {
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            SettingsRowContent(symbol: "trash.fill", title: "Reset Progress", detail: "Clear saved words, learned words, streaks, and review history.")
                        }
                        .buttonStyle(.plain)
                    }

                    if let status = purchases.statusMessage {
                        Text(status)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(VerbsyDesign.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 26)
            }
            .background(VerbsyDesign.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(VerbsyDesign.ink)
                }
            }
            .confirmationDialog("Reset local progress?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset Progress", role: .destructive) {
                    progress.resetAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This clears only data stored on this device.")
            }
        }
    }

    @ViewBuilder
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(VerbsyDesign.sage)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                content()
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(VerbsyDesign.line))
        }
    }
}

private struct SettingsRow: View {
    let symbol: String
    let title: String
    let detail: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRowContent(symbol: symbol, title: title, detail: detail)
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsRowContent: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(VerbsyDesign.ink)
                .frame(width: 38, height: 38)
                .background(VerbsyDesign.panel)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(VerbsyDesign.ink)
                Text(detail)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(VerbsyDesign.muted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(VerbsyDesign.muted.opacity(0.45))
        }
        .padding(16)
    }
}

private struct EmptyReviewCard: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "rectangle.stack.badge.play.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(VerbsyDesign.sage)
            Text("Build recall, not just recognition")
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundStyle(VerbsyDesign.ink)
            Text("Review asks you to pick meanings from words you have learned or saved.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(VerbsyDesign.muted)
                .lineSpacing(3)
            Button("Start review", action: action)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(VerbsyDesign.ink)
                .clipShape(Capsule())
        }
        .padding(22)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(VerbsyDesign.line))
    }
}

private struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(VerbsyDesign.muted)
            TextField("Search words or meanings", text: $text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(VerbsyDesign.muted.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(VerbsyDesign.line))
    }
}

private struct LockedFeatureCard: View {
    let title: String
    let detail: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(VerbsyDesign.gold)
            Text(title)
                .font(.system(size: 25, weight: .black, design: .rounded))
            Text(detail)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(VerbsyDesign.muted)
            Button("Unlock Verbsy Pro", action: action)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(VerbsyDesign.ink)
                .clipShape(Capsule())
        }
        .padding(22)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(VerbsyDesign.line))
    }
}

private struct CompactWordRow: View {
    let word: VerbsyWord
    let isSaved: Bool
    let isLearned: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(word.word)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(VerbsyDesign.ink)
                        Text("\(word.pronunciation) · \(word.partOfSpeech)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(VerbsyDesign.sage)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        if isLearned {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(VerbsyDesign.sage)
                        }
                        if isSaved {
                            Image(systemName: "bookmark.fill")
                                .foregroundStyle(VerbsyDesign.ink)
                        }
                    }
                    .font(.system(size: 16, weight: .bold))
                }
                Text(word.shortDefinition)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(VerbsyDesign.muted)
                    .multilineTextAlignment(.leading)
                HStack(spacing: 8) {
                    ForEach(word.topics.prefix(2), id: \.self) { topic in
                        Text(topic)
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(VerbsyDesign.muted)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(VerbsyDesign.panel)
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Text(word.difficulty.capitalized)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(VerbsyDesign.muted)
                }
            }
            .padding(18)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(VerbsyDesign.line))
        }
        .buttonStyle(.plain)
    }
}

private struct EmptyLibraryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No matching words")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(VerbsyDesign.ink)
            Text("Try a broader search or another topic.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(VerbsyDesign.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(VerbsyDesign.line))
    }
}

private struct WordDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progress: LocalProgressStore
    let word: VerbsyWord

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    WordDetailCard(word: word, isSaved: progress.isSaved(word)) {
                        Haptics.selection()
                        progress.toggleSaved(word)
                    }

                    Button {
                        Haptics.success()
                        progress.markLearned(word)
                    } label: {
                        Label(progress.isLearned(word) ? "Learned" : "Mark Learned", systemImage: progress.isLearned(word) ? "checkmark.seal.fill" : "checkmark.circle.fill")
                            .font(.system(size: 19, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(progress.isLearned(word) ? VerbsyDesign.sage : VerbsyDesign.ink)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    if let secondExample = word.secondExample {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Another way to use it")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(VerbsyDesign.sage)
                                .textCase(.uppercase)
                            Text(secondExample)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(VerbsyDesign.muted)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(VerbsyDesign.line))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
            }
            .background(VerbsyDesign.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
        }
    }
}
