FROM ubuntu:latest

WORKDIR /opt
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
	          git \
            apache2 \
            curl \
            libapache2-mod-php5 \
            libmysqlclient18 \
            mercurial \
            mysql-client \
            mysql-server \
            php-apc \
            php5 \
            php5-apcu \
            php5-cli \
            php5-curl \
            php5-gd \
            php5-json \
            php5-ldap \
            php5-mysql \
            python-pygments \
            sendmail \
            subversion \
            git-core \
            tar

RUN git clone https://github.com/phacility/libphutil.git
RUN git clone https://github.com/phacility/arcanist.git
RUN git clone https://github.com/phacility/phabricator.git

# Setup apache
RUN     a2enmod rewrite
ADD     build/http.conf /etc/apache2/sites-available/phabricator.conf
RUN     ln -s /etc/apache2/sites-available/phabricator.conf \
            /etc/apache2/sites-enabled/phabricator.conf && \
        rm -f /etc/apache2/sites-enabled/000-default.conf
RUN     service apache2 restart

# Setup phabricator
RUN     mkdir -p /opt/phabricator/conf/local /var/repo
ADD     build/local.json /opt/phabricator/conf/local/local.json
RUN     sed -i -e 's/post_max_size = 8M/post_max_size = 32M/' /etc/php5/apache2/php.ini

# Setup database
RUN     mkdir -p /opt/mysql
RUN     sed -i -e "s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/"  /etc/mysql/my.cnf
ADD     build/mysql.cnf /etc/mysql/conf.d/my-phabricator.cnf
ADD     build/setup_mysql.sh /opt/mysql/setup_mysql.sh
RUN     chmod a+x /opt/mysql/setup_mysql.sh
RUN     bash /opt/mysql/setup_mysql.sh

# Deploy the chinese translation package
RUN      cd /opt/
RUN      git clone https://github.com/qinchao/phabricator-zh_CN.git
RUN      cp /opt/phabricator-zh_CN/* /opt/phabricator/src/extensions/

ADD      build/setup_phabricator.sh /opt/mysql/setup_phabricator.sh
RUN      chmod a+x /opt/mysql/setup_phabricator.sh
RUN      bash /opt/mysql/setup_phabricator.sh

EXPOSE  80
CMD     bash -c "service mysql start;source /etc/apache2/envvars; /usr/sbin/apache2 -DFOREGROUND"

