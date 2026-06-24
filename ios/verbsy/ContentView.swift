import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        AppRootView()
    }
}

private struct SplashView: View {
    @State private var markScale = 0.92
    @State private var markOpacity = 0.0

    var body: some View {
        ZStack {
            AppStyle.background.ignoresSafeArea()

            VStack(spacing: 22) {
                VerbsyMark(size: 112)
                    .scaleEffect(markScale)
                    .opacity(markOpacity)

                VStack(spacing: 6) {
                    Text("Verbsy")
                        .font(VerbsyDesign.display(40))
                        .foregroundStyle(AppStyle.ink)

                    Text("One new word every day.")
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .foregroundStyle(AppStyle.muted)
                }
                .opacity(markOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.78)) {
                markScale = 1
                markOpacity = 1
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var purchases: PurchaseManager

    let onCompleted: (_ wantsReminders: Bool, _ topics: [String], _ level: String) -> Void

    @State private var step = 0
    @State private var data = OnboardingData()
    @State private var isGenerating = false
    @State private var navigationDirection = NavigationDirection.forward

    private let totalSteps = 13

    var body: some View {
        ZStack {
            AppStyle.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if step > 0 {
                    ProgressHeader(
                        progress: min(CGFloat(step) / CGFloat(totalSteps), 1),
                        canGoBack: step > 1,
                        onBack: back,
                        onSkip: skipHandler
                    )
                }

                ZStack {
                    currentScreen
                        .id(step)
                        .transition(screenTransition)
                }
            }
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch step {
        case 0:
            WelcomeScreen(onContinue: next)
        case 1:
            MultiChoiceQuestion(
                title: "What do you want Verbsy to help with?",
                options: [
                    .init(title: "Sound more articulate", symbol: "quote.bubble.fill"),
                    .init(title: "Write with range", symbol: "pencil.and.outline"),
                    .init(title: "Explain feelings", symbol: "heart.text.square.fill"),
                    .init(title: "Think clearly", symbol: "sparkles")
                ],
                selections: $data.goals,
                minimumSelections: 1,
                onContinue: next
            )
        case 2:
            SingleChoiceQuestion(
                title: "How strong is your vocabulary right now?",
                subtitle: "We'll calibrate your first words to the right level.",
                options: [
                    .init(title: "Casual", symbol: "leaf.fill"),
                    .init(title: "Curious", symbol: "magnifyingglass"),
                    .init(title: "Advanced", symbol: "graduationcap.fill")
                ],
                selection: $data.level,
                onContinue: next
            )
        case 3:
            MultiChoiceQuestion(
                title: "What usually gets in the way?",
                options: [
                    .init(title: "I forget them", symbol: "arrow.counterclockwise"),
                    .init(title: "I don't use them", symbol: "person.wave.2.fill"),
                    .init(title: "No daily routine", symbol: "calendar.badge.clock"),
                    .init(title: "Boring lessons", symbol: "wand.and.stars")
                ],
                selections: $data.obstacles,
                minimumSelections: 1,
                onContinue: next
            )
        case 4:
            MultiChoiceQuestion(
                title: "Choose topics you care about",
                subtitle: "Pick a few, or let Verbsy surprise you.",
                options: [
                    .init(title: "Surprise me", subtitle: "All topics, fully mixed", symbol: "sparkles", clearsOtherSelections: true),
                    .init(title: "Everyday Life", symbol: "cup.and.saucer.fill"),
                    .init(title: "People", symbol: "person.fill"),
                    .init(title: "Ambition", symbol: "briefcase.fill"),
                    .init(title: "Ideas", symbol: "brain.head.profile"),
                    .init(title: "Communication", symbol: "text.bubble.fill"),
                    .init(title: "Emotions", symbol: "heart.fill"),
                    .init(title: "Nature", symbol: "leaf.fill"),
                    .init(title: "Culture", symbol: "building.columns.fill"),
                    .init(title: "Rare Words", symbol: "sparkles")
                ],
                selections: $data.topics,
                minimumSelections: 1,
                allowsEmptySelection: true,
                onContinue: next
            )
        case 5:
            MultiChoiceQuestion(
                title: "Where should better words show up?",
                options: [
                    .init(title: "Conversations", symbol: "bubble.left.and.bubble.right.fill"),
                    .init(title: "Writing", symbol: "doc.text.fill"),
                    .init(title: "Work and school", symbol: "briefcase.fill"),
                    .init(title: "Self-understanding", symbol: "person.crop.circle.badge.checkmark")
                ],
                selections: $data.contexts,
                minimumSelections: 1,
                onContinue: next
            )
        case 6:
            SingleChoiceQuestion(
                title: "How much time can you give each day?",
                subtitle: "Verbsy works best when the habit feels effortless.",
                options: [
                    .init(title: "1 minute", symbol: "timer"),
                    .init(title: "3 minutes", symbol: "timer.circle.fill"),
                    .init(title: "5 minutes", symbol: "clock.badge.checkmark.fill")
                ],
                selection: $data.dailyTime,
                onContinue: next
            )
        case 7:
            DailyLearningPreviewScreen(onContinue: next)
        case 8:
            SingleChoiceQuestion(
                title: "Would you like daily word reminders?",
                subtitle: "We will use this later to help protect your streak.",
                options: [
                    .init(title: "Yes", symbol: "bell.badge.fill"),
                    .init(title: "Not yet", symbol: "bell.slash.fill")
                ],
                selection: $data.reminders,
                onContinue: continueFromReminderChoice
            )
        case 9:
            WidgetPreviewScreen(onContinue: next)
        case 10:
            GeneratePlanIntro(onContinue: startGenerating)
        case 11:
            GeneratingPlanScreen(
                goal: data.primaryGoal,
                level: data.level,
                topics: data.topics,
                isGenerating: $isGenerating,
                onComplete: next
            )
        case 12:
            PlanRevealScreen(data: data, onContinue: next)
        default:
            StorePaywallView(
                canContinueFree: true,
                onContinueFree: {
                    onCompleted(data.reminders == "Yes", Array(data.topics), data.level)
                },
                onCompleted: {
                    onCompleted(data.reminders == "Yes", Array(data.topics), data.level)
                }
            )
            .environmentObject(purchases)
        }
    }

    private var skipHandler: (() -> Void)? {
        guard (1...9).contains(step) else { return nil }
        return { next() }
    }

    private func next() {
        Haptics.selection()
        navigationDirection = .forward
        withAnimation(onboardingStepAnimation) {
            step += 1
        }
    }

    private func back() {
        Haptics.selection()
        navigationDirection = .backward
        withAnimation(onboardingStepAnimation) {
            if step == 12 {
                isGenerating = false
                step = 10
            } else {
                if step == 11 {
                    isGenerating = false
                }
                step = max(0, step - 1)
            }
        }
    }

    private func startGenerating() {
        Haptics.impact()
        isGenerating = true
        next()
    }

    private func continueFromReminderChoice() {
        guard data.reminders == "Yes" else {
            next()
            return
        }
        Haptics.selection()
        navigationDirection = .forward
        Task {
            await NotificationScheduler.requestAuthorization()
            await MainActor.run {
                withAnimation(onboardingStepAnimation) {
                    step += 1
                }
            }
        }
    }

    private var screenTransition: AnyTransition {
        switch navigationDirection {
        case .forward:
            return .asymmetric(
                insertion: .modifier(
                    active: OnboardingStepTransition(xOffset: 34, opacity: 0),
                    identity: OnboardingStepTransition(xOffset: 0, opacity: 1)
                ),
                removal: .modifier(
                    active: OnboardingStepTransition(xOffset: -22, opacity: 0),
                    identity: OnboardingStepTransition(xOffset: 0, opacity: 1)
                )
            )
        case .backward:
            return .asymmetric(
                insertion: .modifier(
                    active: OnboardingStepTransition(xOffset: -34, opacity: 0),
                    identity: OnboardingStepTransition(xOffset: 0, opacity: 1)
                ),
                removal: .modifier(
                    active: OnboardingStepTransition(xOffset: 22, opacity: 0),
                    identity: OnboardingStepTransition(xOffset: 0, opacity: 1)
                )
            )
        }
    }

    private var onboardingStepAnimation: Animation {
        .smooth(duration: 0.32, extraBounce: 0)
    }
}

private struct OnboardingStepTransition: ViewModifier {
    let xOffset: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .offset(x: xOffset)
            .opacity(opacity)
            .scaleEffect(opacity < 1 ? 0.992 : 1)
    }
}

private enum NavigationDirection {
    case forward
    case backward
}

private struct OnboardingData {
    var goals: Set<String> = []
    var level = ""
    var obstacles: Set<String> = []
    var topics: Set<String> = []
    var contexts: Set<String> = []
    var dailyTime = ""
    var reminders = ""

    var primaryGoal: String {
        preferredValue(from: goals, orderedBy: [
            "Sound more articulate",
            "Write with range",
            "Explain feelings",
            "Think clearly"
        ])
    }

    var primaryContext: String {
        preferredValue(from: contexts, orderedBy: [
            "Conversations",
            "Writing",
            "Work and school",
            "Self-understanding"
        ])
    }

    var recommendedWord: WordRecommendation {
        let advanced = level == "Advanced"
        let emotional = topics.contains("Emotions") || goals.contains("Explain feelings")
        let writing = contexts.contains("Writing") || goals.contains("Write with range")

        if emotional {
            return .init(
                word: "Sonder",
                pronunciation: "SAHN-der",
                meaning: "The realization that every person has an inner life as vivid and complex as your own.",
                useCase: "Use it when you want to describe sudden empathy or perspective."
            )
        }

        if writing {
            return .init(
                word: advanced ? "Perspicuous" : "Lucid",
                pronunciation: advanced ? "per-SPIK-yoo-us" : "LOO-sid",
                meaning: advanced ? "Clearly expressed and easy to understand." : "Clear, bright, and easy to understand.",
                useCase: "Use it to praise writing, thinking, or explanations that feel clean and precise."
            )
        }

        return .init(
            word: advanced ? "Sagacious" : "Poised",
            pronunciation: advanced ? "suh-GAY-shus" : "POYZD",
            meaning: advanced ? "Having calm, practical wisdom and good judgment." : "Calm, composed, and self-assured.",
            useCase: "Use it when someone's presence feels steady, sharp, and controlled."
        )
    }

    private func preferredValue(from values: Set<String>, orderedBy preference: [String]) -> String {
        preference.first { values.contains($0) } ?? values.sorted().first ?? ""
    }
}

private struct WordRecommendation {
    let word: String
    let pronunciation: String
    let meaning: String
    let useCase: String
}

private struct ChoiceOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    var subtitle: String? = nil
    let symbol: String
    var clearsOtherSelections = false
}

private struct WelcomeScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 28)

            VStack(spacing: 28) {
                DailyWordPreview()
                    .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    Text("Build a stronger vocabulary")
                        .font(VerbsyDesign.display(42))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppStyle.ink)
                        .minimumScaleFactor(0.78)

                    Text("One powerful word each day, chosen for how you want to think, write, and speak.")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 24)
                }
            }

            Spacer(minLength: 24)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Get Started", action: onContinue)
        }
    }
}

