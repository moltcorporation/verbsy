import AppIntents
import SwiftUI
import WidgetKit

private struct WidgetWord: Codable {
    let word: String
    let pronunciation: String
    let partOfSpeech: String
    let shortDefinition: String
    let example: String
}

private struct VerbsyEntry: TimelineEntry {
    let date: Date
    let isPro: Bool
    let word: WidgetWord
    let theme: VerbsyWidgetTheme
}

enum VerbsyWidgetTheme: String, AppEnum {
    case paper
    case sage
    case ink
    case mist
    case clear
    case graphite

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Style")
    static var caseDisplayRepresentations: [VerbsyWidgetTheme: DisplayRepresentation] = [
        .paper: "Paper",
        .sage: "Sage",
        .ink: "Ink",
        .mist: "Mist",
        .clear: "Clear",
        .graphite: "Graphite"
    ]
}

struct VerbsyWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Word Widget"
    static var description = IntentDescription("Choose the visual style for your Verbsy word widget.")

    @Parameter(title: "Style", default: .paper)
    var theme: VerbsyWidgetTheme
}

private struct VerbsyProvider: AppIntentTimelineProvider {
    private let appGroup = "group.com.moltcorporation.verbsy"

    func placeholder(in context: Context) -> VerbsyEntry {
        VerbsyEntry(date: Date(), isPro: true, word: .sample, theme: .paper)
    }

    func snapshot(for configuration: VerbsyWidgetIntent, in context: Context) async -> VerbsyEntry {
        currentEntry(configuration: configuration)
    }

    func timeline(for configuration: VerbsyWidgetIntent, in context: Context) async -> Timeline<VerbsyEntry> {
        let entry = currentEntry(configuration: configuration)
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date().addingTimeInterval(10_800)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    private func currentEntry(configuration: VerbsyWidgetIntent) -> VerbsyEntry {
        let defaults = UserDefaults(suiteName: appGroup) ?? .standard
        let isPro = defaults.bool(forKey: "widget.isPro")
        let word: WidgetWord

        if
            let data = defaults.data(forKey: "widget.todayWord"),
            let decoded = try? JSONDecoder().decode(WidgetWord.self, from: data)
        {
            word = decoded
        } else {
            word = .sample
        }

        return VerbsyEntry(date: Date(), isPro: isPro, word: word, theme: configuration.theme)
    }
}

private extension WidgetWord {
    static let sample = WidgetWord(
        word: "Lucid",
        pronunciation: "LOO-sid",
        partOfSpeech: "adjective",
        shortDefinition: "Clear, bright, and easy to understand.",
        example: "Her explanation was lucid enough that the whole room relaxed."
    )
}

private struct VerbsyWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: VerbsyEntry

    var body: some View {
        if entry.isPro {
            proView
                .widgetURL(URL(string: "verbsy://today"))
        } else {
            lockedView
                .widgetURL(URL(string: "verbsy://paywall"))
        }
    }

    private var proView: some View {
        content
            .foregroundStyle(palette.primary)
        .containerBackground(for: .widget) {
            palette.background
        }
    }

