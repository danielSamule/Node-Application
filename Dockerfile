# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

# syntax=docker/dockerfile:1

ARG NODE_VERSION=18.0.0

# Base image shared by all stages
FROM node:${NODE_VERSION}-alpine AS base
WORKDIR /usr/src/app
EXPOSE 3000

# Development stage
FROM base AS dev
ENV NODE_ENV=development

# Install dependencies including devDependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Use non-root user
USER node

# Default command for development (can be overridden in docker-compose)
CMD ["node", "src/index.js"]

# Test stage
FROM base AS test
ENV NODE_ENV=test

# Install dependencies including devDependencies
COPY package*.json ./
RUN npm ci --include=dev

# Copy source code
COPY . .

# Use non-root user
USER node

# Run tests
RUN npm run test

# Production stage
FROM base AS prod
ENV NODE_ENV=production

# Install only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy source code
COPY . .

# Use non-root user
USER node

# Start the app
CMD ["node", "src/index.js"]
