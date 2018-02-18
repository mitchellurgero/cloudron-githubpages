FROM cloudron/base:0.10.0

ENV PATH /usr/local/node-6.9.5/bin:$PATH

RUN mkdir -p /app/code
WORKDIR /app/code

# https://pages.github.com/versions/
RUN gem install --no-document bundler github-pages:177

COPY package.json /app/code/
RUN npm install

COPY start.sh index.js build-pages.sh post-receive welcome.html /app/code/

RUN echo "\ncloudron ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

CMD ["/app/code/start.sh"]
