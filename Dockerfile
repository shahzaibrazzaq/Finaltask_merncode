# Set base image to Ubuntu 20
FROM ubuntu:20.04

# Install essential packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg \
    lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Install vim and nginx
RUN apt-get install -y vim nginx

# Install Node.js and npm using NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Add MongoDB GPG key and repository, install MongoDB
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg && \
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org && \
    rm -rf /var/lib/apt/lists/*

# Define working directory
WORKDIR /opt/app

# Clone your project repository
ADD https://github.com/shahzaibrazzaq/iac-final-project-mern-stack.git .

# Install project dependencies for backend
RUN npm install

# Set working directory for frontend and install dependencies
WORKDIR /opt/frontend
RUN npm install

# Build frontend assets
RUN npm run build

# Return to backend working directory
WORKDIR /opt/app

# Expose necessary ports
EXPOSE 27017
EXPOSE 5000

RUN mkdir -p /data/db && chown -R mongodb:mongodb /data/db

CMD ["sh", "-c", "mongod --bind_ip_all --dbpath /data/db --logpath /var/log/mongodb.log --fork && npm run server"]
