import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Proactive Guard",
  description: "AI-powered safety command center",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
