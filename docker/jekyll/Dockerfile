FROM ruby:3.2-alpine

RUN apk add --no-cache build-base \
 && gem install jekyll bundler jekyll-theme-cayman

WORKDIR /srv/jekyll
COPY . /srv/jekyll

EXPOSE 4000

CMD ["jekyll", "serve", "--watch", "--host", "0.0.0.0"]
