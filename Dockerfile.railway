# Railway Deployment Dockerfile for Twenty CRM
FROM node:24.5.0-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    musl-dev \
    giflib-dev \
    pixman-dev \
    pangomm-dev \
    libjpeg-turbo-dev \
    freetype-dev

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./
COPY .yarnrc.yml ./
COPY .yarn ./.yarn

# Copy workspace package.json files
COPY packages/twenty-server/package.json ./packages/twenty-server/
COPY packages/twenty-front/package.json ./packages/twenty-front/
COPY packages/twenty-ui/package.json ./packages/twenty-ui/
COPY packages/twenty-utils/package.json ./packages/twenty-utils/

# Install dependencies
RUN yarn install --immutable

# Copy source code
COPY . .

# Build the application
RUN yarn nx build twenty-server
RUN yarn nx build twenty-front

# Production stage
FROM node:24.5.0-alpine AS production

RUN apk add --no-cache \
    cairo \
    jpeg \
    pango \
    musl \
    giflib \
    pixman \
    libjpeg-turbo \
    freetype

WORKDIR /app

# Copy built application from base stage
COPY --from=base /app/dist ./dist
COPY --from=base /app/packages ./packages
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/package.json ./package.json
COPY --from=base /app/yarn.lock ./yarn.lock

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "dist/packages/twenty-server/main.js"]