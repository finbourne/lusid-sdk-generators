FROM node:alpine

WORKDIR /usr/src/

COPY package.json package.json

RUN npm install

# The environment variables required to run the tests
ENV FBN_TOKEN_URL ${FBN_TOKEN_URL}
ENV FBN_USERNAME ${FBN_USERNAME}
ENV FBN_PASSWORD ${FBN_PASSWORD}
ENV FBN_CLIENT_ID ${FBN_CLIENT_ID}
ENV FBN_CLIENT_SECRET ${FBN_CLIENT_SECRET}
ENV FBN_LUSID_API_URL ${FBN_LUSID_API_URL}

CMD ["npm", "test"]