import Foundation
import WidgetKit

enum WidgetBridge {
    static let appGroup = "group.com.moltcorporation.verbsy"
    private static let fallbackDefaults = UserDefaults.standard

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? fallbackDefaults
    }

    static func write(word: VerbsyWord) {
        guard let data = try? JSONEncoder().encode(word) else { return }
        defaults.set(data, forKey: "widget.todayWord")
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func write(isPro: Bool) {
        defaults.set(isPro, forKey: "widget.isPro")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
