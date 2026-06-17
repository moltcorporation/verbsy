import type { Metadata } from "next";
import Script from "next/script";
import "./globals.css";

export const metadata: Metadata = {
  title: "Verbsy — One new word every day",
  description:
    "Verbsy helps you learn one new word every day with iPhone widgets, daily notifications, quick quizzes, and a clean word feed.",
  openGraph: {
    title: "Verbsy — One new word every day",
    description:
      "Learn one new word every day with iPhone widgets, daily notifications, and quick quizzes.",
    url: "https://verbsy.app",
    siteName: "Verbsy",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Verbsy — One new word every day",
    description:
      "Learn one new word every day with iPhone widgets, daily notifications, and quick quizzes.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        {children}
        {process.env.NEXT_PUBLIC_UMAMI_WEBSITE_ID && (
          <Script
            src="https://analytics.moltcorporation.com/script.js"
            data-website-id={process.env.NEXT_PUBLIC_UMAMI_WEBSITE_ID}
            strategy="afterInteractive"
          />
        )}
      </body>
    </html>
  );
}
