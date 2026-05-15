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
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)

                    Text("A sharper word for every day.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
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

    let onCompleted: (Bool) -> Void

    @State private var step = 0
    @State private var data = OnboardingData()
    @State private var isGenerating = false
    @State private var navigationDirection = NavigationDirection.forward

    private let totalSteps = 17

    var body: some View {
        ZStack {
            AppStyle.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if step > 0 {
                    ProgressHeader(
                        progress: min(CGFloat(step) / CGFloat(totalSteps), 1),
                        canGoBack: step > 1,
                        onBack: back
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
            SingleChoiceQuestion(
                title: "What do you want Verbsy to help with?",
                subtitle: "This helps us shape your daily word plan.",
                options: [
                    .init(title: "Sound more articulate", subtitle: "Use precise words naturally", symbol: "quote.bubble.fill"),
                    .init(title: "Write with more range", subtitle: "Find stronger words faster", symbol: "pencil.and.outline"),
                    .init(title: "Explain feelings clearly", subtitle: "Build emotional vocabulary", symbol: "heart.text.square.fill"),
                    .init(title: "Think and speak sharper", subtitle: "Daily language for better ideas", symbol: "sparkles")
                ],
                selection: $data.goal,
                onContinue: next
            )
        case 2:
            SingleChoiceQuestion(
                title: "How strong is your vocabulary right now?",
                subtitle: "We will calibrate your first words to the right level.",
                options: [
                    .init(title: "Casual", subtitle: "I know common words and want range", symbol: "leaf.fill"),
                    .init(title: "Curious", subtitle: "I like learning better words", symbol: "magnifyingglass"),
                    .init(title: "Advanced", subtitle: "Challenge me with richer language", symbol: "graduationcap.fill")
                ],
                selection: $data.level,
                onContinue: next
            )
        case 3:
            SingleChoiceQuestion(
                title: "What usually gets in the way?",
                subtitle: "Your plan will be built around the obstacle you choose.",
                options: [
                    .init(title: "I forget new words", subtitle: "They do not stick long term", symbol: "arrow.counterclockwise"),
                    .init(title: "I do not use them", subtitle: "I learn words but never say them", symbol: "person.wave.2.fill"),
                    .init(title: "I lack a routine", subtitle: "I need a daily system", symbol: "calendar.badge.clock"),
                    .init(title: "I dislike boring lessons", subtitle: "I want learning to feel beautiful", symbol: "wand.and.stars")
                ],
                selection: $data.obstacle,
                onContinue: next
            )
        case 4:
            MultiChoiceQuestion(
                title: "Choose the topics you care about",
                subtitle: "Pick at least two. We will personalize your daily words.",
                options: [
                    .init(title: "Psychology", subtitle: nil, symbol: "brain.head.profile"),
                    .init(title: "Emotions", subtitle: nil, symbol: "heart.fill"),
                    .init(title: "Writing", subtitle: nil, symbol: "pencil.tip.crop.circle"),
                    .init(title: "Philosophy", subtitle: nil, symbol: "building.columns.fill"),
                    .init(title: "Productivity", subtitle: nil, symbol: "bolt.fill"),
                    .init(title: "Relationships", subtitle: nil, symbol: "person.2.fill")
                ],
                selections: $data.topics,
                minimumSelections: 2,
                onContinue: next
            )
        case 5:
            SingleChoiceQuestion(
                title: "Where do you want better words to show up?",
                subtitle: "This changes the examples and practice prompts you see.",
                options: [
                    .init(title: "Conversations", subtitle: "Sound clear in real life", symbol: "bubble.left.and.bubble.right.fill"),
                    .init(title: "Writing", subtitle: "Upgrade notes, essays, and posts", symbol: "doc.text.fill"),
                    .init(title: "Work and school", subtitle: "Communicate with confidence", symbol: "briefcase.fill"),
                    .init(title: "Self-understanding", subtitle: "Name what you feel and think", symbol: "person.crop.circle.badge.checkmark")
                ],
                selection: $data.context,
                onContinue: next
            )
        case 6:
            SingleChoiceQuestion(
                title: "How much time can you give each day?",
                subtitle: "Verbsy works best when the habit feels effortless.",
                options: [
                    .init(title: "1 minute", subtitle: "One word and a quick example", symbol: "timer"),
                    .init(title: "3 minutes", subtitle: "Word, example, and mini quiz", symbol: "timer.circle.fill"),
                    .init(title: "5 minutes", subtitle: "Deeper practice and review", symbol: "clock.badge.checkmark.fill")
                ],
                selection: $data.dailyTime,
                onContinue: next
            )
        case 7:
            ValueInterstitial(
                title: "Designed to make powerful words stick",
                subtitle: "Verbsy pairs one memorable word with context, emotion, and a tiny daily review loop.",
                onContinue: next
            )
        case 8:
            DailyLearningPreviewScreen(onContinue: next)
        case 9:
            SingleChoiceQuestion(
                title: "Would you like daily word reminders?",
                subtitle: "We will use this later to help protect your streak.",
                options: [
                    .init(title: "Yes", subtitle: "A gentle daily nudge", symbol: "bell.badge.fill"),
                    .init(title: "Not yet", subtitle: "I will explore first", symbol: "bell.slash.fill")
                ],
                selection: $data.reminders,
                onContinue: next
            )
        case 10:
            NotificationPreviewScreen(onContinue: next)
        case 11:
            WidgetPreviewScreen(onContinue: next)
        case 12:
            SocialProofScreen(onContinue: next)
        case 13:
            GeneratePlanIntro(onContinue: startGenerating)
        case 14:
            GeneratingPlanScreen(
                goal: data.goal,
                level: data.level,
                topics: data.topics,
                isGenerating: $isGenerating,
                onComplete: next
            )
        case 15:
            PlanRevealScreen(data: data, onContinue: next)
        case 16:
            SuccessPlanScreen(data: data, onContinue: next)
        default:
            StorePaywallView(
                canContinueFree: true,
                onContinueFree: {
                    onCompleted(data.reminders == "Yes")
                },
                onCompleted: {
                    onCompleted(data.reminders == "Yes")
                }
            )
            .environmentObject(purchases)
        }
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
            step = max(0, step - 1)
        }
    }

    private func startGenerating() {
        Haptics.impact()
        isGenerating = true
        next()
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
    var goal = ""
    var level = ""
    var obstacle = ""
    var topics: Set<String> = []
    var context = ""
    var dailyTime = ""
    var reminders = ""

    var recommendedWord: WordRecommendation {
        let advanced = level == "Advanced"
        let emotional = topics.contains("Emotions") || goal == "Explain feelings clearly"
        let writing = topics.contains("Writing") || context == "Writing"

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
    let subtitle: String?
    let symbol: String
}

private struct WelcomeScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 28)

            VStack(spacing: 28) {
                DailyWordPreview()
                    .padding(.horizontal, 28)

                VStack(spacing: 12) {
                    Text("Build a sharper vocabulary")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppStyle.ink)
                        .minimumScaleFactor(0.78)

                    Text("One powerful word each day, chosen for how you want to think, write, and speak.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
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
    let subtitle: String
    let options: [ChoiceOption]
    @Binding var selection: String
    let onContinue: () -> Void

    var body: some View {
        QuestionContainer(title: title, subtitle: subtitle) {
            VStack(spacing: 14) {
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
    let subtitle: String
    let options: [ChoiceOption]
    @Binding var selections: Set<String>
    let minimumSelections: Int
    let onContinue: () -> Void

    var body: some View {
        QuestionContainer(title: title, subtitle: subtitle) {
            VStack(spacing: 14) {
                ForEach(options) { option in
                    ChoiceTile(
                        option: option,
                        isSelected: selections.contains(option.title),
                        action: {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                if selections.contains(option.title) {
                                    selections.remove(option.title)
                                } else {
                                    selections.insert(option.title)
                                }
                            }
                        }
                    )
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(
                title: selections.count >= minimumSelections ? "Continue" : "Choose \(minimumSelections)",
                isEnabled: selections.count >= minimumSelections,
                action: onContinue
            )
        }
    }
}

private struct QuestionContainer<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 18) {
                    Text(title)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .lineSpacing(-1)
                        .minimumScaleFactor(0.76)

                    Text(subtitle)
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                        .lineSpacing(3)
                }
                .padding(.top, 28)

                content
                    .padding(.bottom, 110)
            }
            .padding(.horizontal, 28)
        }
    }
}

private struct ValueInterstitial: View {
    let title: String
    let subtitle: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            VStack(spacing: 30) {
                StickinessChart()

                VStack(spacing: 14) {
                    Text(title)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)

                    Text(subtitle)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 26)
                }
            }

            Spacer(minLength: 28)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Continue", action: onContinue)
        }
    }
}

