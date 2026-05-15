export default function PrivacyPage() {
  return (
    <main className="mx-auto max-w-3xl px-6 py-16 text-[#131218]">
      <h1 className="text-4xl font-black">Privacy Policy</h1>
      <p className="mt-4 text-[#66666b]">Effective May 15, 2026</p>
      <div className="mt-10 space-y-6 text-lg leading-8 text-[#3f3f46]">
        <p>
          Verbsy is designed to collect as little personal information as
          possible. The app does not require a Verbsy account for the MVP.
          Onboarding answers, streaks, saved words, review progress, and
          notification preferences are stored locally on your device.
        </p>
        <p>
          The app contacts the Verbsy API to download vocabulary content such as
          the daily word and word library. Standard server logs may include
          technical information such as request time, route, IP address, and
          user agent for security, reliability, and abuse prevention.
        </p>
        <p>
          Purchases are handled by Apple through StoreKit. Verbsy checks your
          active App Store entitlement to unlock Pro features. We do not receive
          your full payment card details from Apple.
        </p>
        <p>
          Verbsy does not sell personal information and does not use third-party
          advertising SDKs. If analytics or crash reporting are added later, this
          policy and the App Store privacy disclosures will be updated before
          release.
        </p>
        <p>
          You can revoke notification permission in iOS Settings. You can delete
          locally stored Verbsy progress by using Reset Progress in the app
          settings or by deleting the app from your device.
        </p>
        <p>
          We retain server logs only as long as reasonably needed for security,
          debugging, and legal compliance. If you contact support, we retain your
          message and email address long enough to respond and maintain support
          records.
        </p>
        <p>
          For privacy questions, contact privacy@verbsy.app.
        </p>
      </div>
    </main>
  );
}
