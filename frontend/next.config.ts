import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  reactStrictMode: true,
  images: {
    domains: ["storage.googleapis.com", "AWS STORAGE BUCKET HERE"],
  },
};

export default nextConfig;
