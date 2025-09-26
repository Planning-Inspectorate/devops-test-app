# Stage 1/3 - Insatll
FROM alpine:3.4
ARG GIT_SHA
USER root
RUN apk update
# TODO: Remove this once these get fixed:
# - https://github.com/vercel/turborepo/issues/1097
# - https://github.com/vercel/turborepo/issues/1103
RUN apk add git
ENV GIT_SHA=$GIT_SHA

# --------------------------------------------

# Stage 2/3 - Builder
FROM node:22-alpine AS pins-web-builder
ARG GIT_SHA

WORKDIR /usr/src/app

COPY package.json .
COPY package-lock.json .
COPY turbo.json .


COPY app/src ./app/src

RUN npm ci --loglevel notice

ENV GIT_SHA=$GIT_SHA
ENV NODE_ENV=dev
ENV APP_RELEASE=true

RUN npm run build

# --------------------------------

# Stage 3/3 - App run
FROM node:22-alpine
ARG GIT_SHA

WORKDIR /usr/src/app

COPY --from=pins-web-builder /usr/src/app ./

WORKDIR /usr/src/app/app/src

ENV GIT_SHA=$GIT_SHA
ENV NODE_ENV=dev
ENV APP_RELEASE=true

# TODO: Perhaps use `RUN npm ci --production` to shrink the size of the container

EXPOSE 8080

ENTRYPOINT npm run start
