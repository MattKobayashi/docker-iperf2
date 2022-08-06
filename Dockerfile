FROM alpine:3 as buildenv

ENV IPERF2_URL=https://sourceforge.net/projects/iperf2/files/iperf-2.1.7.tar.gz/download \
    IPERF2_SHA1SUM=52f8a46c98776bbd4b9bd0c114fa18cdc0dc403f

# Grab iperf2 from Sourceforge and compile
WORKDIR /iperf2
RUN apk --no-cache upgrade \
    && apk add --no-cache tar build-base \
    && wget -O - ${IPERF2_URL} \
    && IPERF2_FILE="$(ls | grep iperf)" \
    && echo "${IPERF2_SHA1SUM} ${IPERF2_FILE}" | sha1sum -c - \
    && tar -xz --strip 1 ${IPERF2_FILE} \
    && ./configure \
    && make \
    && make install

FROM alpine:3

# Copy relevant compiled files to distribution image
RUN adduser --system iperf2 \
    && apk --no-cache upgrade \
    && apk add --no-cache libgcc libstdc++
COPY --from=buildenv /usr/local/bin/ /usr/local/bin/
COPY --from=buildenv /usr/local/share/man/ /usr/local/share/man/

# Switch to 'iperf2' user
USER iperf2

# Set expose port and entrypoint
EXPOSE 5001
ENTRYPOINT ["iperf"]

LABEL maintainer="matthew@kobayashi.au"