private struct SingleChoiceQuestion: View {
    let title: String
    var subtitle: String? = nil
    let options: [ChoiceOption]
    @Binding var selection: String
    let onContinue: () -> Void

    var body: some View {
        QuestionContainer(title: title, subtitle: subtitle) {
            VStack(spacing: 10) {
                ForEach(options) { option in
                    ChoiceTile(
                        option: option,
                        isSelected: selection == option.title,
                        action: {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                selection = option.title
                            }
                        }
                    )
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Continue", isEnabled: !selection.isEmpty, action: onContinue)
        }
    }
}

private struct MultiChoiceQuestion: View {
    let title: String
    var subtitle: String? = nil
    let options: [ChoiceOption]
    @Binding var selections: Set<String>
    let minimumSelections: Int
    var allowsEmptySelection = false
    let onContinue: () -> Void

    private var canContinue: Bool {
        selections.count >= minimumSelections || (allowsEmptySelection && selections.isEmpty)
    }

    var body: some View {
        QuestionContainer(title: title, subtitle: subtitle) {
            if options.count > 6 {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(options) { option in
                        ChoiceTile(
                            option: option,
                            isSelected: isSelected(option),
                            isCompact: true,
                            action: { toggle(option) }
                        )
                    }
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(options) { option in
                        ChoiceTile(
                            option: option,
                            isSelected: isSelected(option),
                            action: { toggle(option) }
                        )
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(
                title: canContinue ? "Continue" : "Choose \(minimumSelections)",
                isEnabled: canContinue,
                action: onContinue
            )
        }
    }

    private func isSelected(_ option: ChoiceOption) -> Bool {
        option.clearsOtherSelections ? selections.isEmpty : selections.contains(option.title)
    }

    private func toggle(_ option: ChoiceOption) {
        Haptics.selection()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            if option.clearsOtherSelections {
                selections.removeAll()
                return
            }
            if selections.contains(option.title) {
                selections.remove(option.title)
            } else {
                selections.insert(option.title)
            }
        }
    }
}

private struct QuestionContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 9) {
                    Text(title)
                        .font(VerbsyDesign.display(30))
                        .foregroundStyle(AppStyle.ink)
                        .lineSpacing(0)
                        .minimumScaleFactor(0.82)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 15, weight: .medium, design: .default))
                            .foregroundStyle(AppStyle.muted)
                            .lineSpacing(2)
                    }
                }
                .padding(.top, 18)

                content
                    .padding(.bottom, 96)
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct DailyLearningPreviewScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            VStack(spacing: 26) {
                DailyWordPreview()
                    .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    Text("Learn with one word of the day")
                        .font(VerbsyDesign.display(36))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)

                    Text("A precise word, a memorable example, and a tiny recall loop. No clutter, no endless lessons.")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 24)
                }
            }

            Spacer(minLength: 28)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Continue", action: onContinue)
        }
    }
}

