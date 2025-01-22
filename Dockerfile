# syntax = docker/dockerfile:1

# Adjust NODE_VERSION as desired
ARG NODE_VERSION=22.12.0
FROM node:${NODE_VERSION}-slim AS base

LABEL fly_launch_runtime="SvelteKit"

# SvelteKit app lives here
WORKDIR /app

# Set production environment
ENV NODE_ENV="production"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential node-gyp pkg-config python-is-python3

# Install node modules
COPY .npmrc package-lock.json package.json ./
RUN npm ci --include=dev

# Copy application code
COPY . .

ENV PUBLIC_BETTER_AUTH_URL="https://beta.bliptext.com"
ENV PUBLIC_WEBSOCKET_URL="wss://ws.bliptext.com"

ARG DISCORD_CLIENT_ID
ARG DISCORD_CLIENT_SECRET
ARG DATABASE_URL
ARG REDIS_URL
ARG REDIS_TOKEN


# Build application
RUN DISCORD_CLIENT_ID=$DISCORD_CLIENT_ID DISCORD_CLIENT_SECRET=$DISCORD_CLIENT_SECRET DATABASE_URL=$DATABASE_URL REDIS_URL=$REDIS_URL REDIS_TOKEN=$REDIS_TOKEN npm run build

# Remove development dependencies
RUN npm prune --omit=dev


# Final stage for app image
FROM base

# Copy built application
COPY --from=build /app/build /app/build
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/package.json /app

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD [ "node", "./build/index.js" ]
