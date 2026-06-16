import SwiftUI

/// The core experience. A horizontal pager between an infinite word feed and an
/// infinite quiz — slide sideways to switch, like a TikTok feed.
struct LearnView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var prefs: PreferencesStore

    @State private var mode = 0 // 0 = Words, 1 = Quiz

    var body: some View {
        ZStack(alignment: .top) {
            VerbsyDesign.background.ignoresSafeArea()

            TabView(selection: $mode) {
                WordFeedView()
                    .tag(0)
                QuizFeedView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)

            LearnModeSwitcher(mode: $mode)
                .padding(.top, 6)
        }
        .task {
            if content.feedItems.isEmpty {
                await content.loadFeedPage(topics: prefs.selectedTopics, difficulties: prefs.effectiveDifficulties, reset: true)
            }
        }
    }
}

private struct LearnModeSwitcher: View {
    @Binding var mode: Int
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 4) {
            segment("Words", index: 0)
            segment("Quiz", index: 1)
        }
        .padding(4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(VerbsyDesign.line))
    }

    private func segment(_ title: String, index: Int) -> some View {
        Button {
            Haptics.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) { mode = index }
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .default))
                .foregroundStyle(mode == index ? VerbsyDesign.onSage : VerbsyDesign.muted)
                .padding(.horizontal, 20)
                .padding(.vertical, 9)
                .background {
                    if mode == index {
                        Capsule().fill(VerbsyDesign.sage).matchedGeometryEffect(id: "seg", in: ns)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Word feed

private struct WordFeedView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var progress: LocalProgressStore
    @EnvironmentObject private var prefs: PreferencesStore

    @State private var currentId: Int?

    var body: some View {
        Group {
            if content.feedItems.isEmpty {
                FeedLoadingView()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(content.feedItems) { item in
                            WordCardView(word: item.word)
                                .containerRelativeFrame(.vertical)
                                .id(item.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentId)
                .ignoresSafeArea()
                .onChange(of: currentId) { _, id in
                    guard let id, let item = content.feedItems.first(where: { $0.id == id }) else { return }
                    progress.recordSeen(item.word)
                    loadMoreIfNeeded(currentId: id)
                }
                .onAppear {
                    if currentId == nil, let first = content.feedItems.first {
                        progress.recordSeen(first.word)
                    }
                }
            }
        }
    }

    private func loadMoreIfNeeded(currentId id: Int) {
        guard let index = content.feedItems.firstIndex(where: { $0.id == id }) else { return }
        if index >= content.feedItems.count - 4 {
            Task { await content.loadFeedPage(topics: prefs.selectedTopics, difficulties: prefs.effectiveDifficulties) }
        }
    }
}

private struct WordCardView: View {
    @EnvironmentObject private var progress: LocalProgressStore
    let word: VerbsyWord

    private var isFavorite: Bool { progress.isFavorite(word) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    if let topic = word.topics.first { TopicChip(topic: topic) }
                    DifficultyPill(word: word)
                }
                .padding(.bottom, 18)

                Text(word.word)
                    .font(VerbsyDesign.display(58))
                    .foregroundStyle(VerbsyDesign.ink)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)

                Text("\(word.pronunciation) · \(word.partOfSpeech)")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(VerbsyDesign.sage)
                    .padding(.top, 6)

                Text(word.shortDefinition)
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(VerbsyDesign.ink)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 22)

                Text("“\(word.example)”")
                    .font(.system(size: 19, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(VerbsyDesign.muted)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 16)

                if let origin = word.origin {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(VerbsyDesign.gold)
                            .padding(.top, 2)
                        Text(origin)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundStyle(VerbsyDesign.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 20)
                }

                if !word.synonyms.isEmpty {
                    Text("Similar: \(word.synonyms.prefix(3).joined(separator: " · "))")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(VerbsyDesign.muted)
                        .padding(.top, 12)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, VerbsyDesign.pageGutter)
            .padding(.trailing, 56)
            .padding(.top, 80)
            .padding(.bottom, 96)

            // TikTok-style control column
            VStack(spacing: 16) {
                Button {
                    Haptics.selection()
                    progress.toggleFavorite(word)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isFavorite ? VerbsyDesign.onSage : VerbsyDesign.ink)
                        .frame(width: 54, height: 54)
                        .background(isFavorite ? VerbsyDesign.sage : VerbsyDesign.surface)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(VerbsyDesign.line))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFavorite ? "Remove favorite" : "Add favorite")

                WordShareButton(word: word)
            }
            .padding(.trailing, VerbsyDesign.pageGutter)
            .padding(.bottom, 110)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VerbsyDesign.background)
    }
}