private struct WidgetPreviewScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 24) {
                VStack(spacing: 14) {
                    HStack(spacing: 12) {
                        WidgetMockCard(size: 112, word: "Lucid", definition: "Clear, bright, and easy to understand.")
                        WidgetMockCard(size: 112, word: "Aplomb", definition: "Grace under pressure.")
                    }

                    LockScreenWidgetMock()
                }
                .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    Text("Home and Lock Screen widgets")
                        .font(VerbsyDesign.display(36))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)

                    Text("Keep your daily word visible with beautiful widgets you can style for your Home Screen or Lock Screen.")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 24)
                }
            }

            Spacer(minLength: 28)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Continue", action: onContinue)
        }
    }
}

private struct WidgetMockCard: View {
    let size: CGFloat
    let word: String
    let definition: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VerbsyMark(size: size > 100 ? 28 : 20)
                Spacer()
                Image(systemName: "sparkle")
                    .font(.system(size: size > 100 ? 15 : 11, weight: .bold))
                    .foregroundStyle(AppStyle.gold)
            }

            Spacer()

            Text(word)
                .font(.system(size: size > 100 ? 25 : 16, weight: .black, design: .default))
                .foregroundStyle(AppStyle.ink)
                .minimumScaleFactor(0.75)

            Text(definition)
                .font(.system(size: size > 100 ? 13 : 9, weight: .semibold, design: .default))
                .foregroundStyle(AppStyle.muted)
                .lineLimit(size > 100 ? 3 : 2)
        }
        .padding(size > 100 ? 16 : 10)
        .frame(width: size, height: size)
        .background(AppStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(AppStyle.line))
        .shadow(color: .black.opacity(0.07), radius: 18, x: 0, y: 10)
    }
}

