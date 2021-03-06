FROM gitlab/dind

MAINTAINER chirgwin

ENV CHROME_DRIVER_VERSION 2.21
ENV NODE_JS_VERSION 6
ENV PHANTOM_JS_VERSION 2.1.1

ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0
ENV NPM_CONFIG_LOGLEVEL error
ENV PATH /usr/local/sonar-runner-2.4/bin:$PATH

COPY config.json /tmp/selenium-config.json
COPY chrome_launcher.sh /tmp/chrome_launcher.sh

RUN \
  wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOM_JS_VERSION-linux-x86_64.tar.bz2 \
  && apt-get update -qqy \
  && apt-get install -y software-properties-common python-software-properties \
  && add-apt-repository ppa:webupd8team/java -y \
  && curl -sL https://deb.nodesource.com/setup_$NODE_JS_VERSION.x | sudo -E bash - \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && echo "deb http://download.rethinkdb.com/apt `lsb_release -cs` main" > /etc/apt/sources.list.d/rethinkdb.list \
  && wget -O- http://download.rethinkdb.com/apt/pubkey.gpg | apt-key add - \
  && apt-get update -qqy \
  && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
  && apt-get install -y \
    build-essential \
    chrpath \
    libssl-dev \
    libxft-dev \
    git \
    nodejs \
    oracle-java8-installer \
    libfreetype6 \
    libfreetype6-dev \
    libfontconfig1 \
    libfontconfig1-dev \
    unzip \
    xvfb \
    google-chrome-stable \
    rethinkdb \
  && mv /tmp/chrome_launcher.sh /opt/google/chrome/google-chrome \
  && chmod +x /opt/google/chrome/google-chrome \
  && tar xvjf phantomjs-$PHANTOM_JS_VERSION-linux-x86_64.tar.bz2 \
  && mv phantomjs-$PHANTOM_JS_VERSION-linux-x86_64 /usr/local/share \
  && ln -sf /usr/local/share/phantomjs-$PHANTOM_JS_VERSION-linux-x86_64/bin/phantomjs /usr/local/bin \
  && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver \
  && mv /tmp/selenium-config.json /opt/selenium/config.json \
  && mkdir -p /usr/src/app \
  && npm i -g gulp grunt bower selenium-standalone@latest \
  && selenium-standalone install \
  && wget http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-2.4.zip \
  && unzip sonar-runner-dist-2.4.zip \
  && mv sonar-runner-2.4 /usr/local/sonar-runner-2.4 \
  && rm phantomjs-$PHANTOM_JS_VERSION-linux-x86_64.tar.bz2 \
    /tmp/chromedriver_linux64.zip \
    /etc/apt/sources.list.d/google-chrome.list \
    sonar-runner-dist-2.4.zip \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

WORKDIR /usr/src/app

# RethinkDB
CMD ["rethinkdb", "--bind", "all"]

CMD ["gulp"]


# Expose ports.
#   - 8080: web UI
#   - 28015: process
#   - 29015: cluster
EXPOSE 8080
EXPOSE 28015
EXPOSE 29015