private struct SocialProofScreen: View {
    let onContinue: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Text("Join learners building a more precise voice")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .lineSpacing(-1)
                    .padding(.top, 28)

                HStack(spacing: 14) {
                    ProofMetric(value: "4.9", label: "early rating", symbol: "star.fill", tint: AppStyle.gold)
                    ProofMetric(value: "1 word", label: "every day", symbol: "calendar", tint: AppStyle.sage)
                }

                TestimonialCard(
                    name: "Maya",
                    text: "The words feel useful, not academic. I actually remember them because the examples match real conversations."
                )

                TestimonialCard(
                    name: "Julian",
                    text: "It makes vocabulary feel premium and practical. The daily format is short enough to keep."
                )
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 110)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Continue", action: onContinue)
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
                    .padding(.horizontal, 28)

                VStack(spacing: 12) {
                    Text("Learn with one word of the day")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)

                    Text("A precise word, a memorable example, and a tiny recall loop. No clutter, no endless lessons.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
                }
            }

            Spacer(minLength: 28)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Continue", action: onContinue)
        }
    }
}

private struct NotificationPreviewScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        VerbsyMark(size: 34)
                        Text("VERBSY")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(AppStyle.muted)
                        Spacer()
                        Text("now")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(AppStyle.muted)
                    }

                    Text("Your Verbsy word is ready")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)

                    Text("Take one minute to add a sharper word to your day.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                }
                .padding(20)
                .background(.white.opacity(0.94))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(AppStyle.line))
                .shadow(color: .black.opacity(0.08), radius: 24, x: 0, y: 14)
                .padding(.horizontal, 28)

                VStack(spacing: 12) {
                    Text("A gentle reminder, not a noisy app")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)

                    Text("Verbsy helps you protect the habit with one clean daily nudge.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 32)
                }
            }

            Spacer()
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

            VStack(spacing: 26) {
                HStack(alignment: .bottom, spacing: 12) {
                    WidgetMockCard(size: 124, word: "Lucid", definition: "Clear, bright, and easy to understand.")
                    VStack(spacing: 12) {
                        WidgetMockCard(size: 78, word: "Aplomb", definition: "Grace under pressure.")
                        LockScreenWidgetMock()
                    }
                }
                .padding(.horizontal, 28)

                VStack(spacing: 12) {
                    Text("Put better words on your screen")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)

                    Text("Pro includes Home Screen and Lock Screen widgets for your word of the day.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
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
                .font(.system(size: size > 100 ? 25 : 16, weight: .black, design: .rounded))
                .foregroundStyle(AppStyle.ink)
                .minimumScaleFactor(0.75)

            Text(definition)
                .font(.system(size: size > 100 ? 13 : 9, weight: .semibold, design: .rounded))
                .foregroundStyle(AppStyle.muted)
                .lineLimit(size > 100 ? 3 : 2)
        }
        .padding(size > 100 ? 16 : 10)
        .frame(width: size, height: size)
        .background(.white)
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
                    .font(.system(size: 14, weight: .black, design: .rounded))
                Text("Everyone has a hidden inner life.")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(AppStyle.ink)
        .padding(.horizontal, 12)
        .frame(width: 122, height: 54)
        .background(.white)
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
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppStyle.sage)

                    Text("Time to generate your personal word plan")
                        .font(.system(size: 39, weight: .black, design: .rounded))
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

    var body: some View {
        VStack(spacing: 44) {
            Spacer(minLength: 80)

            VStack(spacing: 18) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 84, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)

                Text("We're setting everything up for you")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(-1)
                    .padding(.horizontal, 22)

                ProgressView(value: progress)
                    .tint(AppStyle.sage)
                    .scaleEffect(x: 1, y: 1.7)
                    .padding(.horizontal, 32)
                    .padding(.top, 10)
            }

            VStack(alignment: .leading, spacing: 17) {
                Text("Daily plan includes")
                    .font(.system(size: 22, weight: .black, design: .rounded))

                PlanGeneratingRow(text: "Word difficulty calibrated to \(level.isEmpty ? "your level" : level.lowercased())")
                PlanGeneratingRow(text: "Topics shaped around \(topics.isEmpty ? "your interests" : topics.prefix(2).joined(separator: " and "))")
                PlanGeneratingRow(text: "Practice prompts for \(goal.isEmpty ? "your goal" : goal.lowercased())")
                PlanGeneratingRow(text: "A lightweight review loop")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 36)

            Spacer()
        }
        .onAppear {
            progress = 0.17
            withAnimation(.easeInOut(duration: 2.1)) {
                progress = 1
            }

            Task {
                try? await Task.sleep(for: .seconds(2.35))
                if isGenerating {
                    isGenerating = false
                    Haptics.success()
                    onComplete()
                }
            }
        }
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
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-1)
                }
                .padding(.top, 26)

                WordPlanCard(word: data.recommendedWord)

                VStack(spacing: 14) {
                    PlanInfoRow(title: "Goal", value: data.goal.isEmpty ? "Build a sharper vocabulary" : data.goal, symbol: "target")
                    PlanInfoRow(title: "Daily pace", value: data.dailyTime.isEmpty ? "3 minutes" : data.dailyTime, symbol: "timer")
                    PlanInfoRow(title: "Focus", value: data.topics.isEmpty ? "Psychology, writing" : data.topics.sorted().prefix(3).joined(separator: ", "), symbol: "sparkles")
                }
                .padding(.bottom, 112)
            }
            .padding(.horizontal, 28)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Let's get started", action: onContinue)
        }
    }
}