private struct LockScreenWidgetMock: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 14, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("Sonder")
                    .font(.system(size: 14, weight: .black, design: .default))
                Text("Everyone has a hidden inner life.")
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(AppStyle.ink)
        .padding(.horizontal, 12)
        .frame(width: 252, height: 54, alignment: .leading)
        .background(AppStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppStyle.line))
    }
}

private struct GeneratePlanIntro: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .fill(AppStyle.softBlue)
                        .frame(width: 226, height: 226)

                    Circle()
                        .fill(.white)
                        .frame(width: 156, height: 156)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(AppStyle.ink)
                }

                VStack(spacing: 12) {
                    Label("All done", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundStyle(AppStyle.sage)

                    Text("Time to generate your personal word plan")
                        .font(VerbsyDesign.display(37))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)
                        .padding(.horizontal, 20)
                }
            }

            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Generate My Plan", action: onContinue)
        }
    }
}

private struct GeneratingPlanScreen: View {
    let goal: String
    let level: String
    let topics: Set<String>
    @Binding var isGenerating: Bool
    let onComplete: () -> Void

    @State private var progress = 0.0
    @State private var activeStage = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 36)

            VStack(spacing: 28) {
                PlanBuildOrb(progress: progress)

                VStack(spacing: 10) {
                    Text("Building your word plan")
                        .font(VerbsyDesign.display(32))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)

                    Text(stageText)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(minHeight: 44)
                        .padding(.horizontal, 12)
                        .contentTransition(.opacity)
                }

                ProgressView(value: progress)
                    .tint(AppStyle.sage)
                    .scaleEffect(x: 1, y: 1.25)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 26)
            .padding(.vertical, 30)
            .background(AppStyle.surface)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(AppStyle.line, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 22, x: 0, y: 12)
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            Task {
                await runGenerationSequence()
                if isGenerating {
                    isGenerating = false
                    Haptics.success()
                    onComplete()
                }
            }
        }
    }

    @MainActor
    private func runGenerationSequence() async {
        let stages: [(Double, UInt64)] = [
            (0.18, 700_000_000),
            (0.46, 850_000_000),
            (0.74, 850_000_000),
            (1.0, 650_000_000)
        ]

        for (index, stage) in stages.enumerated() {
            withAnimation(.smooth(duration: 0.34, extraBounce: 0)) {
                activeStage = index
                progress = stage.0
            }
            try? await Task.sleep(nanoseconds: stage.1)
        }
    }

    private var stageText: String {
        let focus = topics.sorted().prefix(2).joined(separator: " + ")
        let stages = [
            level.isEmpty ? "Choosing the right starting level" : "Tuning your starting level",
            focus.isEmpty ? "Matching words to your interests" : "Matching words to \(focus)",
            goal.isEmpty ? "Shaping examples for everyday use" : "Shaping examples for \(goal.lowercased())",
            "Preparing your first word"
        ]
        return stages[min(activeStage, stages.count - 1)]
    }
}

