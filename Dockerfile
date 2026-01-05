# Use the official Bun image as a parent image
FROM oven/bun:1-alpine AS builder

# Set the working directory in the container to /app
WORKDIR /app

# Copy package.json and package-lock.json into the container
COPY package.json package-lock.json ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy the rest of the application code into the container
COPY src/ ./src/
COPY tsconfig.json ./

# Build the project for Docker
RUN bun run build

# Use a minimal bun image as the base image for running
FROM oven/bun:1-alpine AS runner

WORKDIR /app

# Copy compiled code from the builder stage
COPY --from=builder /app/dist ./dist
COPY package.json package-lock.json ./

# Install only production dependencies
RUN bun install --frozen-lockfile --production

# Set environment variable for the Exa API key
ENV EXA_API_KEY=your-api-key-here

# Run the application
ENTRYPOINT ["bun", "run", "dist/index.js"]