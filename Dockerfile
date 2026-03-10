# Base Image: Use a stable Node.js image
FROM node:20-alpine

# Work Directory: Set the working directory
WORKDIR /app

# Dependency Copy: Copy only package.json first to leverage Docker cache
COPY package.json ./

# Install: Install dependencies
RUN npm install

# Source Copy: Copy the rest of the application files
COPY . .

# Default Command: Run the test suite by default
CMD ["npm", "test"]
