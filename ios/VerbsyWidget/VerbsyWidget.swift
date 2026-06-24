import AppIntents
import SwiftUI
import WidgetKit

private struct WidgetWord: Codable {
    let slug: String?
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

private enum VerbsyWidgetPresentation: Equatable {
    case standard
    case homeDefinition
    case homeQuote
    case homeMinimal
    case lockDefinition
    case lockWord
    case lockExample
}

enum VerbsyWidgetTheme: String, AppEnum {
    case paper
    case sage
    case ink
    case mist
    case clear
    case graphite
    case gold
    case library

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Style")
    static var caseDisplayRepresentations: [VerbsyWidgetTheme: DisplayRepresentation] = [
        .paper: "Paper",
        .sage: "Sage",
        .ink: "Ink",
        .mist: "Mist",
        .clear: "Clear",
        .graphite: "Graphite",
        .gold: "Warm Gold",
        .library: "Library"
    ]
}

enum VerbsyWidgetRotation: String, AppEnum {
    case hourly
    case twoHours
    case threeHours
    case daily
    case twiceDaily
    case sixHours

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Change word")
    static var caseDisplayRepresentations: [VerbsyWidgetRotation: DisplayRepresentation] = [
        .hourly: "Every hour",
        .twoHours: "Every 2 hours",
        .threeHours: "Every 3 hours",
        .sixHours: "Every 6 hours",
        .twiceDaily: "Every 12 hours",
        .daily: "Once a day",
    ]

    var hours: Int {
        switch self {
        case .hourly: return 1
        case .twoHours: return 2
        case .threeHours: return 3
        case .sixHours: return 6
        case .twiceDaily: return 12
        case .daily: return 24
        }
    }
}

struct VerbsyWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Word Widget"
    static var description = IntentDescription("Choose the style and how often the word changes.")

    @Parameter(title: "Style", default: .paper)
    var theme: VerbsyWidgetTheme

    @Parameter(title: "Change word", default: .threeHours)
    var rotation: VerbsyWidgetRotation
}

private struct VerbsyProvider: AppIntentTimelineProvider {
    private let appGroup = "group.com.moltcorporation.verbsy"

    func placeholder(in context: Context) -> VerbsyEntry {
        VerbsyEntry(date: Date(), isPro: true, word: .sample, theme: .paper)
    }

    func snapshot(for configuration: VerbsyWidgetIntent, in context: Context) async -> VerbsyEntry {
        let defaults = UserDefaults(suiteName: appGroup) ?? .standard
        let words = loadWords(defaults)
        return VerbsyEntry(date: Date(), isPro: defaults.bool(forKey: "widget.isPro"), word: words[0], theme: configuration.theme)
    }

    func timeline(for configuration: VerbsyWidgetIntent, in context: Context) async -> Timeline<VerbsyEntry> {
        let defaults = UserDefaults(suiteName: appGroup) ?? .standard
        let isPro = defaults.bool(forKey: "widget.isPro")
        let words = loadWords(defaults)
        let theme = isPro ? configuration.theme : .paper
        let interval = isPro ? max(1, configuration.rotation.hours) : 24
        let calendar = Calendar.current
        let now = Date()

        // Pre-build rotating entries covering ~2 days so the word changes on
        // schedule without needing the app to run.
        var entries: [VerbsyEntry] = []
        let count = max(2, (48 / interval) + 1)
        for i in 0..<count {
            let date = calendar.date(byAdding: .hour, value: i * interval, to: now) ?? now
            let bucket = Int(date.timeIntervalSince1970 / 3600) / interval
            let word = words[((bucket % words.count) + words.count) % words.count]
            entries.append(VerbsyEntry(date: date, isPro: isPro, word: word, theme: theme))
        }
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func loadWords(_ defaults: UserDefaults) -> [WidgetWord] {
        if
            let data = defaults.data(forKey: "widget.words"),
            let decoded = try? JSONDecoder().decode([WidgetWord].self, from: data),
            !decoded.isEmpty
        {
            return decoded
        }
        if
            let data = defaults.data(forKey: "widget.todayWord"),
            let decoded = try? JSONDecoder().decode(WidgetWord.self, from: data)
        {
            return [decoded]
        }
        return [.sample]
    }
}

private extension WidgetWord {
    static let sample = WidgetWord(
        slug: "lucid",
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
    var presentation: VerbsyWidgetPresentation = .standard

    var body: some View {
        Group {
            if entry.isPro {
                content
            } else {
                lockedContent
            }
        }
            .foregroundStyle(isAccessoryFamily ? Color.primary : palette.primary)
            .containerBackground(for: .widget) {
                if isAccessoryFamily {
                    Color.clear
                } else {
                    palette.background
                }
            }
            .widgetURL(widgetURL)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemLarge:
            largeView
        case .systemMedium:
            mediumView
        case .accessoryRectangular:
            lockRectangularView
        case .accessoryCircular:
            lockCircularView
        case .accessoryInline:
            lockInlineView
        default:
            smallView
        }
    }

