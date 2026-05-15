import SwiftUI

struct AppRootView: View {
    @AppStorage("verbsy.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("verbsy.wantsReminders") private var wantsReminders = false

    @StateObject private var content = VerbsyContentStore()
    @StateObject private var purchases = PurchaseManager()
    @StateObject private var progress = LocalProgressStore()

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
                .opacity(isShowingSplash ? 0 : 1)
            } else {
                OnboardingView(
                    onCompleted: { wantsReminder in
                        wantsReminders = wantsReminder
                        hasCompletedOnboarding = true
                        showPaywall = false
                        if wantsReminder {
                            Task { await NotificationScheduler.scheduleDailyWordReminder() }
                        }
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
        .task {
            await content.refresh()
            try? await Task.sleep(for: .seconds(1.1))
            withAnimation(.easeInOut(duration: 0.4)) {
                isShowingSplash = false
            }
        }
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
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(VerbsyDesign.ink)
                    Text("A sharper word for every day.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
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

enum VerbsyDesign {
    static let background = Color(red: 0.985, green: 0.982, blue: 0.973)
    static let panel = Color(red: 0.948, green: 0.947, blue: 0.936)
    static let ink = Color(red: 0.075, green: 0.07, blue: 0.095)
    static let muted = Color(red: 0.50, green: 0.50, blue: 0.52)
    static let line = Color(red: 0.878, green: 0.876, blue: 0.86)
    static let sage = Color(red: 0.24, green: 0.47, blue: 0.36)
    static let gold = Color(red: 0.82, green: 0.61, blue: 0.27)
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
