# Stage 1: Build the Next.js app
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock)
COPY package*.json ./

# Install dependencies
RUN npm install --frozen-lockfile

# Copy the rest of the application files
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Set up the production environment
FROM node:18-alpine

WORKDIR /app

# Install serve globally to serve the app (for static exports)
RUN npm install -g serve

# Copy only the necessary files from the builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Set environment variables if needed
# ENV NODE_ENV=production

# Expose the port
EXPOSE 3000

# Start the Next.js application
CMD ["npm", "start"]