private struct PlanBuildOrb: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(AppStyle.sage.opacity(0.12))
                .frame(width: 178, height: 178)

            Circle()
                .stroke(AppStyle.line, lineWidth: 12)
                .frame(width: 142, height: 142)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppStyle.sage, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 142, height: 142)
                .rotationEffect(.degrees(-90))

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppStyle.surface)
                .frame(width: 92, height: 92)
                .overlay(
                    Image(systemName: progress >= 1 ? "checkmark.seal.fill" : "text.book.closed.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(progress >= 1 ? AppStyle.sage : AppStyle.ink)
                )
                .shadow(color: .black.opacity(0.07), radius: 18, x: 0, y: 10)
        }
        .accessibilityHidden(true)
    }
}

private struct PlanRevealScreen: View {
    let data: OnboardingData
    let onContinue: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 26) {
                VStack(spacing: 14) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(AppStyle.ink)

                    Text("Your daily word plan is ready")
                        .font(VerbsyDesign.display(36))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)
                }
                .padding(.top, 26)

                WordPlanCard(word: data.recommendedWord)

                VStack(spacing: 14) {
                    PlanInfoRow(title: "Goal", value: data.primaryGoal.isEmpty ? "Build a stronger vocabulary" : data.primaryGoal, symbol: "target")
                    PlanInfoRow(title: "Daily pace", value: data.dailyTime.isEmpty ? "3 minutes" : data.dailyTime, symbol: "timer")
                    PlanInfoRow(title: "Focus", value: data.topics.isEmpty ? "Surprise me · all topics" : data.topics.sorted().prefix(3).joined(separator: ", "), symbol: "sparkles")
                }
                .padding(.bottom, 112)
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Let's get started", action: onContinue)
        }
    }
}

