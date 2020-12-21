FROM alpine:3.12 as buildenv

# Grab iperf2 from Sourceforge and compile
WORKDIR /iperf2
RUN apk --no-cache upgrade \
    && apk add --no-cache tar build-base \
    && wget -O - https://sourceforge.net/projects/iperf2/files/iperf-2.0.14a.tar.gz/download \
    | tar -xz --strip 1 \
    && ./configure \
    && make \
    && make install

FROM alpine:3.12

# Copy relevant compiled files to distribution image
RUN adduser --system iperf2 \
    && apk add --no-cache libgcc libstdc++
COPY --from=buildenv /usr/local/bin/ /usr/local/bin/
COPY --from=buildenv /usr/local/share/man/ /usr/local/share/man/

# Switch to 'iperf2' user
USER iperf2

# Set expose port and entrypoint
EXPOSE 5001
ENTRYPOINT ["iperf"]

LABEL maintainer="matthew@thompsons.id.au"
