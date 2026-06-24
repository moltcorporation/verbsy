import Foundation
import Combine
import StoreKit
import UIKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let annualProductId = "verbsy.pro.annual"
    static let monthlyProductId = "verbsy.pro.monthly"
    static let productIds = [annualProductId, monthlyProductId]

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPro = false
    @Published var statusMessage: String?
    @Published var isPurchasing = false
    @Published private(set) var isLoadingProducts = false

    private let localDebugProKey = "verbsy.localDebugPro"
    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var annualProduct: Product? {
        products.first { $0.id == Self.annualProductId }
    }

    func loadProducts(force: Bool = false) async {
        guard !isLoadingProducts else { return }
        guard force || products.isEmpty else { return }

        if products.isEmpty || force {
            isLoadingProducts = true
        }
        defer { isLoadingProducts = false }

        do {
            let fetchedProducts = try await Product.products(for: Self.productIds)
                .sorted { lhs, rhs in
                    let left = Self.productIds.firstIndex(of: lhs.id) ?? 0
                    let right = Self.productIds.firstIndex(of: rhs.id) ?? 0
                    return left < right
                }
            products = fetchedProducts

            if fetchedProducts.isEmpty {
#if DEBUG
                statusMessage = "No StoreKit products were returned. Check the scheme StoreKit configuration or test with TestFlight/App Store sandbox."
#else
                statusMessage = "Subscription options are temporarily unavailable. Please try again."
#endif
            } else if fetchedProducts.count != Self.productIds.count {
                let returnedIds = Set(fetchedProducts.map(\.id))
                let missingIds = Self.productIds.filter { !returnedIds.contains($0) }
                statusMessage = "Some subscription options are unavailable: \(missingIds.joined(separator: ", "))."
            } else {
                statusMessage = nil
            }
        } catch {
            statusMessage = "Subscription options are unavailable: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }

        MetaEventLogger.logSubscriptionCheckoutStarted(product: product)

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                MetaEventLogger.logSubscriptionCompleted(product: product, transaction: transaction)
                if let expirationDate = transaction.expirationDate {
                    await NotificationScheduler.scheduleTrialEndingReminder(expirationDate: expirationDate)
                }
                await transaction.finish()
                await refreshEntitlements()
                statusMessage = "Verbsy Pro is unlocked."
            case .userCancelled:
                statusMessage = "Purchase cancelled."
            case .pending:
                statusMessage = "Purchase pending approval."
            @unknown default:
                MetaEventLogger.logSubscriptionFailed(productId: product.id)
                statusMessage = "Purchase could not be completed."
            }
        } catch {
            MetaEventLogger.logSubscriptionFailed(productId: product.id)
            statusMessage = "Purchase failed. Please try again."
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = isPro ? "Purchases restored." : "No active Verbsy Pro purchase found."
        } catch {
            statusMessage = "Restore failed. Please try again."
        }
    }

    func manageSubscriptions() async {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            statusMessage = "Subscription settings are unavailable right now."
            return
        }

        do {
            try await AppStore.showManageSubscriptions(in: scene)
        } catch {
            statusMessage = "Could not open subscription settings. Please try again."
        }
    }

    func refreshEntitlements() async {
        var hasPro = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if Self.productIds.contains(transaction.productID) {
                hasPro = true
            }
        }
#if DEBUG
        hasPro = hasPro || UserDefaults.standard.bool(forKey: localDebugProKey)
#endif
        isPro = hasPro
        WidgetBridge.write(isPro: hasPro)
    }

#if DEBUG
    func unlockForLocalTesting() {
        UserDefaults.standard.set(true, forKey: localDebugProKey)
        isPro = true
        statusMessage = "Verbsy Pro is unlocked for local testing."
        WidgetBridge.write(isPro: true)
    }

    func resetLocalTestingUnlock() {
        UserDefaults.standard.set(false, forKey: localDebugProKey)
        isPro = false
        statusMessage = "Local testing unlock reset."
        WidgetBridge.write(isPro: false)
    }
#endif

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
