import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: LocalProgressStore
    @EnvironmentObject private var purchases: PurchaseManager

    @Binding var showPaywall: Bool
    @Binding var requestedRoute: ProfileRoute?
    var openLearn: () -> Void

    @State private var path: [ProfileRoute] = []

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VerbsyDesign.sectionGap) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Eyebrow(text: greeting)
                            Text("Verbsy")
                                .font(VerbsyDesign.display(34))
                                .foregroundStyle(VerbsyDesign.ink)
                        }
                        Spacer()
                        VerbsyLogo(size: 44)
                    }

                    StreakHeroCard(progress: progress.progress)

                    Button(action: openLearn) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(progress.progress.todaySeen >= LocalProgress.dailyGoal ? "Keep going" : "Learn today’s words")
                                    .font(.system(size: 19, weight: .bold, design: .default))
                                    .foregroundStyle(VerbsyDesign.onSage)
                                Text("Scroll new words or take a quick quiz")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundStyle(VerbsyDesign.onSage.opacity(0.85))
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(VerbsyDesign.onSage)
                        }
                        .padding(20)
                        .background(VerbsyDesign.sage)
                        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous))
                    }
                    .buttonStyle(.pressable)

                    VStack(alignment: .leading, spacing: 12) {
                        Eyebrow(text: "Your library")
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            HomeTile(symbol: "heart.fill", title: "Favorites", value: "\(progress.progress.favoritesCount)", locked: false) {
                                path.append(.favorites)
                            }
                            HomeTile(symbol: "square.grid.2x2.fill", title: "Topics", value: nil, locked: false) {
                                path.append(.topics)
                            }
                            HomeTile(symbol: "rectangle.on.rectangle.angled", title: "Widgets", value: nil, locked: false) {
                                path.append(.widgets)
                            }
                            HomeTile(symbol: "bell.fill", title: "Daily word", value: nil, locked: !purchases.isPro) {
                                if purchases.isPro { path.append(.notifications) } else { showPaywall = true }
                            }
                        }
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
        }
    }
}

private struct StreakHeroCard: View {
    let progress: LocalProgress

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(VerbsyDesign.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text(progress.streak == 0 ? "Start your streak" : "\(progress.streak)-day streak")
                        .font(VerbsyDesign.display(26))
                        .foregroundStyle(VerbsyDesign.ink)
                    Text(streakSubtitle)
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundStyle(VerbsyDesign.muted)
                }
                Spacer()
                DailyRing(seen: progress.todaySeen, goal: LocalProgress.dailyGoal)
            }

            Divider().overlay(VerbsyDesign.line)

            HStack(spacing: 0) {
                stat(value: "\(progress.wordsLearned)", label: "Learned")
                divider
                stat(value: "\(progress.favoritesCount)", label: "Favorites")
                divider
                stat(value: accuracyText, label: "Quiz acc.")
            }
        }
        .padding(VerbsyDesign.cardPadding)
        .background(VerbsyDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous).stroke(VerbsyDesign.line))
        .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 12)
    }

    private var streakSubtitle: String {
        if progress.todaySeen >= LocalProgress.dailyGoal {
            return progress.streak > 0 ? "Today’s word is done — see you tomorrow" : "Nice — you’ve started"
        }
        return progress.streak == 0 ? "Learn one word today to begin" : "One word a day keeps it alive"
    }

    private var accuracyText: String {
        progress.quizAttempts > 0 ? "\(Int((progress.quizAccuracy * 100).rounded()))%" : "—"
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(VerbsyDesign.display(26))
                .foregroundStyle(VerbsyDesign.ink)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 12.5, weight: .semibold, design: .default))
                .foregroundStyle(VerbsyDesign.muted)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle().fill(VerbsyDesign.line).frame(width: 1, height: 34)
    }
}

private struct DailyRing: View {
    let seen: Int
    let goal: Int

    private var fraction: Double { min(Double(seen) / Double(max(goal, 1)), 1) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(VerbsyDesign.panel, lineWidth: 7)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(fraction >= 1 ? VerbsyDesign.gold : VerbsyDesign.sage, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(min(seen, goal))/\(goal)")
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundStyle(VerbsyDesign.ink)
                .monospacedDigit()
        }
        .frame(width: 56, height: 56)
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: fraction)
    }
}

private struct HomeTile: View {
    let symbol: String
    let title: String
    let value: String?
    let locked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: symbol)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(VerbsyDesign.sage)
                    Spacer()
                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(VerbsyDesign.gold)
                    } else if let value {
                        Text(value)
                            .font(VerbsyDesign.display(22))
                            .foregroundStyle(VerbsyDesign.ink)
                            .monospacedDigit()
                    }
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundStyle(VerbsyDesign.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .frame(height: 96)
            .background(VerbsyDesign.surface)
            .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(VerbsyDesign.line))
        }
        .buttonStyle(.pressable)
    }
}
