export default function PrivacyPage() {
  return (
    <main className="mx-auto max-w-3xl px-6 py-16 text-[#131218]">
      <h1 className="text-4xl font-black">Privacy Policy</h1>
      <p className="mt-4 text-[#66666b]">Effective May 15, 2026</p>
      <div className="mt-10 space-y-6 text-lg leading-8 text-[#3f3f46]">
        <p>
          Verbsy is designed to keep the MVP simple. Onboarding answers, streaks,
          saved words, review progress, and notification preferences are stored
          locally on your device.
        </p>
        <p>
          The app contacts the Verbsy API to download vocabulary content such as
          the daily word and word library. The API does not require a Verbsy user
          account for the MVP.
        </p>
        <p>
          Purchases are handled by Apple through StoreKit. Verbsy checks your
          active App Store entitlement to unlock Pro features.
        </p>
        <p>
          For privacy questions, contact privacy@verbsy.app.
        </p>
      </div>
    </main>
  );
}
