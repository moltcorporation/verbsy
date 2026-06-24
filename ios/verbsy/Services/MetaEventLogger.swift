import Foundation
import StoreKit

#if canImport(FacebookCore)
import FacebookCore
#endif

@MainActor
enum MetaEventLogger {
    private static let completedOnboardingKey = "verbsy.meta.completedOnboardingLogged"

    static func logCompletedOnboarding() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: completedOnboardingKey) else { return }
        defaults.set(true, forKey: completedOnboardingKey)

#if canImport(FacebookCore)
        AppEvents.shared.logEvent(
            .completedRegistration,
            parameters: [.registrationMethod: "onboarding"]
        )
#endif
    }

    static func logSubscriptionCheckoutStarted(product: Product) {
#if canImport(FacebookCore)
        AppEvents.shared.logEvent(
            .subscribeInitiatedCheckout,
            valueToSum: priceValue(for: product),
            parameters: subscriptionParameters(product: product)
        )
#endif
    }

    static func logSubscriptionCompleted(product: Product, transaction: Transaction) {
#if canImport(FacebookCore)
        let isTrial = hasIntroductoryFreeTrial(product)
        let eventName: AppEvents.Name = isTrial ? .startTrial : .subscribe
        var parameters = subscriptionParameters(product: product, transaction: transaction)
        parameters[.isStartTrial] = isTrial ? "1" : "0"

        AppEvents.shared.logEvent(
            eventName,
            valueToSum: priceValue(for: product),
            parameters: parameters
        )
#endif
    }

    static func logSubscriptionFailed(productId: String) {
#if canImport(FacebookCore)
        AppEvents.shared.logFailedStoreKit2Purchase(productId)
#endif
    }

#if canImport(FacebookCore)
    private static func subscriptionParameters(
        product: Product,
        transaction: Transaction? = nil
    ) -> [AppEvents.ParameterName: Any] {
        var parameters: [AppEvents.ParameterName: Any] = [
            .contentID: product.id,
            .contentType: "subscription",
            .currency: currencyCode(for: product),
            .numItems: 1,
            .productTitle: product.displayName,
            .inAppPurchaseType: "subscription",
            .hasFreeTrial: hasIntroductoryFreeTrial(product) ? "1" : "0"
        ]

        if let transaction {
            let transactionId = String(transaction.id)
            parameters[.orderID] = transactionId
            parameters[.transactionID] = transactionId
            parameters[.originalTransactionID] = String(transaction.originalID)
            parameters[.transactionDate] = ISO8601DateFormatter().string(from: transaction.purchaseDate)
        }

        return parameters
    }

    private static func priceValue(for product: Product) -> Double {
        NSDecimalNumber(decimal: product.price).doubleValue
    }

    private static func currencyCode(for product: Product) -> String {
        product.priceFormatStyle.currencyCode
    }

    private static func hasIntroductoryFreeTrial(_ product: Product) -> Bool {
        product.subscription?.introductoryOffer?.paymentMode == .freeTrial
    }
#endif
}
