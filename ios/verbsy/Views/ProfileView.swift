import SwiftUI
import UIKit
import UserNotifications

/// Deep-link targets used by Home tiles and Profile rows.
enum ProfileRoute: Hashable {
    case favorites
    case topics
    case difficulty
    case widgets
    case notifications
    case subscription
}

struct ProfileView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var progress: LocalProgressStore
    @EnvironmentObject private var prefs: PreferencesStore

    @Binding var showPaywall: Bool
    @Binding var requestedRoute: ProfileRoute?

    @State private var path: [ProfileRoute] = []
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VerbsyDesign.sectionGap) {
                    header

                    SettingsSection(title: "Learning") {
                        navRow(.favorites, symbol: "heart.fill", title: "Favorite words", detail: "\(progress.progress.favoritesCount) saved")
                        rowDivider
                        navRow(.topics, symbol: "square.grid.2x2.fill", title: "Topics", detail: prefs.isSurpriseMe ? "Surprise me · all topics" : prefs.selectedTopics.prefix(2).joined(separator: ", "))
                        rowDivider
                        navRow(.difficulty, symbol: "dial.medium.fill", title: "Difficulty", detail: difficultyDetail)
                    }

                    SettingsSection(title: "Daily habit") {
                        gatedRow(.notifications, symbol: "bell.fill", title: "Word of the day", detail: purchases.isPro ? "A push notification each morning" : "Verbsy Pro")
                        rowDivider
                        gatedRow(.widgets, symbol: "rectangle.on.rectangle.angled", title: "Home Screen widgets", detail: purchases.isPro ? "A word on your Home & Lock Screen" : "Verbsy Pro")
                    }

                    SettingsSection(title: "Verbsy Pro") {
                        navRow(.subscription, symbol: purchases.isPro ? "checkmark.seal.fill" : "sparkles",
                               title: purchases.isPro ? "Verbsy Pro is active" : "Upgrade to Verbsy Pro",
                               detail: purchases.isPro ? "Manage your subscription" : "Widgets, daily words, and more")
                        rowDivider
                        Button { Task { await purchases.restore() } } label: {
                            SettingsRowContent(symbol: "arrow.clockwise", title: "Restore Purchases", detail: "Restore an existing subscription.", showsChevron: false)
                        }
                        .buttonStyle(.pressable)
                    }

                    SettingsSection(title: "Support & legal") {
                        Link(destination: URL(string: "https://verbsy.app/support")!) {
                            SettingsRowContent(symbol: "questionmark.circle.fill", title: "Support", detail: "Contact support@verbsy.app.")
                        }
                        rowDivider
                        Link(destination: URL(string: "https://verbsy.app/privacy")!) {
                            SettingsRowContent(symbol: "hand.raised.fill", title: "Privacy Policy", detail: "How Verbsy handles data.")
                        }
                        rowDivider
                        Link(destination: URL(string: "https://verbsy.app/terms")!) {
                            SettingsRowContent(symbol: "doc.text.fill", title: "Terms of Use", detail: "Subscription and app terms.")
                        }
                    }

                    SettingsSection(title: "Local data") {
                        Button(role: .destructive) { showResetConfirmation = true } label: {
                            SettingsRowContent(symbol: "trash.fill", title: "Reset progress", detail: "Clear favorites, stats, and streak.", showsChevron: false, tint: VerbsyDesign.destructive)
                        }
                        .buttonStyle(.pressable)
                    }

                    if let status = purchases.statusMessage {
                        Text(status)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundStyle(VerbsyDesign.muted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, VerbsyDesign.pageGutter)
                .padding(.vertical, 20)
            }
            .background(VerbsyDesign.background.ignoresSafeArea())
            .navigationDestination(for: ProfileRoute.self) { destination in
                ProfileDestinationView(route: destination, showPaywall: $showPaywall)
            }
            .onChange(of: requestedRoute) { _, route in
                guard let route else { return }
                path = [route]
                requestedRoute = nil
            }
            .confirmationDialog("Reset local progress?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset Progress", role: .destructive) { progress.resetAll() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This clears only data stored on this device.")
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VerbsyLogo(size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("You")
                    .font(VerbsyDesign.display(30))
                    .foregroundStyle(VerbsyDesign.ink)
                Text(purchases.isPro ? "Verbsy Pro" : "Free plan")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundStyle(purchases.isPro ? VerbsyDesign.sage : VerbsyDesign.muted)
            }
            Spacer()
            if purchases.isPro {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(VerbsyDesign.gold)
                    .padding(10)
                    .background(VerbsyDesign.goldSoft)
                    .clipShape(Circle())
            }
        }
    }

    private var difficultyDetail: String {
        switch prefs.difficultyLevel {
        case "casual": return "Everyday"
        case "curious": return "Curious"
        case "advanced": return "Advanced"
        default: return "Advanced"
        }
    }

    private var rowDivider: some View {
        Divider().overlay(VerbsyDesign.line).padding(.leading, 68)
    }

    private func navRow(_ route: ProfileRoute, symbol: String, title: String, detail: String) -> some View {
        Button { path.append(route) } label: {
            SettingsRowContent(symbol: symbol, title: title, detail: detail)
        }
        .buttonStyle(.pressable)
    }

    private func gatedRow(_ route: ProfileRoute, symbol: String, title: String, detail: String) -> some View {
        Button {
            if purchases.isPro { path.append(route) } else { showPaywall = true }
        } label: {
            HStack(spacing: 0) {
                SettingsRowContent(symbol: symbol, title: title, detail: detail, showsChevron: purchases.isPro)
                if !purchases.isPro {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(VerbsyDesign.gold)
                        .padding(.trailing, 16)
                }
            }
        }
        .buttonStyle(.pressable)
    }

}

