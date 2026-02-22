FROM node:18-alpine

# Install Python 3.11 and ffmpeg (needed by yt-dlp)
RUN apk add --no-cache python3 python3-dev py3-pip ffmpeg && \
    ln -sf /usr/bin/python3 /usr/bin/python

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Force update yt-dlp to the absolute latest version
RUN /app/node_modules/youtube-dl-exec/bin/yt-dlp -U

# Copy the rest of the backend code
COPY . .

# Expose the API port
EXPOSE 3000

# Start the Node.js server
CMD ["node", "src/index.js"]
