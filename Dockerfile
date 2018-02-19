FROM cloudron/base:0.10.0

RUN mkdir -p /app/code
WORKDIR /app/code

ENV PATH /usr/local/node-6.9.5/bin:$PATH

# Some ruby gems require this to be set
ENV LANG=en_US.UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LC_ALL=en_US.UTF-8

# https://pages.github.com/versions/
RUN gem install --no-document bundler github-pages:177

COPY package.json /app/code/
RUN npm install

COPY start.sh index.js pre-receive welcome.html /app/code/

RUN echo "\ncloudron ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

CMD ["/app/code/start.sh"]
