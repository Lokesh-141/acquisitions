# Multi-stage Dockerfile for Node.js app using Neon

# Base image with dependencies installed
FROM node:20-alpine AS base
WORKDIR /app

# Install dependencies separately for better caching
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# Development stage
FROM base AS development
ENV NODE_ENV=development
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Production stage
FROM base AS production
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "src/index.js"]
