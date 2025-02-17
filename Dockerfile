FROM node:22.13 AS base

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

FROM base AS build

COPY . .
COPY --from=base /usr/src/app/node_modules ./node_modules

RUN npm run build
RUN npm prune --production

FROM node:22.13-alpine AS deploy

WORKDIR /usr/src/app

RUN npm install -g prisma

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/prisma ./prisma

RUN prisma generate

EXPOSE 3333

CMD ["npm", "run", "start:prod"]