import Image from "next/image";

console.log("API_URL", process.env.API_URL);
console.log("JWT_SECRET", process.env.JWT_SECRET);
console.log("NEXTAUTH_SECRET", process.env.NEXTAUTH_SECRET);

export default function LandingPage() {
  // For thorough troubleshooting, you might also want to log inside the component:
  console.log("[LandingPage Component] API_URL:", process.env.API_URL);
  console.log("[LandingPage Component] JWT_SECRET:", process.env.JWT_SECRET);
  console.log("[LandingPage Component] NEXTAUTH_SECRET:", process.env.NEXTAUTH_SECRET);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gradient-to-b from-gray-900 via-black to-gray-950 text-white p-8 sm:p-16">
      {/* Logo & Title */}
      <div className="flex flex-col items-center text-center mb-10">
        <Image src="/logo.svg" alt="AWS SaaS Webapp Logo" width={200} height={50} priority />
        <h1 className="text-4xl font-extrabold tracking-tight mt-6 sm:text-5xl">
          AWS SaaS Webapp Template
        </h1>
        <p className="text-lg text-gray-300 max-w-2xl mx-auto mt-3">
          Build, deploy, and scale your SaaS application on AWS with ease.
        </p>
      </div>

      {/* Instruction Box */}
      <div className="w-full max-w-3xl bg-gray-800/50 backdrop-blur-md p-8 sm:p-12 rounded-xl shadow-lg border border-gray-700">
        <h2 className="text-2xl font-semibold text-orange-400 mb-4 text-center">
          Get Started in Minutes
        </h2>
        <ol className="list-decimal list-inside text-gray-300 leading-relaxed text-lg space-y-4">
          <li>
            Edit{" "}
            <code className="bg-black/40 px-2 py-1 rounded-md font-mono text-orange-300">
              frontend/src/components/pages/landing-page.tsx
            </code>{" "}
            to customize your landing page
          </li>
          <li>
          Edit{" "}
            <code className="bg-black/40 px-2 py-1 rounded-md font-mono text-orange-300">
              src/app.py
            </code>{" "}
            for API development
          </li>
          <li>
            To deploy with Terraform, push your changes to <code className="bg-black/40 px-2 py-1 rounded-md font-mono text-orange-300">
              /main
            </code>
          </li>
        </ol>
      </div>

      {/* Footer */}
      <footer className="mt-12 text-gray-500 text-sm text-center">
        <p>
          Released under the{" "}
          <a
            href="https://opensource.org/licenses/MIT"
            target="_blank"
            rel="noopener noreferrer"
            className="text-orange-400 hover:underline"
          >
            MIT License
          </a>.
        </p>
        <p>Open-source and community-driven. Contributions welcome!</p>
      </footer>
    </div>
  );
}
