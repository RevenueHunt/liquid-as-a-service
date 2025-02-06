FROM ruby:3.4-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENV PORT=4567
EXPOSE 4567

CMD ["bundle", "exec", "ruby", "server.rb", "-o", "0.0.0.0"]