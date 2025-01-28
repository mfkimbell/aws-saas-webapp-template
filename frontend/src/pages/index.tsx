import Image from "next/image";
import { Geist, Geist_Mono } from "next/font/google";



export default function Home() {
  return (
    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen bg-gradient-to-b from-black via-[#1a1a3f] to-[#000428] text-white p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col gap-8 row-start-2 items-center sm:items-center">
        {/* Centered Image and Text */}
        <div className="flex flex-col items-center text-center gap-4">
          <Image
            src="/logo.svg"
            alt="AWS SaaS Webapp Logo"
            width={180}
            height={38}
            priority
          />
          <h1 className="text-2xl font-bold">AWS SaaS Webapp Template</h1>
        </div>
        
        {/* Instructions */}
        <ol className="list-inside list-decimal text-sm text-center sm:text-left font-[family-name:var(--font-geist-mono)]">
          <li className="mb-2">
            Get started by editing{" "}
            <code className="bg-white/[.1] px-1 py-0.5 rounded font-semibold">
              src/pages/index.tsx
            </code>
            
          </li>
          <li>Customize and deploy your SaaS webapp on AWS.</li>
        </ol>

        {/* Action Buttons */}
        <div className="flex gap-4 items-center flex-col sm:flex-row">
          <a
            className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-purple-600 hover:bg-purple-500 text-white text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
            href="https://aws.amazon.com"
            target="_blank"
            rel="noopener noreferrer"
          >
            <Image
              src="/rocket.svg"
              alt="Rocket icon"
              width={20}
              height={20}
              className="mr-2" // Add right padding
            />
            Launch to AWS
          </a>
          <a
            className="rounded-full border border-solid border-white/[.2] transition-colors flex items-center justify-center hover:bg-white/[.1] text-white text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 sm:min-w-44"
            href="https://nextjs.org/docs"
            target="_blank"
            rel="noopener noreferrer"
          >
            Read Next.js Docs
          </a>
        </div>
      </main>

      <footer className="row-start-3 flex gap-6 flex-wrap items-center justify-center text-sm text-white">
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://aws.amazon.com/getting-started/"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="/file.svg"
            alt="File icon"
            width={16}
            height={16}
          />
          AWS Getting Started
        </a>
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://nextjs.org/examples"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="/window.svg"
            alt="Window icon"
            width={16}
            height={16}
          />
          Next.js Examples
        </a>
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://aws.amazon.com/saas-factory/"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            aria-hidden
            src="/globe.svg"
            alt="Globe icon"
            width={16}
            height={16}
          />
          Learn SaaS on AWS →
        </a>
      </footer>
    </div>
  );
}
