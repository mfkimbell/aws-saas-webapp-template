import { NextApiRequest, NextApiResponse } from "next";
import { getToken } from "next-auth/jwt";
import { getServerSession } from "next-auth";
import { authOptions } from "./auth/[...nextauth]"; // Import NextAuth config
import axios from "axios";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method Not Allowed" });
  }

  // 🔑 Get JWT from NextAuth
  const token = await getToken({ req, secret: process.env.NEXTAUTH_SECRET });

  if (!token?.access_token) {
    return res.status(401).json({ error: "Unauthorized: No token found" });
  }

  try {
    // 🔄 Fetch latest user data from backend
    const response = await axios.get(`${process.env.API_URL}/user/refresh-session`, {
      headers: {
        Authorization: `Bearer ${token.access_token}`,
      },
    });

    if (!response.data) {
      return res.status(500).json({ error: "Failed to fetch user data" });
    }

    // ✅ Get current NextAuth session
    const session = await getServerSession(req, res, authOptions);

    if (session) {
      session.user = {
        id: response.data.id,
        username: response.data.username,
        startingCredits: response.data.credits,
      };
    }

    return res.status(200).json({
      message: "Session updated",
      session, // ✅ Return updated session
    });
  } catch (error) {
    console.error("❌ Error updating session:", error);
    return res.status(500).json({ error: "Internal Server Error" });
  }
}
