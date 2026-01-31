FROM node:18-slim

RUN apt-get update && apt-get install -y git chromium \
    && rm -rf /var/lib/apt/lists/*

# Playwright needs these env vars to use system chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV CHROMIUM_PATH=/usr/bin/chromium

WORKDIR /app

# Install playwright
RUN npm init -y && npm install playwright-chromium

COPY run_test.sh /app/run_test.sh
RUN chmod +x /app/run_test.sh

COPY test_bug.js /app/test_bug.js

ENTRYPOINT ["/app/run_test.sh"]
