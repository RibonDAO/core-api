FROM ruby:3.1.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client libvips42
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

EXPOSE 8080

ENTRYPOINT ["bin/entry.sh"]
CMD ["bundle","exec","sidekiq","-C","./config/sidekiq.yml"]