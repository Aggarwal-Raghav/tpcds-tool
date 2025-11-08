FROM debian:latest

# Define the proxy URL. Using ARG makes it overridable.
# ARG HTTP_PROXY_URL="http://proxy.your-company.com:8080"
# ARG HTTPS_PROXY_URL="http://proxy.your-company.com:8080"

# Create a proxy config file for apt
# RUN echo "Acquire::http::Proxy \"${HTTP_PROXY_URL}\";" > /etc/apt/apt.conf.d/99proxy && \
    # echo "Acquire::https::Proxy \"${HTTPS_PROXY_URL}\";" >> /etc/apt/apt.conf.d/99proxy

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    yacc \
    flex \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy official toolkit source code

COPY tpc-ds/ /opt/tpcds
WORKDIR /opt/tpcds/tools

# Build the toolkit
RUN make LINUX_CFLAGS="-g -Wall -std=gnu89" LDFLAGS="-z muldefs"
RUN rm -rf /etc/apt/apt.conf.d/99proxy

# Add to PATH for convenience
ENV PATH="/opt/tpcds/tools:${PATH}"