private struct SuccessPlanScreen: View {
    let data: OnboardingData
    let onContinue: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("How Verbsy will help you improve")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)

                    VStack(spacing: 12) {
                        MethodRow(symbol: "1.circle.fill", title: "Learn one word worth keeping", detail: "No word dumps. One useful word gets the full treatment.")
                        MethodRow(symbol: "2.circle.fill", title: "See it in real context", detail: "Examples match how you want to write, speak, and think.")
                        MethodRow(symbol: "3.circle.fill", title: "Review before it fades", detail: "Tiny recall prompts help the word become usable.")
                        MethodRow(symbol: "4.circle.fill", title: "Build a visible streak", detail: "A premium daily ritual turns vocabulary into momentum.")
                    }
                }
                .padding(20)
                .background(AppStyle.panel)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppStyle.line, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 16) {
                    Text("Why Verbsy?")
                        .font(.system(size: 28, weight: .black, design: .rounded))

                    ComparisonRow(symbol: "xmark", tint: .red, text: "Random vocabulary lists are hard to remember")
                    ComparisonRow(symbol: "xmark", tint: .red, text: "Dictionary definitions rarely become daily language")
                    ComparisonRow(symbol: "checkmark", tint: AppStyle.sage, text: "Verbsy gives you a word, context, and recall loop")
                    ComparisonRow(symbol: "checkmark", tint: AppStyle.sage, text: "Your plan adapts to \(data.goal.isEmpty ? "your goals" : data.goal.lowercased())")
                }
                .padding(20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppStyle.line, lineWidth: 1)
                )
                .padding(.bottom, 112)
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryBottomButton(title: "Continue", action: onContinue)
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
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .multilineTextAlignment(.center)

                    Text("For now, Verbsy runs locally on this device. Accounts and syncing can be added later.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
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
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 66)
                    .background(AppStyle.ink)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
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
                Text("Start your 3-day FREE trial to continue")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(-1)
                    .padding(.top, 26)
                    .padding(.horizontal, 8)

                VStack(alignment: .leading, spacing: 24) {
                    TimelineRow(symbol: "lock.open.fill", title: "Today", detail: "Unlock your full daily vocabulary plan, review loop, and advanced word collections.", isLast: false)
                    TimelineRow(symbol: "bell.fill", title: "In 2 Days - Reminder", detail: "We will remind you before your trial would end once notifications are connected.", isLast: false)
                    TimelineRow(symbol: "crown.fill", title: "In 3 Days - Billing Starts", detail: "Payment is not implemented yet. This screen is a visual placeholder for the future trial wall.", isLast: true)
                }
                .padding(.horizontal, 8)

                HStack(spacing: 14) {
                    PlanOption(title: "Monthly", price: "$9.99 /mo", isSelected: false, badge: nil)
                    PlanOption(title: "Yearly", price: "$29.99", isSelected: true, badge: "3 DAYS FREE")
                }

                Label("No Payment Due Now", systemImage: "checkmark")
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)

                Button(action: onStartTrial) {
                    Text("Start My 3-Day Free Trial")
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(AppStyle.ink)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                VStack(spacing: 12) {
                    Text("Already purchased?")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)

                    Text("3 days free, then $29.99 per year. Plan auto-renews unless canceled. StoreKit will be connected later.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text("Terms - Privacy - Restore")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                }
                .padding(.bottom, 36)
            }
            .padding(.horizontal, 28)
        }
    }
}

