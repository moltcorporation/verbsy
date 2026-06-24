# Verbsy StoreKit Testing

Use the `verbsy` scheme for subscription testing. It does not attach a local
StoreKit configuration, so device builds use the App Store sandbox catalog from
App Store Connect.

## Required Preflight

In App Store Connect, both products must be approved and available:

- `verbsy.pro.monthly`
- `verbsy.pro.annual`

Validate from this folder:

```bash
asc subscriptions list --group-id 22162598 --output table
asc validate subscriptions --app 6781111581 --output table
```

Expected result: both subscriptions are `APPROVED`, and validation has `0` errors and `0` blocking issues.

## App Store Sandbox Device Test

Use this as the main pre-release test:

1. Select scheme `verbsy`.
2. Run on a physical iPhone.
3. Open the paywall.
4. Confirm both plans load with Apple-provided prices.
5. Start a trial using a sandbox Apple Account when prompted.
6. Confirm Verbsy Pro unlocks immediately.
7. Delete and reinstall the app from Xcode.
8. Open Profile > Verbsy Pro > Restore Purchases.
9. Confirm Verbsy Pro unlocks again.
10. Open Profile > Verbsy Pro > Manage subscription.
11. Confirm Apple's subscription management sheet opens.

Sandbox can ask for Apple Account credentials. That is normal in sandbox and does not mean production users will see that exact prompt.

If you need to sign in before purchasing, use a Sandbox Apple Account created in
App Store Connect > Users and Access > Sandbox. Do not use an existing personal
Apple Account email for a sandbox tester.

The simulator is not enough for final subscription validation because it cannot
prove the real App Store Connect catalog and device purchase sheet are working.

## Final Pre-Release Test

Use TestFlight for the closest production-like purchase flow:

1. Upload the build to TestFlight.
2. Install through the TestFlight app.
3. Sign out of the production Apple Account under Settings > Apple Account > Media & Purchases.
4. Go to Settings > Developer > Sandbox Apple Account and sign in with the sandbox tester.
5. Open the paywall and confirm both plans load.
6. Start a trial.
7. Confirm the Apple purchase sheet says it is a test purchase and no charge will occur.
8. Confirm Verbsy Pro unlocks, restore works after reinstall, and Manage subscription opens.

If Settings does not show Developer, enable Developer Mode on the device and keep
the device connected to Xcode once.
