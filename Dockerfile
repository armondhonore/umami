FROM mirror.gcr.io/library/node:22-alpine AS builder
WORKDIR /app

# Install build dependencies for native modules
RUN apk add --no-cache libc6-compat python3 make g++ linux-headers

# Use corepack to ensure pnpm version matches environment
RUN npm install -g corepack@latest && corepack enable

# Copy config files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc* ./ 

# FIX: Use --ignore-scripts during install to completely bypass the [ERR_PNPM_IGNORED_BUILDS] 
# issue during the dependency installation phase. We will run the specific required 
# build scripts (prisma generate, etc.) manually later.
RUN pnpm install --no-frozen-lockfile --ignore-scripts

COPY . .
COPY docker/proxy.ts ./src

ARG BASE_PATH
ENV BASE_PATH=$BASE_PATH
ENV NEXT_TELEMETRY_DISABLED=1
ENV DATABASE_URL="postgresql://user:pass@localhost:5432/dummy"

# Ensure standalone output for Next.js
RUN sed -i "s/output.*'export'/output: 'standalone'/g" next.config.* 2>/dev/null || true
RUN sed -i "s/output.*\"export\"/output: 'standalone'/g" next.config.* 2>/dev/null || true

# Manually run the essential build-time scripts that were skipped by --ignore-scripts
# We use npx/pnpm exec to run them directly
RUN npx prisma generate

# Build the application
RUN NODE_OPTIONS="--max-old-space-size=8192" DISABLE_ESLINT_PLUGIN=true NEXT_TELEMETRY_DISABLED=1 TSC_COMPILE_ON_ERROR=true npm run build-docker

FROM mirror.gcr.io/library/node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy standalone build artifacts
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/prisma.config.ts ./prisma.config.ts
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/generated ./generated
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

CMD ["node", "server.js"]