// MARK: - Quiz feed

private struct QuizFeedView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var prefs: PreferencesStore

    @State private var currentId: Int?

    var body: some View {
        Group {
            if content.quizEntries.isEmpty {
                FeedLoadingView()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(content.quizEntries) { entry in
                            QuizCardView(item: entry.item)
                                .containerRelativeFrame(.vertical)
                                .id(entry.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentId)
                .ignoresSafeArea()
                .onChange(of: currentId) { _, id in
                    guard let id, let index = content.quizEntries.firstIndex(where: { $0.id == id }) else { return }
                    if index >= content.quizEntries.count - 3 {
                        Task { await content.loadQuizBatch(topics: prefs.selectedTopics, difficulties: prefs.effectiveDifficulties) }
                    }
                }
            }
        }
        .task {
            if content.quizEntries.isEmpty {
                await content.loadQuizBatch(topics: prefs.selectedTopics, difficulties: prefs.effectiveDifficulties, reset: true)
            }
        }
    }
}

private struct QuizCardView: View {
    @EnvironmentObject private var progress: LocalProgressStore
    let item: QuizBatchItem

    @State private var selectedSlug: String?

    private var answered: Bool { selectedSlug != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)

            Eyebrow(text: "What does this mean?", color: VerbsyDesign.sage)
            Text(item.word.word)
                .font(VerbsyDesign.display(46))
                .foregroundStyle(VerbsyDesign.ink)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.top, 6)
            Text("\(item.word.pronunciation) · \(item.word.partOfSpeech)")
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundStyle(VerbsyDesign.muted)
                .padding(.top, 4)

            VStack(spacing: 12) {
                ForEach(item.options) { option in
                    QuizOptionRow(
                        text: option.shortDefinition,
                        state: state(for: option)
                    ) {
                        select(option)
                    }
                }
            }
            .padding(.top, 24)

            if answered {
                Text("“\(item.word.example)”")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(VerbsyDesign.muted)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 18)
                    .transition(.opacity)

                Text("Swipe up for the next word")
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 14)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, VerbsyDesign.pageGutter)
        .padding(.top, 80)
        .padding(.bottom, 110)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(VerbsyDesign.background)
    }

    private func state(for option: VerbsyWord) -> QuizOptionRow.State {
        guard let selectedSlug else { return .idle }
        if option.slug == item.correctSlug { return .correct }
        if option.slug == selectedSlug { return .wrong }
        return .dimmed
    }

    private func select(_ option: VerbsyWord) {
        guard selectedSlug == nil else { return }
        let isCorrect = option.slug == item.correctSlug
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            selectedSlug = option.slug
        }
        progress.recordQuiz(word: item.word, correct: isCorrect)
        isCorrect ? Haptics.success() : Haptics.warning()
    }
}

private struct QuizOptionRow: View {
    enum State { case idle, correct, wrong, dimmed }

    let text: String
    let state: State
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Text(text)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(VerbsyDesign.ink)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                icon
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(stroke, lineWidth: state == .idle ? 1 : 2))
            .opacity(state == .dimmed ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(state != .idle)
    }

    @ViewBuilder private var icon: some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(VerbsyDesign.sage)
        case .wrong:
            Image(systemName: "xmark.circle.fill").foregroundStyle(VerbsyDesign.destructive)
        default:
            EmptyView()
        }
    }

    private var fill: Color {
        switch state {
        case .correct: return VerbsyDesign.sageSoft
        case .wrong: return VerbsyDesign.destructive.opacity(0.10)
        default: return VerbsyDesign.surface
        }
    }

    private var stroke: Color {
        switch state {
        case .correct: return VerbsyDesign.sage
        case .wrong: return VerbsyDesign.destructive
        default: return VerbsyDesign.line
        }
    }
}

private struct FeedLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView().tint(VerbsyDesign.sage)
            Text("Gathering words…")
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundStyle(VerbsyDesign.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VerbsyDesign.background)
    }
}