/// Shared detail builder so Home and Profile can each navigate to these screens
/// inside their own navigation stack — so Back returns to the originating tab.
struct ProfileDestinationView: View {
    let route: ProfileRoute
    @Binding var showPaywall: Bool

    var body: some View {
        switch route {
        case .favorites: FavoritesView()
        case .topics: TopicsPickerView()
        case .difficulty: DifficultyPickerView()
        case .widgets: WidgetsHelpView()
        case .notifications: NotificationsSettingsView()
        case .subscription: SubscriptionView(showPaywall: $showPaywall)
        }
    }
}

// MARK: - Favorites

private struct FavoritesView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var progress: LocalProgressStore
    @State private var query = ""
    @State private var selected: VerbsyWord?

    private var favorites: [VerbsyWord] {
        let all = content.words(for: progress.progress.favoriteSlugs)
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return all }
        return all.filter {
            $0.word.localizedCaseInsensitiveContains(trimmed) ||
            $0.shortDefinition.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                if !progress.progress.favoriteSlugs.isEmpty {
                    SearchField(text: $query)
                }
                if favorites.isEmpty {
                    EmptyStateCard(
                        symbol: "heart",
                        title: progress.progress.favoriteSlugs.isEmpty ? "No favorites yet" : "No matches",
                        detail: progress.progress.favoriteSlugs.isEmpty ? "Tap the heart on any word in Learn to save it here." : "Try a different search."
                    )
                } else {
                    ForEach(favorites) { word in
                        Button { selected = word } label: { FavoriteRow(word: word) }
                            .buttonStyle(.pressable)
                    }
                }
            }
            .padding(.horizontal, VerbsyDesign.pageGutter)
            .padding(.vertical, 18)
        }
        .background(VerbsyDesign.background.ignoresSafeArea())
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selected) { word in
            WordDetailSheet(word: word).environmentObject(progress)
        }
    }
}

private struct FavoriteRow: View {
    let word: VerbsyWord
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(word.word)
                    .font(VerbsyDesign.display(22))
                    .foregroundStyle(VerbsyDesign.ink)
                Text(word.shortDefinition)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(VerbsyDesign.muted.opacity(0.45))
                .padding(.top, 6)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(VerbsyDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(VerbsyDesign.line))
    }
}

// MARK: - Topics

private struct TopicsPickerView: View {
    @EnvironmentObject private var content: VerbsyContentStore
    @EnvironmentObject private var prefs: PreferencesStore

