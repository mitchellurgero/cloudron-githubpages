FROM cloudron/base:1.0.0

RUN mkdir -p /app/code
WORKDIR /app/code

# Some ruby gems require this to be set
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# https://pages.github.com/versions/
RUN gem install --no-document bundler github-pages:192

COPY package.json /app/code/
RUN npm install

COPY start.sh index.js pre-receive welcome.html /app/code/

RUN echo "\ncloudron ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

CMD ["/app/code/start.sh"]
