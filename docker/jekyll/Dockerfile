FROM ruby:3.2-alpine

# Install deps
RUN apk add --no-cache build-base nginx \
  && gem install jekyll bundler jekyll-theme-cayman

# Set up site
WORKDIR /srv/jekyll
COPY . /srv/jekyll

# Nginx config
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD sh -c "jekyll serve --watch --host 0.0.0.0 --port 4000 & nginx -g 'daemon off;'"