    @ViewBuilder
    private var lockedContent: some View {
        switch family {
        case .accessoryInline:
            Text("Verbsy Pro required")
                .font(.system(size: 13.6, weight: .heavy, design: .default))
                .foregroundStyle(.primary)
                .lineLimit(1)
        case .accessoryCircular:
            VStack(spacing: 2) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.primary)
                Text("Pro")
                    .font(.system(size: 9.5, weight: .black, design: .default))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .accessoryRectangular:
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.primary)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Verbsy Pro")
                        .font(.system(size: 15.5, weight: .black, design: .default))
                        .foregroundStyle(.primary)
                    Text("Open Verbsy to unlock")
                        .font(.system(size: 11.2, weight: .bold, design: .default))
                        .foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        default:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Verbsy")
                        .font(.system(size: 12, weight: .black, design: .default))
                        .foregroundStyle(palette.secondary)
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(palette.accent)
                }

                Spacer(minLength: 0)

                Text("Verbsy Pro required")
                    .font(.system(size: family == .systemLarge ? 32 : 22, weight: .bold, design: .serif))
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)

                Text("Open Verbsy to unlock Home Screen and Lock Screen widgets.")
                    .font(.system(size: family == .systemLarge ? 17 : 13, weight: .semibold, design: .default))
                    .foregroundStyle(palette.secondary)
                    .lineLimit(family == .systemLarge ? 3 : 2)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(contentPadding)
        }
    }

    private var smallView: some View {
        Group {
            switch presentation {
            case .homeMinimal:
                VStack(alignment: .leading, spacing: 6) {
                    Spacer(minLength: 0)
                    wordText(size: 31)
                    metaText(size: 11)
                    Spacer(minLength: 0)
                    Text("Verbsy")
                        .font(.system(size: 11, weight: .black, design: .default))
                        .foregroundStyle(palette.accent)
                }
            case .homeQuote:
                VStack(alignment: .leading, spacing: 8) {
                    compactHeader
                    Spacer(minLength: 0)
                    wordText(size: 23)
                    exampleText(size: 13, lines: 5)
                }
            case .homeDefinition:
                VStack(alignment: .leading, spacing: 7) {
                    compactHeader
                    Spacer(minLength: 0)
                    wordText(size: 25)
                    definitionText(size: 14, lines: 5)
                }
            default:
                VStack(alignment: .leading, spacing: 6) {
                    compactHeader
                    Spacer(minLength: 4)
                    wordText(size: 26)
                    metaText(size: 11)
                    definitionText(size: 13, lines: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(contentPadding)
    }

    private var mediumView: some View {
        Group {
            switch presentation {
            case .homeMinimal:
                HStack(alignment: .center, spacing: 14) {
                    wordText(size: 38)
                        .frame(maxWidth: 142, alignment: .leading)
                    VStack(alignment: .leading, spacing: 7) {
                        metaText(size: 12)
                        definitionText(size: 14, lines: 3)
                    }
                }
            case .homeQuote:
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 7) {
                        compactHeader
                        Spacer(minLength: 0)
                        wordText(size: 31)
                        metaText(size: 12)
                    }
                    .frame(maxWidth: 126, maxHeight: .infinity, alignment: .topLeading)

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Used in context")
                            .font(.system(size: 11, weight: .black, design: .default))
                            .foregroundStyle(palette.accent)
                        exampleText(size: 15, lines: 5)
                    }
                }
            case .homeDefinition:
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 7) {
                        compactHeader
                        Spacer(minLength: 0)
                        wordText(size: 32)
                        metaText(size: 12)
                    }
                    .frame(maxWidth: 128, maxHeight: .infinity, alignment: .topLeading)

                    definitionText(size: 17, lines: 5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            default:
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
                        exampleText(size: 13, lines: 3)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .padding(contentPadding)
    }

    private var largeView: some View {
        Group {
            switch presentation {
            case .homeMinimal:
                VStack(alignment: .leading, spacing: 12) {
                    compactHeader
                    Spacer(minLength: 0)
                    wordText(size: 48)
                    metaText(size: 14)
                    definitionText(size: 20, lines: 4)
                    Spacer(minLength: 0)
                }
            case .homeQuote:
                VStack(alignment: .leading, spacing: 12) {
                    compactHeader
                    Spacer(minLength: 0)
                    wordText(size: 38)
                    metaText(size: 13)
                    Divider().overlay(palette.secondary.opacity(0.28))
                    exampleText(size: 21, lines: 6)
                    Spacer(minLength: 0)
                }
            case .homeDefinition:
                VStack(alignment: .leading, spacing: 12) {
                    compactHeader
                    Spacer(minLength: 0)
                    wordText(size: 40)
                    metaText(size: 13)
                    definitionText(size: 22, lines: 5)
                    Spacer(minLength: 0)
                }
            default:
                VStack(alignment: .leading, spacing: 10) {
                    compactHeader
                    Spacer(minLength: 6)
                    wordText(size: 42)
                    metaText(size: 13)
                    definitionText(size: 19, lines: 4)
                    Spacer(minLength: 4)
                    exampleText(size: 15, lines: 4)
                        .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(contentPadding)
    }

    private var rectangularView: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 5) {
                    Text(entry.word.word)
                        .font(.system(size: 16.5, weight: .bold, design: .serif))
                        .lineLimit(1)
                        .minimumScaleFactor(0.56)
                        .allowsTightening(true)

                    Text(entry.word.partOfSpeech.uppercased())
                        .font(.system(size: 7.8, weight: .black, design: .default))
                        .foregroundStyle(palette.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                if presentation == .lockWord {
                    Text(entry.word.pronunciation)
                        .font(.system(size: 10.4, weight: .bold, design: .default))
                        .foregroundStyle(palette.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                } else if presentation == .lockExample {
                    Text(entry.word.example)
                        .font(.system(size: 10.2, weight: .semibold, design: .default))
                        .foregroundStyle(palette.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .allowsTightening(true)
                } else {
                    Text(entry.word.shortDefinition)
                        .font(.system(size: 10.7, weight: .semibold, design: .default))
                        .foregroundStyle(palette.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .allowsTightening(true)
                }
            }

            if presentation == .standard, entry.theme != .clear {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(palette.accent.opacity(0.72))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var circularView: some View {
        VStack(spacing: 1) {
            Text(compactLockWord)
                .font(.system(size: compactLockWord.count <= 5 ? 17 : 15, weight: .bold, design: .serif))
                .lineLimit(1)
                .minimumScaleFactor(0.52)
                .allowsTightening(true)

            Text(entry.word.partOfSpeech.prefix(4).uppercased())
                .font(.system(size: 7.2, weight: .black, design: .default))
                .foregroundStyle(palette.secondary)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var lockRectangularView: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: presentation == .lockWord ? 2 : 1.5) {
                HStack(alignment: .firstTextBaseline, spacing: 5.5) {
                    Text(entry.word.word)
                        .font(.system(size: presentation == .lockWord ? 19.4 : 18.2, weight: .bold, design: .serif))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.56)
                        .allowsTightening(true)

                    if presentation != .lockWord {
                        Text(entry.word.partOfSpeech.uppercased())
                            .font(.system(size: 8.8, weight: .bold, design: .default))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }

                switch presentation {
                case .lockWord:
                    Text("\(entry.word.pronunciation) · \(entry.word.partOfSpeech)")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                case .lockExample:
                    Text(entry.word.example)
                        .font(.system(size: 11.8, weight: .semibold, design: .serif))
                        .italic()
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .allowsTightening(true)
                default:
                    Text(entry.word.shortDefinition)
                        .font(.system(size: 12.1, weight: .semibold, design: .default))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .allowsTightening(true)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var lockCircularView: some View {
        VStack(spacing: 1) {
            Text(compactLockWord)
                .font(.system(size: compactLockWord.count <= 5 ? 19.6 : 17.2, weight: .bold, design: .serif))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.54)
                .allowsTightening(true)

            Text(entry.word.partOfSpeech.prefix(4).uppercased())
                .font(.system(size: 8, weight: .bold, design: .default))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var lockInlineView: some View {
        let detail = presentation == .lockExample ? entry.word.example : entry.word.shortDefinition
        return Text("\(entry.word.word): \(detail)")
            .font(.system(size: 13.8, weight: .semibold, design: .default))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }

    private var inlineView: some View {
        let detail = presentation == .lockExample ? entry.word.example : entry.word.shortDefinition
        return Text("\(entry.word.word): \(detail)")
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

    private func exampleText(size: CGFloat, lines: Int) -> some View {
        Text("\"\(entry.word.example)\"")
            .font(.system(size: size, weight: .semibold, design: .serif))
            .italic()
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

    private var palette: VerbsyWidgetPalette {
        VerbsyWidgetPalette(theme: entry.theme)
    }

    private var widgetURL: URL? {
        guard entry.isPro else { return URL(string: "verbsy://paywall") }
        guard let slug = entry.word.slug else { return URL(string: "verbsy://today") }
        return URL(string: "verbsy://word/\(slug)")
    }

    private var compactLockWord: String {
        let word = entry.word.word
        if word.count <= 7 { return word }
        return String(word.prefix(6)) + "..."
    }

    private var isLockPresentation: Bool {
        presentation == .lockDefinition || presentation == .lockWord || presentation == .lockExample
    }

    private var isAccessoryFamily: Bool {
        family == .accessoryRectangular || family == .accessoryCircular || family == .accessoryInline
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
        case .gold:
            background = Color(red: 0.953, green: 0.914, blue: 0.831) // #F3E9D4
            primary = Color(red: 0.102, green: 0.098, blue: 0.086)
            secondary = Color(red: 0.420, green: 0.340, blue: 0.230)
            accent = Color(red: 0.745, green: 0.541, blue: 0.239)     // #BE8A3D
        case .library:
            background = Color(red: 0.115, green: 0.150, blue: 0.120)
            primary = Color(red: 0.953, green: 0.945, blue: 0.914)
            secondary = Color(red: 0.720, green: 0.745, blue: 0.675)
            accent = Color(red: 0.498, green: 0.722, blue: 0.612)
        }
    }
}

@main
struct VerbsyWidgetBundle: WidgetBundle {
    var body: some Widget {
        VerbsyDailyWidget()
        VerbsyDefinitionWidget()
        VerbsyExampleWidget()
        VerbsyMinimalWidget()
        VerbsyLockDefinitionWidget()
        VerbsyLockWordWidget()
        VerbsyLockExampleWidget()
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

struct VerbsyDefinitionWidget: Widget {
    let kind = "VerbsyDefinitionWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: VerbsyWidgetIntent.self, provider: VerbsyProvider()) { entry in
            VerbsyWidgetView(entry: entry, presentation: .homeDefinition)
        }
        .configurationDisplayName("Definition Focus")
        .description("A Home Screen widget built around the word's meaning.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

struct VerbsyExampleWidget: Widget {
    let kind = "VerbsyExampleWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: VerbsyWidgetIntent.self, provider: VerbsyProvider()) { entry in
            VerbsyWidgetView(entry: entry, presentation: .homeQuote)
        }
        .configurationDisplayName("Example in Context")
        .description("A Home Screen widget that shows how the word is used.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

struct VerbsyMinimalWidget: Widget {
    let kind = "VerbsyMinimalWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: VerbsyWidgetIntent.self, provider: VerbsyProvider()) { entry in
            VerbsyWidgetView(entry: entry, presentation: .homeMinimal)
        }
        .configurationDisplayName("Minimal Word")
        .description("A quieter Home Screen widget with a clean word-first layout.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

struct VerbsyLockDefinitionWidget: Widget {
    let kind = "VerbsyLockDefinitionWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: VerbsyWidgetIntent.self, provider: VerbsyProvider()) { entry in
            VerbsyWidgetView(entry: entry, presentation: .lockDefinition)
        }
        .configurationDisplayName("Word + Definition")
        .description("A useful Lock Screen word with a short definition.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
        .contentMarginsDisabled()
    }
}

struct VerbsyLockWordWidget: Widget {
    let kind = "VerbsyLockWordWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: VerbsyWidgetIntent.self, provider: VerbsyProvider()) { entry in
            VerbsyWidgetView(entry: entry, presentation: .lockWord)
        }
        .configurationDisplayName("Word Glance")
        .description("A compact Lock Screen word that stays readable at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
        .contentMarginsDisabled()
    }
}

struct VerbsyLockExampleWidget: Widget {
    let kind = "VerbsyLockExampleWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: VerbsyWidgetIntent.self, provider: VerbsyProvider()) { entry in
            VerbsyWidgetView(entry: entry, presentation: .lockExample)
        }
        .configurationDisplayName("Word in Context")
        .description("A Lock Screen widget with a short usage example.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
        .contentMarginsDisabled()
    }
}