private struct ProgressHeader: View {
    let progress: CGFloat
    let canGoBack: Bool
    let onBack: () -> Void

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
            .buttonStyle(.plain)

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
        }
        .padding(.horizontal, 28)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

private struct ChoiceTile: View {
    let option: ChoiceOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppStyle.ink : .white)
                        .frame(width: 58, height: 58)

                    Image(systemName: isSelected ? "checkmark" : option.symbol)
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(isSelected ? .white : AppStyle.ink)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(option.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.84)

                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .font(.system(size: 15.5, weight: .medium, design: .rounded))
                            .foregroundStyle(AppStyle.muted)
                            .lineLimit(2)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .frame(minHeight: 92)
            .background(isSelected ? AppStyle.selectedTile : AppStyle.panel)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(isSelected ? AppStyle.ink : .clear, lineWidth: 1.4)
            )
        }
        .buttonStyle(.plain)
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
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 68)
                    .background(isEnabled ? AppStyle.ink : AppStyle.disabled)
                    .clipShape(Capsule())
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
            }
            .buttonStyle(.plain)
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
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppStyle.panel)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Sonder")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)

                Text("The realization that every person has an inner life as vivid and complex as your own.")
                    .font(.system(size: 19, weight: .medium, design: .rounded))
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
        .background(.white)
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
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppStyle.muted)

                    Text(word.word)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(AppStyle.ink)
                }

                Spacer()

                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(AppStyle.ink)
                    .frame(width: 58, height: 58)
                    .background(AppStyle.panel)
                    .clipShape(Circle())
            }

            Text(word.pronunciation)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(AppStyle.sage)

            Divider()

            Text(word.meaning)
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(AppStyle.ink)
                .lineSpacing(4)

            Text(word.useCase)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppStyle.muted)
                .lineSpacing(3)
        }
        .padding(22)
        .background(.white)
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

