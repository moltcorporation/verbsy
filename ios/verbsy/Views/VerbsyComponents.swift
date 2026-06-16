import SwiftUI
import UIKit

// MARK: - Pressable button style (premium press-scale + haptic on every tap)

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .sensoryFeedback(trigger: configuration.isPressed) { _, pressed in
                pressed ? .impact(weight: .light) : nil
            }
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    /// Standard tappable feel across the app: subtle scale + light haptic.
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
}

// MARK: - Small reusable atoms

/// 11pt uppercase eyebrow label per the brand guide.
struct Eyebrow: View {
    let text: String
    var color: Color = VerbsyDesign.muted

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold, design: .default))
            .tracking(1.6)
            .foregroundStyle(color)
    }
}

struct TopicChip: View {
    let topic: String
    var body: some View {
        Text(topic)
            .font(.system(size: 12, weight: .bold, design: .default))
            .foregroundStyle(VerbsyDesign.sage)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(VerbsyDesign.sageSoft)
            .clipShape(Capsule())
    }
}

struct DifficultyPill: View {
    let word: VerbsyWord
    var body: some View {
        Text(word.difficultyLabel)
            .font(.system(size: 12, weight: .bold, design: .default))
            .foregroundStyle(VerbsyDesign.muted)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(VerbsyDesign.panel)
            .clipShape(Capsule())
    }
}

// MARK: - Settings rows (shared by Profile + sheets)

struct SettingsRowContent: View {
    let symbol: String
    let title: String
    let detail: String
    var showsChevron = true
    var tint: Color = VerbsyDesign.ink

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(VerbsyDesign.panel)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .default))
                    .foregroundStyle(VerbsyDesign.ink)
                Text(detail)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
                    .lineLimit(2)
            }
            Spacer()
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(VerbsyDesign.muted.opacity(0.45))
            }
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Eyebrow(text: title, color: VerbsyDesign.sage)
            VStack(spacing: 0) {
                content()
            }
            .background(VerbsyDesign.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(VerbsyDesign.line))
        }
    }
}

// MARK: - Sharing

/// Branded card rendered to an image when a word is shared.
struct WordShareCard: View {
    let word: VerbsyWord

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                VerbsyLogo(size: 34)
                Text("Verbsy")
                    .font(VerbsyDesign.display(22))
                    .foregroundStyle(VerbsyDesign.ink)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(word.word)
                    .font(VerbsyDesign.display(52))
                    .foregroundStyle(VerbsyDesign.ink)
                Text("\(word.pronunciation) · \(word.partOfSpeech)")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(VerbsyDesign.sage)
            }

            Text(word.shortDefinition)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundStyle(VerbsyDesign.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("“\(word.example)”")
                .font(.system(size: 18, weight: .medium, design: .serif))
                .italic()
                .foregroundStyle(VerbsyDesign.muted)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Text("verbsy.app")
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundStyle(VerbsyDesign.muted)
        }
        .padding(34)
        .frame(width: 540, height: 540, alignment: .topLeading)
        .background(VerbsyDesign.background)
    }
}

/// Tappable share control. The branded image is rendered lazily *only when the
/// user taps* — never during scrolling — so the feed stays smooth.
struct WordShareButton: View {
    let word: VerbsyWord
    var compact = false

    @State private var showShareSheet = false

    private var shareText: String {
        "\(word.word) — \(word.shortDefinition)\n\nA sharper word from Verbsy. https://verbsy.app"
    }

    var body: some View {
        Button {
            Haptics.selection()
            showShareSheet = true
        } label: {
            icon
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: shareItems())
                .presentationDetents([.medium, .large])
        }
    }

    private var icon: some View {
        Image(systemName: "square.and.arrow.up")
            .font(.system(size: compact ? 18 : 22, weight: .semibold))
            .foregroundStyle(VerbsyDesign.ink)
            .frame(width: compact ? 44 : 54, height: compact ? 44 : 54)
            .background(VerbsyDesign.surface)
            .clipShape(Circle())
            .overlay(Circle().stroke(VerbsyDesign.line))
    }

    @MainActor private func shareItems() -> [Any] {
        let renderer = ImageRenderer(content: WordShareCard(word: word))
        renderer.scale = 3
        if let image = renderer.uiImage {
            return [image, shareText]
        }
        return [shareText]
    }
}

/// Bridges UIActivityViewController for sharing image + text.
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

// MARK: - Search field

struct SearchField: View {
    @Binding var text: String
    var placeholder = "Search your words"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(VerbsyDesign.muted)
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium, design: .default))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(VerbsyDesign.muted.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(VerbsyDesign.surface)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(VerbsyDesign.line))
    }
}
