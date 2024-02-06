# Use an official Apache base image
FROM node:5.4

WORKDIR /app

COPY package*.json .
RUN npm install
COPY . .
CMD node index.js