private struct SaveProgressScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VerbsyMark(size: 112)

                VStack(spacing: 12) {
                    Text("Save your progress")
                        .font(VerbsyDesign.display(40))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)

                    Text("For now, Verbsy runs locally on this device. Accounts and syncing can be added later.")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 26)
                }

                Button(action: onContinue) {
                    HStack(spacing: 14) {
                        Image(systemName: "iphone")
                            .font(.system(size: 24, weight: .semibold))
                        Text("Continue on this device")
                            .font(.system(size: 20, weight: .bold, design: .default))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 66)
                    .background(AppStyle.sage)
                    .clipShape(Capsule())
                }
                .buttonStyle(.pressable)
                .padding(.horizontal, 24)
            }

            Spacer()
        }
    }
}

private struct PaywallScreen: View {
    let onStartTrial: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("Try Verbsy Pro free")
                    .font(VerbsyDesign.display(38))
                    .foregroundStyle(AppStyle.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(-1)
                    .padding(.top, 26)
                    .padding(.horizontal, 8)

                VStack(alignment: .leading, spacing: 24) {
                    TimelineRow(symbol: "lock.open.fill", title: "Today", detail: "Unlock widgets, daily word reminders, and faster widget rotation.", isLast: false)
                    TimelineRow(symbol: "bell.fill", title: "Day 2 - Reminder", detail: "We will remind you before your trial ends.", isLast: false)
                    TimelineRow(symbol: "crown.fill", title: "Day 3 - Billing Starts", detail: "Your subscription begins unless you cancel before the trial ends.", isLast: true)
                }
                .padding(.horizontal, 8)

                HStack(spacing: 14) {
                    PlanOption(title: "Monthly", price: "$9.99 /mo", isSelected: false, badge: nil)
                    PlanOption(title: "Yearly", price: "$29.99", isSelected: true, badge: "3 DAYS FREE")
                }

                Label("No payment due during the trial", systemImage: "checkmark")
                    .font(.system(size: 25, weight: .black, design: .default))
                    .foregroundStyle(AppStyle.ink)

                Button(action: onStartTrial) {
                    Text("Start My 3-Day Free Trial")
                        .font(.system(size: 21, weight: .black, design: .default))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(AppStyle.sage)
                        .clipShape(Capsule())
                }
                .buttonStyle(.pressable)

                VStack(spacing: 12) {
                    Text("Restore purchases from the Pro screen.")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundStyle(AppStyle.muted)

                    Text("3 days free, then $29.99 per year. Plan auto-renews unless canceled at least 24 hours before renewal.")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text("Terms - Privacy - Restore")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundStyle(AppStyle.muted)
                }
                .padding(.bottom, 36)
            }
            .padding(.horizontal, 24)
        }
    }
}

