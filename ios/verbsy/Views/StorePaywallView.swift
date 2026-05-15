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
            VStack(spacing: 22) {
                VStack(spacing: 12) {
                    Text("Unlock Verbsy Pro")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(VerbsyDesign.ink)
                        .multilineTextAlignment(.center)

                    Text("Daily widgets, review, topics, saved words, and the full vocabulary archive.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(VerbsyDesign.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.top, 24)

                VStack(spacing: 12) {
                    PaywallBenefit(symbol: "rectangle.on.rectangle", title: "Home and Lock Screen widgets")
                    PaywallBenefit(symbol: "checkmark.seal.fill", title: "Review words until they stick")
                    PaywallBenefit(symbol: "books.vertical.fill", title: "Full topic-based word library")
                    PaywallBenefit(symbol: "bell.badge.fill", title: "Daily ritual with reminders")
                }

                VStack(spacing: 12) {
#if DEBUG
                    if purchases.products.isEmpty {
                        StaticPlanRow(title: "Annual", price: "$29.99 / year", badge: "Best value", isSelected: selectedProductId == "verbsy.pro.annual") {
                            selectedProductId = "verbsy.pro.annual"
                        }
                        StaticPlanRow(title: "Monthly", price: "$7.99 / month", badge: nil, isSelected: selectedProductId == "verbsy.pro.monthly") {
                            selectedProductId = "verbsy.pro.monthly"
                        }
                        StaticPlanRow(title: "Weekly", price: "$1.99 / week", badge: nil, isSelected: selectedProductId == "verbsy.pro.weekly") {
                            selectedProductId = "verbsy.pro.weekly"
                        }
                    } else {
                        ForEach(purchases.products, id: \.id) { product in
                            StaticPlanRow(
                                title: title(for: product),
                                price: price(for: product),
                                badge: product.id == "verbsy.pro.annual" ? "Best value" : nil,
                                isSelected: selectedProductId == product.id
                            ) {
                                selectedProductId = product.id
                            }
                        }
                    }
#else
                    if purchases.products.isEmpty {
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(VerbsyDesign.ink)
                            Text("Loading subscription options...")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(VerbsyDesign.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(28)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    } else {
                        ForEach(purchases.products, id: \.id) { product in
                            StaticPlanRow(
                                title: title(for: product),
                                price: price(for: product),
                                badge: product.id == "verbsy.pro.annual" ? "Best value" : nil,
                                isSelected: selectedProductId == product.id
                            ) {
                                selectedProductId = product.id
                            }
                        }
                    }
#endif
                }

                Button {
                    guard let product = purchases.products.first(where: { $0.id == selectedProductId }) else {
#if DEBUG
                        purchases.unlockForLocalTesting()
                        onCompleted()
                        dismiss()
#else
                        purchases.statusMessage = "Subscriptions are still loading. Try again in a moment."
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
                } label: {
                    Text(primaryButtonTitle)
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 66)
                        .background(VerbsyDesign.ink)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isPrimaryButtonDisabled)

#if DEBUG
                if purchases.products.isEmpty {
                    Text("Debug fallback: Xcode is not running with the local StoreKit configuration yet. This button will unlock Pro locally so you can test the paid experience.")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(VerbsyDesign.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Button {
                        purchases.resetLocalTestingUnlock()
                    } label: {
                        Text("Reset local Pro unlock")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(VerbsyDesign.muted)
                    }
                    .buttonStyle(.plain)
                }
#endif

                if canContinueFree {
                    Button {
                        onContinueFree()
                        dismiss()
                    } label: {
                        Text("Continue with free daily word")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(VerbsyDesign.muted)
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 10) {
                    if let status = purchases.statusMessage {
                        Text(status)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(VerbsyDesign.muted)
                            .multilineTextAlignment(.center)
                    }

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(VerbsyDesign.ink)

                    Text("Subscriptions auto-renew unless canceled at least 24 hours before renewal. Manage or cancel in App Store account settings.")
                        .font(.system(size: 12.5, weight: .medium, design: .rounded))
                        .foregroundStyle(VerbsyDesign.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    HStack(spacing: 8) {
                        Link("Terms", destination: URL(string: "https://verbsy.app/terms")!)
                        Text("·")
                        Link("Privacy", destination: URL(string: "https://verbsy.app/privacy")!)
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(VerbsyDesign.muted)
                }
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 28)
        }
        .background(VerbsyDesign.background.ignoresSafeArea())
        .task { await purchases.loadProducts() }
    }

    private var selectedProduct: Product? {
        purchases.products.first { $0.id == selectedProductId }
    }

    private var primaryButtonTitle: String {
        if purchases.isPurchasing { return "Starting..." }
#if DEBUG
        if purchases.products.isEmpty { return "Continue" }
#else
        if purchases.products.isEmpty { return "Loading..." }
#endif
        return "Subscribe to \(title(for: selectedProduct))"
    }

    private var isPrimaryButtonDisabled: Bool {
        purchases.isPurchasing || (purchases.products.isEmpty && !isDebugBuild)
    }

    private var isDebugBuild: Bool {
#if DEBUG
        true
#else
        false
#endif
    }

    private func title(for product: Product) -> String {
        if product.id.contains("annual") { return "Annual" }
        if product.id.contains("monthly") { return "Monthly" }
        return "Weekly"
    }

    private func title(for product: Product?) -> String {
        guard let product else { return "Pro" }
        return title(for: product)
    }

    private func price(for product: Product) -> String {
        if product.id.contains("annual") { return "\(product.displayPrice) / year" }
        if product.id.contains("monthly") { return "\(product.displayPrice) / month" }
        return "\(product.displayPrice) / week"
    }
}

private struct PaywallBenefit: View {
    let symbol: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(VerbsyDesign.ink)
                .frame(width: 46, height: 46)
                .background(VerbsyDesign.panel)
                .clipShape(Circle())
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Spacer()
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct StaticPlanRow: View {
    let title: String
    let price: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(title)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                        if let badge {
                            Text(badge)
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(VerbsyDesign.sage)
                                .clipShape(Capsule())
                        }
                    }
                    Text(price)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(VerbsyDesign.muted)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(isSelected ? VerbsyDesign.ink : VerbsyDesign.muted.opacity(0.45))
            }
            .padding(18)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(isSelected ? VerbsyDesign.ink : VerbsyDesign.line, lineWidth: isSelected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}
