import { useSession } from "next-auth/react";
import { useDispatch } from "react-redux";
import { setUser } from "@/userSlice";

export default function useRefreshSession() {
  const { update } = useSession();
  const dispatch = useDispatch();

  async function refreshSession() {
    const response = await fetch("/api/refresh-user", { method: "POST" });

    if (!response.ok) {
      console.error("❌ Failed to refresh session");
      return;
    }

    const updatedUser = await response.json(); // Get new user data

    // 🔄 Update NextAuth session
    await update(); 

    // 🔄 Update Redux state with latest user info
    dispatch(setUser(updatedUser.user));

    console.log("✅ Session & Redux Updated:", updatedUser.user);
  }

  return refreshSession; // ✅ Return the function for easy use
}
