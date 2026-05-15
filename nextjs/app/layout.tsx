import type { Metadata } from "next";
import Script from "next/script";
import "./globals.css";

export const metadata: Metadata = {
  title: "Verbsy — A sharper word for every day",
  description:
    "Verbsy helps you build a sharper vocabulary with one powerful daily word, clean review, reminders, and premium widgets.",
  openGraph: {
    title: "Verbsy — A sharper word for every day",
    description:
      "Build a sharper vocabulary with one powerful daily word.",
    url: "https://verbsy.app",
    siteName: "Verbsy",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Verbsy — A sharper word for every day",
    description:
      "Build a sharper vocabulary with one powerful daily word.",
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
