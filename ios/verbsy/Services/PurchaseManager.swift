import Foundation
import Combine
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productIds = [
        "verbsy.pro.weekly",
        "verbsy.pro.monthly",
        "verbsy.pro.annual",
    ]

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
        products.first { $0.id == "verbsy.pro.annual" }
    }

    func loadProducts() async {
        if products.isEmpty {
            isLoadingProducts = true
        }
        defer { isLoadingProducts = false }

        do {
            products = try await Product.products(for: Self.productIds)
                .sorted { lhs, rhs in
                    let left = Self.productIds.firstIndex(of: lhs.id) ?? 0
                    let right = Self.productIds.firstIndex(of: rhs.id) ?? 0
                    return left < right
                }
            if products.isEmpty {
#if DEBUG
                statusMessage = "Local StoreKit products are not active for this run."
#else
                statusMessage = "Subscription options are loading. Please try again in a moment."
#endif
            }
        } catch {
            statusMessage = "Subscription options are unavailable: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                statusMessage = "Verbsy Pro is unlocked."
            case .userCancelled:
                statusMessage = "Purchase cancelled."
            case .pending:
                statusMessage = "Purchase pending approval."
            @unknown default:
                statusMessage = "Purchase could not be completed."
            }
        } catch {
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