    private var lockedView: some View {
        VStack(alignment: .leading, spacing: family == .accessoryRectangular ? 2 : 7) {
            Image(systemName: "crown.fill")
                .font(.system(size: family == .accessoryRectangular ? 13 : 20, weight: .bold))
                .foregroundStyle(palette.accent)
            Text(family == .accessoryCircular ? "Pro" : "Unlock daily words")
                .font(.system(size: lockTitleSize, weight: .black, design: .default))
                .lineLimit(family == .accessoryRectangular ? 1 : 3)
                .minimumScaleFactor(0.72)
            if family != .accessoryCircular {
                Text("Verbsy Pro")
                    .font(.system(size: 11, weight: .bold, design: .default))
                    .foregroundStyle(palette.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(contentPadding)
        .foregroundStyle(palette.primary)
        .containerBackground(for: .widget) {
            palette.background
        }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemLarge:
            largeView
        case .systemMedium:
            mediumView
        case .accessoryRectangular:
            rectangularView
        case .accessoryCircular:
            circularView
        case .accessoryInline:
            inlineView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            compactHeader
            Spacer(minLength: 4)
            wordText(size: 26)
            metaText(size: 11)
            definitionText(size: 13, lines: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(contentPadding)
    }

    private var mediumView: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 7) {
                compactHeader
                Spacer(minLength: 4)
                wordText(size: 34)
                metaText(size: 12)
            }
            .frame(maxWidth: 132, maxHeight: .infinity, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 8) {
                definitionText(size: 16, lines: 3)
                Divider().overlay(palette.secondary.opacity(0.28))
                Text(entry.word.example)
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundStyle(palette.secondary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(contentPadding)
    }

    private var largeView: some View {
        VStack(alignment: .leading, spacing: 10) {
            compactHeader
            Spacer(minLength: 6)
            wordText(size: 42)
            metaText(size: 13)
            definitionText(size: 19, lines: 4)
            Spacer(minLength: 4)
            Text(entry.word.example)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundStyle(palette.secondary)
                .lineLimit(4)
                .minimumScaleFactor(0.78)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(contentPadding)
    }

    private var rectangularView: some View {
        HStack(alignment: .top, spacing: 7) {
            if entry.theme != .clear {
                Text(String(entry.word.word.prefix(1)))
                    .font(.system(size: 15, weight: .black, design: .default))
                    .foregroundStyle(palette.accent)
                    .frame(width: 22, height: 22)
                    .background(palette.accent.opacity(0.13))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(entry.word.word)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)
                    .allowsTightening(true)
                Text(entry.word.shortDefinition)
                    .font(.system(size: 10.8, weight: .semibold, design: .default))
                    .foregroundStyle(palette.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .allowsTightening(true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var circularView: some View {
        VStack(spacing: 0) {
            Text(String(entry.word.word.prefix(1)))
                .font(.system(size: 28, weight: .bold, design: .serif))
                .minimumScaleFactor(0.7)
            Text(entry.word.partOfSpeech.prefix(4))
                .font(.system(size: 7.5, weight: .black, design: .default))
                .foregroundStyle(palette.secondary)
                .minimumScaleFactor(0.7)
        }
    }

    private var inlineView: some View {
        Text("\(entry.word.word): \(entry.word.shortDefinition)")
            .font(.system(size: 13, weight: .semibold, design: .default))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    private var compactHeader: some View {
        HStack {
            Text("Verbsy")
                .font(.system(size: 12, weight: .black, design: .default))
                .foregroundStyle(palette.secondary)
            Spacer()
            Text("Today")
                .font(.system(size: 11, weight: .black, design: .default))
                .foregroundStyle(palette.accent)
        }
    }

    private func wordText(size: CGFloat) -> some View {
        Text(entry.word.word)
            .font(.system(size: size, weight: .bold, design: .serif))
            .lineLimit(1)
            .minimumScaleFactor(0.52)
            .allowsTightening(true)
    }

    private func metaText(size: CGFloat) -> some View {
        Text("\(entry.word.pronunciation) · \(entry.word.partOfSpeech)")
            .font(.system(size: size, weight: .black, design: .default))
            .foregroundStyle(palette.accent)
            .lineLimit(1)
            .minimumScaleFactor(0.76)
    }

    private func definitionText(size: CGFloat, lines: Int) -> some View {
        Text(entry.word.shortDefinition)
            .font(.system(size: size, weight: .semibold, design: .default))
            .foregroundStyle(palette.secondary)
            .lineLimit(lines)
            .minimumScaleFactor(0.74)
            .allowsTightening(true)
    }

    private var contentPadding: CGFloat {
        switch family {
        case .systemMedium, .systemLarge:
            18
        case .accessoryRectangular, .accessoryCircular:
            0
        case .accessoryInline:
            0
        default:
            15
        }
    }

    private var lockTitleSize: CGFloat {
        switch family {
        case .accessoryRectangular:
            13
        case .accessoryCircular:
            12
        case .accessoryInline:
            12
        default:
            17
        }
    }

    private var palette: VerbsyWidgetPalette {
        VerbsyWidgetPalette(theme: entry.theme)
    }
}

private struct VerbsyWidgetPalette {
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color

    init(theme: VerbsyWidgetTheme) {
        switch theme {
        case .paper:
            // Sage Scholar — see brand_guide.md
            background = Color(red: 0.980, green: 0.973, blue: 0.949) // #FAF8F2
            primary = Color(red: 0.102, green: 0.098, blue: 0.086)    // #1A1916
            secondary = Color(red: 0.420, green: 0.416, blue: 0.388)  // #6B6A63
            accent = Color(red: 0.208, green: 0.420, blue: 0.322)     // #356B52 sage
        case .sage:
            background = Color(red: 0.855, green: 0.890, blue: 0.835) // soft sage
            primary = Color(red: 0.102, green: 0.160, blue: 0.120)
            secondary = Color(red: 0.240, green: 0.350, blue: 0.280)
            accent = Color(red: 0.208, green: 0.420, blue: 0.322)     // #356B52 sage
        case .ink:
            background = Color(red: 0.102, green: 0.098, blue: 0.086) // #1A1916
            primary = Color(red: 0.953, green: 0.945, blue: 0.914)    // warm off-white
            secondary = Color(red: 0.643, green: 0.631, blue: 0.600)
            accent = Color(red: 0.851, green: 0.659, blue: 0.353)     // #D9A85A gold
        case .mist:
            background = Color(red: 0.91, green: 0.94, blue: 0.95)
            primary = Color(red: 0.08, green: 0.10, blue: 0.13)
            secondary = Color(red: 0.36, green: 0.43, blue: 0.47)
            accent = Color(red: 0.30, green: 0.42, blue: 0.58)
        case .clear:
            background = Color.clear
            primary = .white
            secondary = .white.opacity(0.82)
            accent = .white.opacity(0.94)
        case .graphite:
            background = Color(red: 0.18, green: 0.18, blue: 0.18).opacity(0.82)
            primary = Color(red: 0.98, green: 0.98, blue: 0.96)
            secondary = Color(red: 0.82, green: 0.82, blue: 0.80)
            accent = Color(red: 0.72, green: 0.75, blue: 0.70)
        }
    }
}

@main
struct VerbsyWidgetBundle: WidgetBundle {
    var body: some Widget {
        VerbsyDailyWidget()
    }
}

struct VerbsyDailyWidget: Widget {
    let kind = "VerbsyDailyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: VerbsyWidgetIntent.self, provider: VerbsyProvider()) { entry in
            VerbsyWidgetView(entry: entry)
        }
        .configurationDisplayName("Word of the Day")
        .description("Keep one sharp word on your Home Screen or Lock Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryCircular, .accessoryInline])
        .contentMarginsDisabled()
    }
}
