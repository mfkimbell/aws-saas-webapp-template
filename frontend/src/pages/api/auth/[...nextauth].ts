import NextAuth, { NextAuthOptions, User as NextAuthUser } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import jwt from "jsonwebtoken";

interface ExtendedUser extends NextAuthUser {
  id: string;
  username: string;
}

console.log("[LandingPage Component] API_URL:", process.env.API_URL);
console.log("[LandingPage Component] JWT_SECRET:", process.env.JWT_SECRET);
console.log("[LandingPage Component] NEXTAUTH_SECRET:", process.env.NEXTAUTH_SECRET);

export const authOptions: NextAuthOptions = {
  secret: process.env.NEXTAUTH_SECRET || "",
  session: {
    strategy: "jwt",
  },
  pages: {
    signOut: "/auth/signout",
  },
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        username: { label: "Username", type: "text" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!process.env.API_URL) {
          console.error("❌ API_URL is not defined in environment variables");
          throw new Error("API_URL is missing");
        }

        const response = await fetch(`${process.env.API_URL}/login`, {
          method: "POST",
          headers: { "Content-Type": "application/x-www-form-urlencoded" },
          body: new URLSearchParams({
            username: credentials?.username || "",
            password: credentials?.password || "",
          }).toString(),
          credentials: "include", // Ensure cookies are included
        });

        console.log("📥 Backend Response Status:", response.status);
        console.log("📥 Backend Response Headers:", response.headers);
        

        if (response.status === 401) {
          console.error("❌ Invalid credentials");
          throw new Error("Invalid credentials");
        }

        let responseData;
        try {
          responseData = await response.json();
          console.log("📦 Response Data:", responseData);
        } catch (err) {
          console.error("❌ Failed to parse JSON from response:", err);
        }
        let access_token = responseData?.access_token;

        // ✅ If access_token is not in response body, check the Set-Cookie header
        if (!access_token) {
          console.warn("⚠️ Token not found in response body, checking Set-Cookie header...");
          const setCookieHeader = response.headers.get("Set-Cookie");
          if (setCookieHeader) {
            access_token = setCookieHeader.split(";")[0].split("=")[1];
            console.log("🔑 Extracted Token from Set-Cookie:", access_token);
          }
        }

        try {
          const decoded = jwt.verify(
            access_token,
            process.env.JWT_SECRET || ""
          ) as unknown as ExtendedUser;

          return {
            access_token,
            id: decoded.id,
            username: decoded.username,
            startingCredits: decoded.credits,
          };
        } catch (error) {
          console.error("❌ JWT verification failed:", error);
          throw new Error("Invalid token");
        }
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.access_token = user.access_token;
        token.id = user.id;
        token.username = user.username;
        token.startingCredits = user.startingCredits;
      }
      return token;
    },

    async session({ session, token }) {
      if (token.access_token) {
        session.user = {
          id: token.id as string,
          username: token.username as string,
          startingCredits: token.startingCredits as number,
        };
      }
      return session;
    },
  },
};

export default NextAuth(authOptions);
