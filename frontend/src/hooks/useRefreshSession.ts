import { useSession } from "next-auth/react";

export default function useRefreshSession() {
  const { update } = useSession();

  async function refreshSession() {
    const response = await fetch("/api/refresh-user", { method: "POST" });

    if (!response.ok) {
      console.error("❌ Failed to refresh session");
      return;
    }

    await update(); // 🔄 Forces NextAuth to re-run the `session` callback
    console.log("✅ Session Updated");
  }

  return refreshSession; // ✅ Return the function for easy use
}
