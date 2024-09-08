# Use the official Node.js image as the base image
FROM node:14

# Create and change to the app directory
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image
COPY package*.json ./

# Install dependencies
RUN pnpm install

# Run the build
RUN pnpm run build

# Copy application files to the container image
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Run the application
CMD ["pnpm", "start"]