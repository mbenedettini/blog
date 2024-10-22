# Build the Astro site using Nix
FROM nixos/nix:2.24.7 AS builder

# Configure Nix
RUN echo "extra-experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Create a directory for the project
WORKDIR /build

# Copy the entire project
COPY . .

# Build the project using Nix
RUN nix build --impure --print-build-logs

# Stage 2: Serve the static site
FROM nginx:1.27.2-alpine

# Copy the built assets from the Nix build
COPY --from=builder /build/result/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
