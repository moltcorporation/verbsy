import SwiftUI

struct AppRootView: View {
    @AppStorage("verbsy.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("verbsy.wantsReminders") private var wantsReminders = false

    @StateObject private var content = VerbsyContentStore()
    @StateObject private var purchases = PurchaseManager()
    @StateObject private var progress = LocalProgressStore()
    @StateObject private var prefs = PreferencesStore()

    @State private var isShowingSplash = true
    @State private var selectedTab = 0
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainAppView(
                    selectedTab: $selectedTab,
                    showPaywall: $showPaywall
                )
                .environmentObject(content)
                .environmentObject(purchases)
                .environmentObject(progress)
                .environmentObject(prefs)
                .opacity(isShowingSplash ? 0 : 1)
            } else {
                OnboardingView(
                    onCompleted: { wantsReminder, topics, level in
                        wantsReminders = wantsReminder
                        prefs.setTopics(topics)
                        prefs.applyLevel(level)
                        hasCompletedOnboarding = true
                        // Daily reminders are a Pro feature; schedule only once unlocked.
                        if wantsReminder && purchases.isPro { scheduleReminders() }
                    }
                )
                .environmentObject(purchases)
                .opacity(isShowingSplash ? 0 : 1)
            }

            if isShowingSplash {
                LaunchSplashView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .sheet(isPresented: $showPaywall) {
            StorePaywallView(
                canContinueFree: true,
                onContinueFree: { showPaywall = false },
                onCompleted: { showPaywall = false }
            )
            .environmentObject(purchases)
            .presentationDetents([.large])
        }
        .onOpenURL { url in
            switch url.host {
            case "paywall":
                showPaywall = true
            case "today", "learn":
                selectedTab = 1
            case "profile", "you":
                selectedTab = 2
            case "home":
                selectedTab = 0
            default:
                break
            }
        }
        .onChange(of: purchases.isPro) { _, isPro in
            // Honor the reminder opt-in once Pro; cancel if Pro lapses.
            if isPro && wantsReminders { scheduleReminders() }
            else if !isPro { NotificationScheduler.cancelWordReminders() }
            content.syncWidget(topics: prefs.selectedTopics, difficulties: prefs.effectiveDifficulties)
        }
        .onChange(of: prefs.selectedTopics) { _, _ in propagatePreferences() }
        .onChange(of: prefs.difficulties) { _, _ in propagatePreferences() }
        .task {
            await content.refresh()
            content.syncWidget(topics: prefs.selectedTopics, difficulties: prefs.effectiveDifficulties)
            // Notifications are one-shot; top up the schedule for Pro users on launch.
            if purchases.isPro && wantsReminders { scheduleReminders() }
            try? await Task.sleep(for: .seconds(1.1))
            withAnimation(.easeInOut(duration: 0.4)) {
                isShowingSplash = false
            }
        }
    }

    private func scheduleReminders() {
        Task {
            await NotificationScheduler.scheduleWordReminders(
                perDay: prefs.wordsPerDay,
                startHour: prefs.reminderHour,
                startMinute: prefs.reminderMinute,
                topics: prefs.selectedTopics,
                difficulties: prefs.effectiveDifficulties
            )
        }
    }

    /// When topics/difficulty change, keep the widget pool and (Pro) reminder
    /// words in sync with what the user now wants.
    private func propagatePreferences() {
        content.syncWidget(topics: prefs.selectedTopics, difficulties: prefs.effectiveDifficulties)
        if purchases.isPro && wantsReminders { scheduleReminders() }
    }
}

private struct LaunchSplashView: View {
    @State private var scale = 0.94
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            VerbsyDesign.background.ignoresSafeArea()

            VStack(spacing: 22) {
                VerbsyLogo(size: 112)
                VStack(spacing: 6) {
                    Text("Verbsy")
                        .font(VerbsyDesign.display(40))
                        .foregroundStyle(VerbsyDesign.ink)
                    Text("A sharper word for every day.")
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .foregroundStyle(VerbsyDesign.muted)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.82)) {
                scale = 1
                opacity = 1
            }
        }
    }
}

/// Verbsy "Sage Scholar" design system — single source of truth for color,
/// typography, spacing, and radius. See brand_guide.md. Light-first (warm paper).
enum VerbsyDesign {
    // MARK: Color — Sage Scholar
    static let background = Color(red: 0.980, green: 0.973, blue: 0.949) // #FAF8F2 paper
    static let surface    = Color(red: 1.000, green: 1.000, blue: 1.000) // #FFFFFF card
    static let panel      = Color(red: 0.953, green: 0.945, blue: 0.914) // #F3F1E9
    static let ink        = Color(red: 0.102, green: 0.098, blue: 0.086) // #1A1916
    static let muted      = Color(red: 0.420, green: 0.416, blue: 0.388) // #6B6A63
    static let line       = Color(red: 0.906, green: 0.894, blue: 0.851) // #E7E4D9
    static let sage       = Color(red: 0.208, green: 0.420, blue: 0.322) // #356B52 signature
    static let onSage     = Color.white                                   // text/icons on sage fills
    static let sageSoft   = Color(red: 0.894, green: 0.922, blue: 0.878) // #E4EBE0
    static let gold       = Color(red: 0.745, green: 0.541, blue: 0.239) // #BE8A3D achievement
    static let goldSoft   = Color(red: 0.953, green: 0.914, blue: 0.831) // #F3E9D4
    static let destructive = Color(red: 0.702, green: 0.251, blue: 0.184) // #B3402F
    static let disabled   = Color(red: 0.788, green: 0.776, blue: 0.741) // calm greige

    // MARK: Spacing scale (4/8pt rhythm)
    static let pageGutter: CGFloat = 24   // horizontal screen margin
    static let cardPadding: CGFloat = 22  // interior card padding
    static let sectionGap: CGFloat = 22   // vertical gap between major blocks

    // MARK: Radius scale
    static let radiusCard: CGFloat = 24
    static let radiusTile: CGFloat = 20
    static let radiusChip: CGFloat = 14

    // MARK: Typography — editorial serif (New York) for words/titles, neutral sans for UI
    /// Vocabulary words and display headlines (the literary, premium voice).
    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}

struct VerbsyLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(VerbsyDesign.ink)
            Image(systemName: "text.book.closed.fill")
                .font(.system(size: size * 0.45, weight: .black))
                .foregroundStyle(.white)
            Circle()
                .fill(VerbsyDesign.gold)
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: size * 0.28, y: -size * 0.28)
        }
        .frame(width: size, height: size)
    }
}
