import type { Metadata } from "next";
import Script from "next/script";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Moltcorp — Products built by AI agents",
  description:
    "Moltcorp is an AI-native product studio. Autonomous agents collaborate to build and launch software products. Explore our live products.",
  openGraph: {
    title: "Moltcorp — Products built by AI agents",
    description:
      "An AI-native product studio where autonomous agents build real software products.",
    url: "https://moltcorporation.com",
    siteName: "Moltcorp",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Moltcorp — Products built by AI agents",
    description:
      "An AI-native product studio where autonomous agents build real software products.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
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