    private var topics: [String] {
        content.topics.isEmpty ? VerbsyCatalog.topics : content.topics
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Pick what you’re curious about, or let Verbsy surprise you.")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)

                surpriseTile

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(topics, id: \.self) { topic in
                        topicTile(topic)
                    }
                }
            }
            .padding(.horizontal, VerbsyDesign.pageGutter)
            .padding(.vertical, 18)
        }
        .background(VerbsyDesign.background.ignoresSafeArea())
        .navigationTitle("Topics")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var surpriseTile: some View {
        Button {
            Haptics.selection()
            prefs.setTopics([])
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(prefs.isSurpriseMe ? VerbsyDesign.onSage : VerbsyDesign.sage)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Surprise me")
                        .font(.system(size: 17, weight: .bold, design: .default))
                        .foregroundStyle(prefs.isSurpriseMe ? VerbsyDesign.onSage : VerbsyDesign.ink)
                    Text("All topics, fully mixed")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundStyle(prefs.isSurpriseMe ? VerbsyDesign.onSage.opacity(0.85) : VerbsyDesign.muted)
                }
                Spacer()
                if prefs.isSurpriseMe {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(VerbsyDesign.onSage)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(prefs.isSurpriseMe ? VerbsyDesign.sage : VerbsyDesign.surface)
            .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(prefs.isSurpriseMe ? Color.clear : VerbsyDesign.line))
        }
        .buttonStyle(.pressable)
    }

    private func topicTile(_ topic: String) -> some View {
        let selected = prefs.selectedTopics.contains(topic)
        return Button {
            Haptics.selection()
            var next = prefs.selectedTopics
            if selected { next.removeAll { $0 == topic } } else { next.append(topic) }
            prefs.setTopics(next)
        } label: {
            HStack {
                Text(topic)
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundStyle(selected ? VerbsyDesign.onSage : VerbsyDesign.ink)
                    .multilineTextAlignment(.leading)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(VerbsyDesign.onSage)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(selected ? VerbsyDesign.sage : VerbsyDesign.surface)
            .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(selected ? Color.clear : VerbsyDesign.line))
        }
        .buttonStyle(.pressable)
    }
}

// MARK: - Difficulty

private struct DifficultyPickerView: View {
    @EnvironmentObject private var prefs: PreferencesStore

    private let levels: [(id: String, title: String, detail: String)] = [
        ("casual", "Everyday", "Useful words you’ll reach for often"),
        ("curious", "Curious", "A little rarer, a little delightful"),
        ("advanced", "Advanced", "Sharp, sophisticated, and rare"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose how challenging your words feel.")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
                    .padding(.bottom, 4)

                ForEach(levels, id: \.id) { level in
                    let on = prefs.difficultyLevel == level.id
                    Button {
                        Haptics.selection()
                        prefs.setDifficultyLevel(level.id)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(level.title)
                                    .font(.system(size: 18, weight: .bold, design: .default))
                                    .foregroundStyle(VerbsyDesign.ink)
                                Text(level.detail)
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundStyle(VerbsyDesign.muted)
                            }
                            Spacer()
                            Image(systemName: on ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(on ? VerbsyDesign.sage : VerbsyDesign.muted.opacity(0.4))
                        }
                        .padding(18)
                        .background(VerbsyDesign.surface)
                        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(on ? VerbsyDesign.sage : VerbsyDesign.line, lineWidth: on ? 2 : 1))
                    }
                    .buttonStyle(.pressable)
                }
            }
            .padding(.horizontal, VerbsyDesign.pageGutter)
            .padding(.vertical, 18)
        }
        .background(VerbsyDesign.background.ignoresSafeArea())
        .navigationTitle("Difficulty")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Widgets help (Pro)

private struct WidgetsHelpView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Put a daily word on your Home and Lock Screen.")
                    .font(VerbsyDesign.display(24))
                    .foregroundStyle(VerbsyDesign.ink)

                stepRow(1, "Touch and hold your Home Screen until the apps jiggle.")
                stepRow(2, "Tap the + in the top corner, then search for “Verbsy.”")
                stepRow(3, "Choose a size, add it, and tap Done.")
                stepRow(4, "Touch and hold the widget, tap Edit Widget, then choose how often the word changes.")

                Text("Verbsy Pro unlocks Home Screen and Lock Screen widgets, all themes, and rotation options from every hour to once a day. New widgets default to every 3 hours.")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
                    .padding(.top, 4)
            }
            .padding(.horizontal, VerbsyDesign.pageGutter)
            .padding(.vertical, 18)
        }
        .background(VerbsyDesign.background.ignoresSafeArea())
        .navigationTitle("Widgets")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepRow(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(n)")
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundStyle(VerbsyDesign.onSage)
                .frame(width: 32, height: 32)
                .background(VerbsyDesign.sage)
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(VerbsyDesign.ink)
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(VerbsyDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(VerbsyDesign.line))
    }
}

