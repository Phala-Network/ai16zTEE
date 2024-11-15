# Use Node 22 instead of 20
FROM node:22.11.0

# Install node-gyp and node-waf
RUN npm install -g node-gyp node-waf pnpm

# Install system dependencies and Playwright dependencies in one layer
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    git \
    curl \
    sqlite3 \
    # Playwright dependencies
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
#RUN corepack enable pnpm

# Set working directory
WORKDIR /app

# Copy package files first
COPY . .

# Install dependencies
#RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile --include=optional sharp
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install -w
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --include=optional sharp -w

# Build all packages
RUN pnpm build
COPY . .

# Expose ports
EXPOSE 3000

ENV PORT=3000

# Switch to non-root user
USER node

# Start the application
CMD ["pnpm", "start"]