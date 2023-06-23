FROM ubuntu:20.04

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl \
    && ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Install all apt dependencies
RUN apt-get update \
    && apt-get install -y \
        software-properties-common \
    && apt-key adv --keyserver "hkp://keyserver.ubuntu.com:80" --recv 'E5267A6C' \
    #&& LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
    #&& add-apt-repository ppa:certbot/certbot \
    && apt-get update \
    && apt-get install -y \
        python-setuptools \
        unzip \
        gettext \
        apache2 \
        php7.4 \
        php-gd \
        libapache2-mod-php7.4 \
        postfix \
        wget \
        php7.4-pgsql \
        vim \
        curl \
        libcurl4 \
        libcurl4-openssl-dev \
        php7.4-curl \
        php7.4-xml \
        php7.4-xmlrpc \
        php7.4-intl \
        php7.4-mysql \
        php7.4-zip \
        php7.4-mbstring \
        php7.4-soap \
	imagemagick \
        certbot \
        python3-certbot-apache \
	supervisor \ 
	sudo \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/www/html

# ImageMagick policy for editing PS / PDF
RUN  sed -i -r 's/="none"( pattern="PS")/="read"\1/' /etc/ImageMagick-6/policy.xml

COPY crontab /crontab
RUN apt-get update \
    && apt-get install -y cron \
    && crontab -u www-data /crontab