private struct ProgressHeader: View {
    let progress: CGFloat
    let canGoBack: Bool
    let onBack: () -> Void
    var onSkip: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 18) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(canGoBack ? AppStyle.ink : AppStyle.muted.opacity(0.35))
                    .frame(width: 58, height: 58)
                    .background(AppStyle.panel)
                    .clipShape(Circle())
            }
            .disabled(!canGoBack)
            .buttonStyle(.pressable)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppStyle.line)
                        .frame(height: 5)

                    Capsule()
                        .fill(AppStyle.ink)
                        .frame(width: max(20, geometry.size.width * progress), height: 5)
                }
            }
            .frame(height: 5)

            if let onSkip {
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundStyle(AppStyle.muted)
                }
                .buttonStyle(.pressable)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

private struct ChoiceTile: View {
    let option: ChoiceOption
    let isSelected: Bool
    var isCompact = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: isCompact ? 9 : 12) {
                Image(systemName: isSelected ? "checkmark" : option.symbol)
                    .font(.system(size: isCompact ? 15 : 17, weight: .bold))
                    .foregroundStyle(isSelected ? AppStyle.ink : AppStyle.sage)
                    .frame(width: isCompact ? 30 : 34, height: isCompact ? 30 : 34)
                    .background(isSelected ? AppStyle.surface : AppStyle.sage.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.system(size: isCompact ? 14.5 : 16, weight: .semibold, design: .default))
                        .foregroundStyle(isSelected ? .white : AppStyle.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundStyle(isSelected ? .white.opacity(0.72) : AppStyle.muted)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, isCompact ? 10 : 13)
            .frame(minHeight: isCompact ? 54 : 58)
            .background(isSelected ? AppStyle.ink : AppStyle.panel)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? AppStyle.ink : AppStyle.line.opacity(0.55), lineWidth: 1)
            )
        }
        .buttonStyle(.pressable)
    }
}

private struct PrimaryBottomButton: View {
    let title: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppStyle.line.opacity(0.7))
                .frame(height: 1)

            Button(action: {
                guard isEnabled else {
                    Haptics.warning()
                    return
                }
                action()
            }) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isEnabled ? AppStyle.sage : AppStyle.disabled)
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 10)
            }
            .buttonStyle(.pressable)
        }
        .background(.ultraThinMaterial)
    }
}

private struct DailyWordPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VerbsyMark(size: 46)
                Spacer()
                Text("Day 1")
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundStyle(AppStyle.muted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppStyle.panel)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Sonder")
                    .font(VerbsyDesign.display(46))
                    .foregroundStyle(AppStyle.ink)

                Text("The realization that every person has an inner life as vivid and complex as your own.")
                    .font(.system(size: 19, weight: .medium, design: .default))
                    .foregroundStyle(AppStyle.muted)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                MiniStat(symbol: "brain.head.profile", title: "Meaning")
                MiniStat(symbol: "text.bubble.fill", title: "Use it")
                MiniStat(symbol: "checkmark.seal.fill", title: "Review")
            }
        }
        .padding(22)
        .background(AppStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 24, x: 0, y: 14)
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(AppStyle.line, lineWidth: 1)
        )
    }
}

private struct WordPlanCard: View {
    let word: WordRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your first word")
                        .font(.system(size: 17, weight: .bold, design: .default))
                        .foregroundStyle(AppStyle.muted)

                    Text(word.word)
                        .font(VerbsyDesign.display(46))
                        .foregroundStyle(AppStyle.ink)
                }

                Spacer()
            }

            Text(word.pronunciation)
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundStyle(AppStyle.sage)

            Divider()

            Text(word.meaning)
                .font(.system(size: 19, weight: .semibold, design: .default))
                .foregroundStyle(AppStyle.ink)
                .lineSpacing(4)

            Text(word.useCase)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(AppStyle.muted)
                .lineSpacing(3)
        }
        .padding(22)
        .background(AppStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(AppStyle.line, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.07), radius: 18, x: 0, y: 10)
    }
}

