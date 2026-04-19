import type { Metadata } from "next";
import { Geist } from "next/font/google";
import "./globals.css";
import Link from "next/link";

const geist = Geist({ subsets: ["latin"], variable: "--font-geist" });

export const metadata: Metadata = {
  title: "Pipeline Monitor",
  description: "AI Agent Pipeline Monitor",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${geist.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col bg-[#0f0f0f] text-[#f5f5f5]">
        <nav className="border-b border-[#2a2a2a] px-6 py-4 flex items-center justify-between">
          <Link href="/" className="text-lg font-semibold tracking-tight">
            Pipeline Monitor
          </Link>
          <Link
            href="/pipelines/new"
            className="text-sm bg-violet-600 text-white px-4 py-2 rounded-md hover:bg-violet-500 transition-colors"
          >
            New Pipeline
          </Link>
        </nav>
        <main className="max-w-5xl mx-auto w-full px-6 py-8">{children}</main>
      </body>
    </html>
  );
}