// MARK: - Notifications (Pro)

private struct NotificationsSettingsView: View {
    @EnvironmentObject private var prefs: PreferencesStore
    @AppStorage("verbsy.wantsReminders") private var wantsReminders = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var reminderTime = Date()
    @State private var authStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Get a push notification with a new word — delivered right to your Lock Screen.")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
                    .padding(.horizontal, 4)

                Toggle(isOn: $wantsReminders) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Word of the day")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundStyle(VerbsyDesign.ink)
                        Text("A gentle daily push notification.")
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundStyle(VerbsyDesign.muted)
                    }
                }
                .tint(VerbsyDesign.sage)
                .padding(18)
                .background(VerbsyDesign.surface)
                .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(VerbsyDesign.line))

                if wantsReminders && (authStatus == .denied) {
                    permissionNudge
                }

                if wantsReminders {
                    VStack(spacing: 0) {
                        Stepper(value: $prefs.wordsPerDay, in: 1...5) {
                            HStack {
                                Text("Words per day")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundStyle(VerbsyDesign.ink)
                                Spacer()
                                Text("\(prefs.wordsPerDay)")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .foregroundStyle(VerbsyDesign.sage)
                                    .monospacedDigit()
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)

                        Divider().overlay(VerbsyDesign.line)

                        DatePicker(
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        ) {
                            Text(prefs.wordsPerDay > 1 ? "First reminder" : "Reminder time")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundStyle(VerbsyDesign.ink)
                        }
                        .tint(VerbsyDesign.sage)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                    }
                    .background(VerbsyDesign.surface)
                    .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(VerbsyDesign.line))
                    .transition(.opacity)

                    Text(prefs.wordsPerDay > 1
                         ? "We’ll space \(prefs.wordsPerDay) words from your start time through the evening."
                         : "One new word each day, drawn from your chosen topics.")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundStyle(VerbsyDesign.muted)
                        .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal, VerbsyDesign.pageGutter)
            .padding(.vertical, 18)
            .animation(.easeInOut(duration: 0.2), value: wantsReminders)
            .animation(.easeInOut(duration: 0.2), value: authStatus)
        }
        .background(VerbsyDesign.background.ignoresSafeArea())
        .navigationTitle("Daily word")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reminderTime = timeFromPrefs()
            refreshAuthStatus()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refreshAuthStatus() }
        }
        .onChange(of: wantsReminders) { _, on in
            if on { reschedule() } else { NotificationScheduler.cancelWordReminders() }
        }
        .onChange(of: prefs.wordsPerDay) { _, _ in if wantsReminders { reschedule() } }
        .onChange(of: reminderTime) { _, newValue in
            let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            prefs.reminderHour = comps.hour ?? 9
            prefs.reminderMinute = comps.minute ?? 0
            if wantsReminders { reschedule() }
        }
    }

    private var permissionNudge: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(VerbsyDesign.gold)
                Text("Notifications are turned off")
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundStyle(VerbsyDesign.ink)
            }
            Text("Verbsy can’t send your word of the day until you allow notifications for Verbsy in iOS Settings.")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(VerbsyDesign.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                Haptics.selection()
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundStyle(VerbsyDesign.onSage)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(VerbsyDesign.sage)
                    .clipShape(Capsule())
            }
            .buttonStyle(.pressable)
        }
        .padding(18)
        .background(VerbsyDesign.goldSoft)
        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
        .transition(.opacity)
    }

    private func timeFromPrefs() -> Date {
        Calendar.current.date(bySettingHour: prefs.reminderHour, minute: prefs.reminderMinute, second: 0, of: Date()) ?? Date()
    }

    private func refreshAuthStatus() {
        Task { authStatus = await NotificationScheduler.authorizationStatus() }
    }

    private func reschedule() {
        Task {
            await NotificationScheduler.scheduleWordReminders(
                perDay: prefs.wordsPerDay,
                startHour: prefs.reminderHour,
                startMinute: prefs.reminderMinute,
                topics: prefs.selectedTopics,
                difficulties: prefs.effectiveDifficulties
            )
            authStatus = await NotificationScheduler.authorizationStatus()
        }
    }
}

