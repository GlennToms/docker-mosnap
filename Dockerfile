FROM debian:buster-slim

# Mopidy Requirements
RUN set -ex \
       && apt-get update \
       && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       wget \
       curl \
       gcc \
       dumb-init \
       python3 \
       python3-pip \
       python3-dev \
       python3-crypto \
       python3-gst-1.0 \
       build-essential \
       libgstreamer1.0-0 \
       gstreamer1.0-plugins-good \
       gstreamer1.0-plugins-ugly \
       gstreamer1.0-plugins-bad \
       gstreamer1.0-tools \
       gstreamer1.0-alsa \
       && curl -L https://apt.mopidy.com/mopidy.gpg | apt-key add - \
       && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list

# Install Mopidy
RUN set -ex \
       && apt-get update \
       && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       mopidy \
       && pip3 install \
       Mopidy-Local \
       Mopidy-Mobile \
       Mopidy-MPD \
       Mopidy-YouTube \
       Mopidy-TuneIn \
       Mopidy-MusicBox-Webclient \
       pyopenssl

# Get and install Snapserver
ARG SNAPCASTVERSION=0.19.0
ARG SNAPCASTDEP_SUFFIX=-1
RUN wget 'https://github.com/badaix/snapcast/releases/download/v'$SNAPCASTVERSION'/snapserver_'$SNAPCASTVERSION$SNAPCASTDEP_SUFFIX'_amd64.deb'
RUN dpkg -i --force-all 'snapserver_'$SNAPCASTVERSION$SNAPCASTDEP_SUFFIX'_amd64.deb' \
       && apt-get -f install -y \ 
       && rm -f 'snapserver_'$SNAPCASTVERSION$SNAPCASTDEP_SUFFIX'_amd64.deb'

# Clean-up Apt
RUN set -ex apt-get purge --auto-remove -y \
       curl \
       gcc \
       build-essential \
       python3-dev \
       && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Create config directorys
RUN mkdir /config /music /mopidy

# Allows any user to run mopidy, but runs by default as a randomly generated UID/GID.
ENV HOME=/var/lib/mopidy/
RUN set -ex \
       && usermod -G audio,sudo mopidy \
       && chown mopidy:audio -R $HOME /config /music /mopidy \
       && chmod go+rwx -R $HOME 

# CONFIG FILES
COPY *.conf /config/

# COPY pulse-client.conf /etc/pulse/client.conf

# Runs as mopidy user by default.
# USER mopidy

# COPY entrypoint.sh /entrypoint.sh
COPY launch.sh /config/launch.sh

ENTRYPOINT ["/bin/bash", "/config/launch.sh"]
VOLUME ["/music", "/mopidy", "/config"]
# Expose MDP and Web ports
EXPOSE 6600 6680 5555/udp
# Snapclient
EXPOSE 1704 1705