# Install texlive & AMC dependencies 
RUN apt-get update \
    && apt-get install -y \
    texlive-xetex \
    lmodern \
    texlive-fonts-recommended \
    poppler-utils \
    imagemagick \
    texlive-latex-extra \
    texlive-science \
    texlive-fonts-extra \
    && rm -rf /var/lib/apt/lists/*

# Install apache2
COPY ./start.sh /start.sh
COPY ./foreground.sh /etc/apache2/foreground.sh
RUN chmod 755 /start.sh /etc/apache2/foreground.sh
COPY ./supervisord.conf /etc/supervisord.conf

COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load \
    && ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load \
    && ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf \
    && ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load \
    && ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

# Install Cerbot
RUN echo "certbot --non-interactive --agree-tos --email \$CERT_EMAIL --apache --domains \$VIRTUAL_HOST" > /certbot-setup.sh \
    && chmod 755 /certbot-setup.sh

# Install moodle 4.1.4 https://download.moodle.org/releases/supported/
RUN cd /var/www \
    && curl -L 'https://download.moodle.org/download.php/direct/stable401/moodle-latest-401.tgz' -o moodle.tar.gz \
    && tar -zxf moodle.tar.gz \
    && rm moodle.tar.gz \
    && mv /var/www/moodle* /var/www/html \
    && chown -R www-data:www-data /var/www/html/

COPY ./config-dist.php /var/www/html/config-dist.php

### Plugin installation: https://docs.moodle.org/402/en/Installing_plugins#Plugins_for_University_teaching ###

# Plugin theme learnr 4.2.r7 (formly fordson) https://moodle.org/plugins/theme_learnr
RUN curl -L https://moodle.org/plugins/download.php/29140/theme_learnr_moodle42_2023050507.zip -o /learnr.zip \
    && cp /learner.zip /var/www/html/theme/ \
    && cd /var/www/html/theme \
    && unzip learnr.zip \
    && rm learnr.zip

# Plugin moodle-auth-saml2 2022111701 https://moodle.org/plugins/auth_saml2
RUN cd /var/www/html/auth \
    && wget https://moodle.org/plugins/download.php/28869/auth_saml2_moodle41_2022111701.zip -O auth_saml2.zip \
    && unzip auth_saml2.zip \
    ##&& mv moodle-auth_saml2* saml2 \
    && rm auth_saml2.zip

# Plugin mod_questionnaire 4.0.1 https://moodle.org/plugins/mod_questionnaire
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/29228/mod_questionnaire_moodle42_2022092202.zip -o questionnaire.zip \
    && unzip questionnaire.zip \
    && chown -R www-data:www-data questionnaire \
    && rm questionnaire.zip

# Install H5P - mod_hvp version 1.23.2 from https://moodle.org/plugins/mod_hvp
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/29419/mod_hvp_moodle42_2022092202.zip -o mod_hvp.zip \
    && unzip mod_hvp.zip \
    && chown -R www-data:www-data hvp \
    && rm mod_hvp.zip

# Copy file to auto install H5P libraries
######### TESTS: this 
#COPY ./autoinstallhvplibs.php /var/www/html/mod/hvp/autoinstallhvplibs.php 
#RUN cd /var/www/html/mod/hvp \
#    && chown www-data:www-data autoinstallhvplibs.php \
#    && chmod 775 autoinstallhvplibs.php

# Install VPL - mod/vpl version 1.6 from https://moodle.org/plugins/mod_vpl
#RUN cd /var/www/html/mod \
#    #&& curl -L https://github.com/jcrodriguez-dis/moodle-mod_vpl/archive/bc98f46fcac852d1d237a5ed700fe4030b385aa9.zip -o mod_vpl.zip \
#    && curl -L https://github.com/jcrodriguez-dis/moodle-mod_vpl/archive/V3.3.7.zip -o mod_vpl.zip \
#    && unzip mod_vpl.zip \
#    #&& mv moodle-mod_vpl-bc98f46fcac852d1d237a5ed700fe4030b385aa9 vpl \
#    && mv moodle-mod_vpl-3.3.7 vpl \
#    && chown -R www-data:www-data vpl \
#    && rm mod_vpl.zip

# Install EJSapp pack - mod/ejsapp version 4.0 from https://moodle.org/plugins/mod_ejsapp
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/20650/mod_ejsapp_moodle38_2019112102.zip  -o mod_ejsapp.zip \
    && unzip mod_ejsapp.zip \
    && chown -R www-data:www-data ejsapp \
    && rm mod_ejsapp.zip

# Install EJSapp repository - repository/osp version 1.3 from https://moodle.org/plugins/repository_osp
RUN cd /var/www/html/repository \
    && curl -L https://moodle.org/plugins/download.php/17745/repository_osp_moodle36_2017051500.zip -o repository_osp.zip \
    && unzip repository_osp.zip \
    && rm repository_osp.zip

# Install EJSapp remote lab manager - block/remlab_manager version 1.2 from https://moodle.org/plugins/block_remlab_manager
RUN cd /var/www/html/blocks \
    && curl -L https://moodle.org/plugins/download.php/20651/block_remlab_manager_moodle38_2019111907.zip -o block_remlab_manager.zip \
    && unzip block_remlab_manager.zip \
    && rm block_remlab_manager.zip

# Install Moosh 1.11 https://moodle.org/plugins/view.php?id=522
RUN wget https://moodle.org/plugins/download.php/29225/moosh_moodle42_2023051601.zip -O /moosh.zip \
    && unzip /moosh.zip \
    && rm /moosh.zip \
    && chmod a+x /moosh/moosh.php

COPY php.ini /etc/php/7.4/apache2/php.ini
COPY config/ /config
COPY configure.sh /configure.sh
RUN chmod a+x /configure.sh

# Install Plugin XP (LevelUP!) 3.14.1 https://moodle.org/plugins/block_xp
RUN cd /var/www/html/blocks \
    && curl -L https://moodle.org/plugins/download.php/29335/block_xp_moodle42_2023042403.zip -o block_xp.zip \
    && unzip block_xp.zip \
    && rm block_xp.zip \
    && chown -R www-data:www-data xp

# Install Plugin emailtest 2.0.2 https://moodle.org/plugins/local_mailtest
RUN cd /var/www/html/local \
    && curl -L https://moodle.org/plugins/download.php/29145/local_mailtest_moodle42_2023050600.zip -o mailtest.zip \
    && unzip mailtest.zip \
    && rm mailtest.zip \
    && chown -R www-data:www-data mailtest

# Install Plugin Scheduler 4.0.0 https://moodle.org/plugins/mod_scheduler
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/29293/mod_scheduler_moodle42_2023052300.zip -o sched.zip \
    && unzip sched.zip \
    && rm sched.zip \
    && chown -R www-data:www-data scheduler

# Install Plugin jazzquiz 1.2.0 https://moodle.org/plugins/mod_jazzquiz
RUN cd /var/www/html/mod \
    && curl -L  https://moodle.org/plugins/download.php/28844/mod_jazzquiz_moodle41_2023033100.zip -o jazz.zip \
    && unzip jazz.zip \
    && rm jazz.zip \
    && chown -R www-data:www-data jazzquiz

# Install Plugin CustomSQL 4.2 https://moodle.org/plugins/report_customsql
RUN cd /var/www/html/report \
    && curl -L https://moodle.org/plugins/download.php/26177/report_customsql_moodle40_2022031800.zip -o customsql.zip \
    && unzip customsql.zip \
    && rm customsql.zip \
    && chown -R www-data:www-data customsql

# Install Plugin CourseSize https://moodle.org/plugins/report_coursesize
RUN cd /var/www/html/report \
    && curl -L https://moodle.org/plugins/download.php/28315/report_coursesize_moodle41_2023010900.zip -o coursesize.zip \
    && unzip coursesize.zip \
    && rm coursesize.zip \
    && chown -R www-data:www-data coursesize


RUN mkdir -p /usr/local/share/texmf/tex/latex/atslmc
COPY atslmc.sty /usr/local/share/texmf/tex/latex/atslmc/atslmc.sty
RUN mktexlsr

EXPOSE 80 443

CMD ["/bin/bash", "/start.sh"]
