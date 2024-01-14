# ================================
# Build image
# ================================
FROM swift:5.9-jammy as build

# Set build type. debug or production
ENV BUILD_TYPE=debug

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y\
    && apt-get -q install -y curl build-essential libssl-dev

RUN echo which nvm

# Install nvm
ENV NVM_DIR /usr/local/nvm
RUN mkdir -p $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Add nvm binaries to path
ENV PATH $NVM_DIR/versions/node/v14.19.0/bin:$PATH

# Install a specific version of node and set it as default
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install 14.19.0 && nvm alias default 14.19.0"

# Verify installation
RUN node --version
RUN npm --version

# Install NodeJS and Node Package Manager for the frontend
# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# RUN source ~/.bashrc
# RUN nvm install latest

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Install webpack
RUN npm install webpack --save-dev

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# --skip-update \
#        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire repo into container
COPY . .


# Build everything, with optimizations
RUN swift build -c $BUILD_TYPE --static-swift-stdlib \
    # Workaround for https://github.com/apple/swift/pull/68669
    # This can be removed as soon as 5.9.1 is released, but is harmless if left in.
    -Xlinker -u -Xlinker _swift_backtrace_isThunkFunction

RUN npm install
RUN npm run build

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c $BUILD_TYPE --show-bin-path)/App" ./

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build -c $BUILD_TYPE --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Copy any resources from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM swift:5.9-jammy-slim

# Make sure all system packages are up to date, and install only essential packages.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      ca-certificates \
      tzdata \
# If your app or its dependencies import FoundationNetworking, also install `libcurl4`.
      # libcurl4 \
# If your app or its dependencies import FoundationXML, also install `libxml2`.
      # libxml2 \
    && rm -r /var/lib/apt/lists/*

# Create a vapor user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=vapor:vapor /staging /app

# Provide configuration needed by the built-in crash reporter and some sensible default behaviors.
ENV SWIFT_ROOT=/usr SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no

# Ensure all further commands run as the vapor user
USER vapor:vapor

# Let Docker bind to port 8080
# EXPOSE 8080

# Start the Vapor service when the image is run, default to listening on 8080 in production environment
# ENTRYPOINT ["./App"]
# CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]

# Heroku struggles with ENTRYPOINT and Array format command so use shell based command. Also make sure it's not quoted ""
CMD ./App serve --env production --hostname 0.0.0.0 --port $PORT
