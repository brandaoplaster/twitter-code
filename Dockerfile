FROM ruby:2.5.1-slim

# Install dependencies
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
    build-essential nodejs libpq-dev imagemagick git-all

# Set path
ENV INSTALL_PATH /twitter-code

# Create directory
RUN mkdir -p $INSTALL_PATH

# Set path as the main directory
WORKDIR $INSTALL_PATH

# Copy Gemfile into the container.
COPY Gemfile ./

# Set the path to the gems
ENV BUNDLE_PATH /box

# Copy code into the container
COPY . .