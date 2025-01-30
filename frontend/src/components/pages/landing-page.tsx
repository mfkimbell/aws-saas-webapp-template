import { useState } from "react";
import Image from "next/image";
import { fetch } from "@/lib/utils"; // Import custom fetch

export default function LandingPage() {
  const [backendResponse, setBackendResponse] = useState<string>("No response received yet.");

  const testBackend = async () => {
    const response = await fetch<{ message: string }>("http://127.0.0.1:8000/health");
    console.log("response: ", response);
    if (response) {
      setBackendResponse(response.message || "Backend is up and running.");
    } else {
      setBackendResponse("Failed to connect to the backend.");
    }
  };

  return (
    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen bg-gradient-to-b from-black via-[#1a1a3f] to-[#000428] text-white p-8 pb-20 gap-16 sm:p-20">
      <main className="flex flex-col gap-8 row-start-2 items-center sm:items-center">
        <div className="flex flex-col items-center text-center gap-4">
          <Image src="/logo.svg" alt="AWS SaaS Webapp Logo" width={180} height={38} priority />
          <h1 className="text-2xl font-bold">AWS SaaS Webapp Template</h1>
        </div>

        {/* Instructions */}
        <ol className="list-inside list-decimal text-sm text-center sm:text-left">
          <li className="mb-2">
            Get started by editing{" "}
            <code className="bg-white/[.1] px-1 py-0.5 rounded font-semibold">
              src/pages/index.tsx
            </code>.
          </li>
          <li>Customize and deploy your SaaS webapp on AWS.</li>
        </ol>

        {/* Test Backend Button */}
        <button
          className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-purple-600 hover:bg-purple-500 text-white text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
          onClick={testBackend}
        >
          Test Backend
        </button>

        {/* Backend Response */}
        <p className="mt-4 text-center text-white text-sm sm:text-base">
          {backendResponse}
        </p>
      </main>
    </div>
  );
}