// MARK: - Subscription

private struct SubscriptionView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Binding var showPaywall: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if purchases.isPro {
                    EmptyStateCard(symbol: "checkmark.seal.fill", title: "Verbsy Pro is active", detail: "Thank you for supporting Verbsy. Widgets and daily words are unlocked.")
                    Button {
                        Task { await purchases.manageSubscriptions() }
                    } label: {
                        SettingsRowContent(symbol: "person.crop.circle", title: "Manage subscription", detail: "Open Apple subscription settings.")
                            .background(VerbsyDesign.surface)
                            .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(VerbsyDesign.line))
                    }
                    .buttonStyle(.pressable)
                } else {
                    EmptyStateCard(symbol: "sparkles", title: "Verbsy Pro", detail: "Unlock Home Screen widgets and word-of-the-day notifications. The feed and quizzes stay free.")
                    Button {
                        showPaywall = true
                    } label: {
                        Text("See plans")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundStyle(VerbsyDesign.onSage)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(VerbsyDesign.sage)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.pressable)
                }

                Button { Task { await purchases.restore() } } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 15, weight: .bold, design: .default))
                        .foregroundStyle(VerbsyDesign.ink)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, VerbsyDesign.pageGutter)
            .padding(.vertical, 18)
        }
        .background(VerbsyDesign.background.ignoresSafeArea())
        .navigationTitle("Verbsy Pro")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Shared profile pieces

private struct EmptyStateCard: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(VerbsyDesign.sage)
            Text(title)
                .font(VerbsyDesign.display(23))
                .foregroundStyle(VerbsyDesign.ink)
            Text(detail)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(VerbsyDesign.muted)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(VerbsyDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous).stroke(VerbsyDesign.line))
    }
}

struct WordDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progress: LocalProgressStore
    let word: VerbsyWord

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(word.word)
                                .font(VerbsyDesign.display(44))
                                .foregroundStyle(VerbsyDesign.ink)
                            Text("\(word.pronunciation) · \(word.partOfSpeech)")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundStyle(VerbsyDesign.sage)
                        }
                        Spacer()
                        WordShareButton(word: word, compact: true)
                    }

                    Text(word.longDefinition)
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundStyle(VerbsyDesign.ink)
                        .lineSpacing(4)

                    detailBlock("Example", "“\(word.example)”", serif: true)
                    if let second = word.secondExample {
                        detailBlock("Another use", "“\(second)”", serif: true)
                    }
                    if let origin = word.origin {
                        detailBlock("Origin", origin, serif: false)
                    }
                    if !word.synonyms.isEmpty {
                        detailBlock("Similar words", word.synonyms.joined(separator: " · "), serif: false)
                    }

                    Button {
                        Haptics.selection()
                        progress.toggleFavorite(word)
                    } label: {
                        Label(progress.isFavorite(word) ? "Saved to favorites" : "Add to favorites",
                              systemImage: progress.isFavorite(word) ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundStyle(progress.isFavorite(word) ? VerbsyDesign.sage : VerbsyDesign.onSage)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(progress.isFavorite(word) ? VerbsyDesign.sageSoft : VerbsyDesign.sage)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.pressable)
                }
                .padding(.horizontal, VerbsyDesign.pageGutter)
                .padding(.vertical, 22)
            }
            .background(VerbsyDesign.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundStyle(VerbsyDesign.ink)
                }
            }
        }
    }

    private func detailBlock(_ title: String, _ body: String, serif: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow(text: title, color: VerbsyDesign.sage)
            Text(body)
                .font(serif ? .system(size: 18, weight: .regular, design: .serif) : .system(size: 16, weight: .medium, design: .default))
                .italic(serif)
                .foregroundStyle(VerbsyDesign.muted)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(VerbsyDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(VerbsyDesign.line))
    }
}
