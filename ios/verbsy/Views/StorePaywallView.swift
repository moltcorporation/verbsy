import StoreKit
import SwiftUI

struct StorePaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let canContinueFree: Bool
    let onContinueFree: () -> Void
    let onCompleted: () -> Void

    @State private var selectedProductId = "verbsy.pro.annual"

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(VerbsyDesign.gold)
                        .padding(16)
                        .background(VerbsyDesign.goldSoft)
                        .clipShape(Circle())

                    Text("Try Verbsy Pro free")
                        .font(VerbsyDesign.display(34))
                        .foregroundStyle(VerbsyDesign.ink)
                        .multilineTextAlignment(.center)

                    Text("Keep a sharper word on your Home Screen and arrive every morning. Free for 3 days.")
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .foregroundStyle(VerbsyDesign.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.top, 20)

                TrialTimeline()

                VStack(spacing: 12) {
                    PaywallBenefit(symbol: "rectangle.on.rectangle.angled", title: "Home & Lock Screen widgets")
                    PaywallBenefit(symbol: "bell.badge.fill", title: "Word-of-the-day notifications")
                    PaywallBenefit(symbol: "infinity", title: "The feed & quizzes are always free")
                }

                planSelector

                Button(action: startPurchase) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundStyle(VerbsyDesign.onSage)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(VerbsyDesign.sage)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isPrimaryButtonDisabled)

                Text(disclosure)
                    .font(.system(size: 12.5, weight: .medium, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

#if DEBUG
                if purchases.products.isEmpty {
                    Button("Reset local Pro unlock") { purchases.resetLocalTestingUnlock() }
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundStyle(VerbsyDesign.muted)
                }
#endif

                if canContinueFree {
                    Button {
                        onContinueFree()
                        dismiss()
                    } label: {
                        Text("Continue with the free version")
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundStyle(VerbsyDesign.muted)
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 10) {
                    if let status = purchases.statusMessage {
                        Text(status)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundStyle(VerbsyDesign.muted)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 16) {
                        Button("Restore") { Task { await purchases.restore() } }
                        Link("Terms", destination: URL(string: "https://verbsy.app/terms")!)
                        Link("Privacy", destination: URL(string: "https://verbsy.app/privacy")!)
                    }
                    .font(.system(size: 13, weight: .bold, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
                }
                .padding(.bottom, 28)
            }
            .padding(.horizontal, VerbsyDesign.pageGutter)
        }
        .background(VerbsyDesign.background.ignoresSafeArea())
        .task { await purchases.loadProducts() }
    }

    // MARK: Plans

    @ViewBuilder
    private var planSelector: some View {
        VStack(spacing: 12) {
            if purchases.products.isEmpty {
#if DEBUG
                PlanRow(title: "Yearly", price: "$29.99 / year", subtitle: "Just $2.50 / month", badge: "Save 75%", isSelected: selectedProductId == "verbsy.pro.annual") { selectedProductId = "verbsy.pro.annual" }
                PlanRow(title: "Monthly", price: "$9.99 / month", subtitle: nil, badge: nil, isSelected: selectedProductId == "verbsy.pro.monthly") { selectedProductId = "verbsy.pro.monthly" }
#else
                ProgressView().tint(VerbsyDesign.ink).frame(maxWidth: .infinity).padding(28)
#endif
            } else {
                ForEach(purchases.products, id: \.id) { product in
                    PlanRow(
                        title: title(for: product),
                        price: price(for: product),
                        subtitle: subtitle(for: product),
                        badge: product.id == "verbsy.pro.annual" ? "Save 75%" : nil,
                        isSelected: selectedProductId == product.id
                    ) {
                        selectedProductId = product.id
                    }
                }
            }
        }
    }

    private func startPurchase() {
        guard let product = purchases.products.first(where: { $0.id == selectedProductId }) else {
#if DEBUG
            purchases.unlockForLocalTesting()
            onCompleted()
            dismiss()
#else
            purchases.statusMessage = "Plans are still loading. Try again in a moment."
#endif
            return
        }
        Task {
            await purchases.purchase(product)
            if purchases.isPro {
                onCompleted()
                dismiss()
            }
        }
    }

    private var primaryButtonTitle: String {
        if purchases.isPurchasing { return "Starting…" }
        return "Start my 3-day free trial"
    }

    private var isPrimaryButtonDisabled: Bool {
        purchases.isPurchasing || (purchases.products.isEmpty && !isDebugBuild)
    }

    private var disclosure: String {
        let price = selectedProductId == "verbsy.pro.monthly" ? "$9.99/month" : "$29.99/year"
        return "3 days free, then \(price). Cancel anytime in Settings, at least 24 hours before renewal. Auto-renews until canceled."
    }

    private var isDebugBuild: Bool {
#if DEBUG
        true
#else
        false
#endif
    }

    private func title(for product: Product) -> String {
        product.id.contains("annual") ? "Yearly" : "Monthly"
    }

    private func price(for product: Product) -> String {
        product.id.contains("annual") ? "\(product.displayPrice) / year" : "\(product.displayPrice) / month"
    }

    private func subtitle(for product: Product) -> String? {
        product.id.contains("annual") ? "Best value" : nil
    }
}

private struct TrialTimeline: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            row(symbol: "lock.open.fill", title: "Today", detail: "Unlock widgets and daily words instantly.", showsLine: true)
            row(symbol: "bell.fill", title: "Day 2", detail: "We’ll remind you before your trial ends.", showsLine: true)
            row(symbol: "checkmark.seal.fill", title: "Day 3", detail: "Trial ends. Cancel anytime before this.", showsLine: false)
        }
        .padding(20)
        .background(VerbsyDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous).stroke(VerbsyDesign.line))
    }

    private func row(symbol: String, title: String, detail: String, showsLine: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(VerbsyDesign.onSage)
                    .frame(width: 34, height: 34)
                    .background(VerbsyDesign.sage)
                    .clipShape(Circle())
                if showsLine {
                    Rectangle().fill(VerbsyDesign.line).frame(width: 2, height: 26)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundStyle(VerbsyDesign.ink)
                Text(detail)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundStyle(VerbsyDesign.muted)
            }
            .padding(.bottom, showsLine ? 12 : 0)
            Spacer()
        }
    }
}

private struct PaywallBenefit: View {
    let symbol: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(VerbsyDesign.sage)
                .frame(width: 44, height: 44)
                .background(VerbsyDesign.sageSoft)
                .clipShape(Circle())
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundStyle(VerbsyDesign.ink)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(VerbsyDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusTile, style: .continuous).stroke(VerbsyDesign.line))
    }
}

private struct PlanRow: View {
    let title: String
    let price: String
    let subtitle: String?
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundStyle(VerbsyDesign.ink)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold, design: .default))
                                .foregroundStyle(VerbsyDesign.onSage)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(VerbsyDesign.gold)
                                .clipShape(Capsule())
                        }
                    }
                    Text(price)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundStyle(VerbsyDesign.muted)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .semibold, design: .default))
                            .foregroundStyle(VerbsyDesign.sage)
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(isSelected ? VerbsyDesign.sage : VerbsyDesign.muted.opacity(0.4))
            }
            .padding(18)
            .background(VerbsyDesign.surface)
            .clipShape(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: VerbsyDesign.radiusCard, style: .continuous).stroke(isSelected ? VerbsyDesign.sage : VerbsyDesign.line, lineWidth: isSelected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}