private struct VerbsyMark: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(AppStyle.ink)
                .frame(width: size, height: size)

            Image(systemName: "text.book.closed.fill")
                .font(.system(size: size * 0.45, weight: .black))
                .foregroundStyle(.white)

            Circle()
                .fill(AppStyle.gold)
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: size * 0.28, y: -size * 0.28)
        }
    }
}

private struct ProofMetric: View {
    let value: String
    let label: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(tint)

            Text(value)
                .font(VerbsyDesign.display(33))
                .foregroundStyle(AppStyle.ink)

            Text(label)
                .font(.system(size: 15, weight: .bold, design: .default))
                .foregroundStyle(AppStyle.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppStyle.line, lineWidth: 1)
        )
    }
}

private struct TestimonialCard: View {
    let name: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundStyle(AppStyle.gold)
                    }
                }
                Spacer()
                Text(name)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundStyle(AppStyle.muted)
            }

            Text(text)
                .font(.system(size: 19, weight: .medium, design: .default))
                .foregroundStyle(AppStyle.ink)
                .lineSpacing(3)
        }
        .padding(20)
        .background(AppStyle.panel)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct PlanInfoRow: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppStyle.ink)
                .frame(width: 54, height: 54)
                .background(AppStyle.panel)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundStyle(AppStyle.muted)

                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundStyle(AppStyle.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer()
        }
        .padding(18)
        .background(AppStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppStyle.line, lineWidth: 1)
        )
    }
}

private struct TimelineRow: View {
    let symbol: String
    let title: String
    let detail: String
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isLast ? AppStyle.ink : AppStyle.gold)
                        .frame(width: 54, height: 54)
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                }

                if !isLast {
                    Rectangle()
                        .fill(AppStyle.gold.opacity(0.35))
                        .frame(width: 8, height: 52)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 23, weight: .black, design: .default))
                    .foregroundStyle(AppStyle.ink)
                Text(detail)
                    .font(.system(size: 17, weight: .medium, design: .default))
                    .foregroundStyle(AppStyle.muted)
                    .lineSpacing(3)
            }
        }
    }
}

private struct PlanOption: View {
    let title: String
    let price: String
    let isSelected: Bool
    let badge: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let badge {
                Text(badge)
                    .font(.system(size: 12, weight: .black, design: .default))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppStyle.ink)
                    .clipShape(Capsule())
                    .offset(y: -18)
                    .padding(.bottom, -18)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .default))
                    Text(price)
                        .font(.system(size: 24, weight: .black, design: .default))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(isSelected ? AppStyle.ink : AppStyle.muted.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(18)
        .background(AppStyle.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isSelected ? AppStyle.ink : AppStyle.muted.opacity(0.35), lineWidth: isSelected ? 3 : 1.5)
        )
    }
}

private struct MiniStat: View {
    let symbol: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppStyle.ink)
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .default))
                .foregroundStyle(AppStyle.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppStyle.panel)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

/// Onboarding style tokens forward to the unified Sage Scholar system
/// in `VerbsyDesign` (see brand_guide.md) so there is one source of truth.
private enum AppStyle {
    static let background = VerbsyDesign.background
    static let surface = VerbsyDesign.surface
    static let panel = VerbsyDesign.panel
    static let selectedTile = VerbsyDesign.sageSoft
    static let line = VerbsyDesign.line
    static let ink = VerbsyDesign.ink
    static let muted = VerbsyDesign.muted
    static let disabled = VerbsyDesign.disabled
    static let sage = VerbsyDesign.sage
    static let gold = VerbsyDesign.gold
    static let softBlue = VerbsyDesign.sageSoft
}

enum Haptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func impact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
