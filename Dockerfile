FROM cloudron/base:0.10.0

ENV PATH /usr/local/node-6.9.5/bin:$PATH

RUN mkdir -p /app/code
WORKDIR /app/code

RUN gem install --no-document bundler github-pages:177
    # jekyll-coffeescript jekyll-gist jekyll-github-metadata jekyll-paginate \
    # jekyll-relative-links jekyll-optional-front-matter jekyll-readme-index \
    # jekyll-default-layout jekyll-titles-from-headings jekyll-feed jekyll-redirect-from \
    # jekyll-seo-tag jekyll-sitemap jekyll-avatar jemoji jekyll-mentions jekyll-include-cache

COPY package.json /app/code/
RUN npm install

COPY start.sh index.js build-pages.sh post-receive /app/code/

CMD ["/app/code/start.sh"]