private struct StickinessChart: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Word recall")
                .font(.system(size: 20, weight: .black, design: .rounded))

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white)
                    .frame(height: 210)

                Path { path in
                    path.move(to: CGPoint(x: 24, y: 160))
                    path.addCurve(to: CGPoint(x: 145, y: 108), control1: CGPoint(x: 70, y: 162), control2: CGPoint(x: 96, y: 132))
                    path.addCurve(to: CGPoint(x: 295, y: 52), control1: CGPoint(x: 198, y: 80), control2: CGPoint(x: 236, y: 58))
                }
                .stroke(AppStyle.sage, style: StrokeStyle(lineWidth: 8, lineCap: .round))

                Path { path in
                    path.move(to: CGPoint(x: 24, y: 72))
                    path.addCurve(to: CGPoint(x: 145, y: 132), control1: CGPoint(x: 68, y: 72), control2: CGPoint(x: 104, y: 86))
                    path.addCurve(to: CGPoint(x: 295, y: 168), control1: CGPoint(x: 190, y: 174), control2: CGPoint(x: 240, y: 178))
                }
                .stroke(AppStyle.muted.opacity(0.35), style: StrokeStyle(lineWidth: 8, lineCap: .round))

                VStack(alignment: .leading, spacing: 8) {
                    Label("Verbsy review loop", systemImage: "sparkles")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppStyle.sage)
                    Text("Random lists")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppStyle.muted)
                }
                .padding(18)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding(18)
        .background(AppStyle.panel)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .padding(.horizontal, 28)
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
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(AppStyle.ink)

            Text(label)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppStyle.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white)
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
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
            }

            Text(text)
                .font(.system(size: 19, weight: .medium, design: .rounded))
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
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.muted)

                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer()

            Image(systemName: "pencil")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppStyle.muted.opacity(0.55))
        }
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppStyle.line, lineWidth: 1)
        )
    }
}

private struct MethodRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppStyle.ink)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                Text(detail)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppStyle.muted)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct ComparisonRow: View {
    let symbol: String
    let tint: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)

            Text(text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(AppStyle.ink)
                .lineSpacing(2)
        }
    }
}

private struct PlanGeneratingRow: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(AppStyle.ink)
            .labelStyle(.titleAndIcon)
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
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .foregroundStyle(AppStyle.ink)
                Text(detail)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
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
                    .font(.system(size: 12, weight: .black, design: .rounded))
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
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(price)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(isSelected ? AppStyle.ink : AppStyle.muted.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(18)
        .background(.white)
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
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppStyle.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppStyle.panel)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private enum AppStyle {
    static let background = Color(red: 0.985, green: 0.982, blue: 0.973)
    static let panel = Color(red: 0.948, green: 0.947, blue: 0.936)
    static let selectedTile = Color(red: 0.925, green: 0.941, blue: 0.918)
    static let line = Color(red: 0.878, green: 0.876, blue: 0.86)
    static let ink = Color(red: 0.075, green: 0.07, blue: 0.095)
    static let muted = Color(red: 0.50, green: 0.50, blue: 0.52)
    static let disabled = Color(red: 0.72, green: 0.72, blue: 0.73)
    static let sage = Color(red: 0.24, green: 0.47, blue: 0.36)
    static let gold = Color(red: 0.82, green: 0.61, blue: 0.27)
    static let softBlue = Color(red: 0.87, green: 0.91, blue: 0.96)
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
