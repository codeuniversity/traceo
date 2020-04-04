FROM ruby:2.5.5-slim

RUN apt-get update -qq && apt-get install -y build-essential libxml2-dev libxslt1-dev nodejs libpq-dev postgresql-client

RUN gem install bundler -v 2.0.2

WORKDIR /traceo
COPY Gemfile.lock .
COPY Gemfile .
RUN bundle install

COPY app app
COPY bin bin
COPY config config
COPY db db
COPY lib lib
COPY public public
COPY storage storage
COPY config.ru .
COPY Rakefile .
COPY .ruby-version .

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
