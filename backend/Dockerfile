FROM node:18-alpine

# Install Python 3.11 and ffmpeg (needed by yt-dlp)
RUN apk add --no-cache python3 python3-dev py3-pip ffmpeg curl && \
    ln -sf /usr/bin/python3 /usr/bin/python

# Download the latest yt-dlp official release directly
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp && \
    yt-dlp --version

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the backend code
COPY . .

# Expose the API port
EXPOSE 3000

# Start the Node.js server
CMD ["node", "src/index.js"]
