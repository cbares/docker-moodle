FROM ubuntu:24.04

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl \
    && ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND=noninteractive

# Install all apt dependencies
RUN apt-get update \
    && apt-get install -y \
        software-properties-common \
    && apt-key adv --keyserver "hkp://keyserver.ubuntu.com:80" --recv 'E5267A6C' \
    && apt-get install -y \
        python3-setuptools \
        unzip \
        gettext \
        apache2 \
        php8.3 \
        php-gd \
        libapache2-mod-php8.3 \
        postfix \
        wget \
        php8.3-pgsql \
        vim \
        curl \
        libcurl4 \
        libcurl4-openssl-dev \
        libsodium23 \
        php8.3-curl \
        php8.3-xml \
        php8.3-xmlrpc \
        php8.3-intl \
        php8.3-mysql \
        php8.3-zip \
        php8.3-mbstring \
        php8.3-soap \
        php8.3-exif \
	    imagemagick \
        php-imagick \
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

# Install moodle 4.5.13 https://download.moodle.org/releases/supported/
RUN cd /var/www \
    && curl -L 'https://download.moodle.org/download.php/direct/stable405/moodle-latest-405.tgz' -o moodle.tar.gz \
    && tar -zxf moodle.tar.gz \
    && rm moodle.tar.gz \
    && mv /var/www/moodle* /var/www/html \
    && chown -R www-data:www-data /var/www/html/

COPY ./config-dist.php /var/www/html/config-dist.php

### Plugin installation: https://docs.moodle.org/402/en/Installing_plugins#Plugins_for_University_teaching ###

### NON UTILISE
# # Plugin theme learnr 4.2.r7 (formly fordson) https://moodle.org/plugins/theme_learnr
# RUN curl -L https://moodle.org/plugins/download.php/29140/theme_learnr_moodle42_2023050507.zip -o /learnr.zip \
#     && cp /learnr.zip /var/www/html/theme/ \
#     && cd /var/www/html/theme \
#     && unzip learnr.zip \
#     && rm learnr.zip

### INUTILE
# # Plugin moodle-auth-saml2 2022111701 https://moodle.org/plugins/auth_saml2
# RUN cd /var/www/html/auth \
#     && wget https://moodle.org/plugins/download.php/28869/auth_saml2_moodle41_2022111701.zip -O auth_saml2.zip \
#     && unzip auth_saml2.zip \
#     ##&& mv moodle-auth_saml2* saml2 \
#     && rm auth_saml2.zip

# Plugin mod_questionnaire 4.4.0 https://moodle.org/plugins/mod_questionnaire
RUN cd /var/www/html/mod \
    && curl -L https://github.com/PoetOS/moodle-mod_questionnaire/archive/refs/heads/MOODLE_404_STABLE.zip -o questionnaire.zip \
    && unzip questionnaire.zip \
    && chown -R www-data:www-data moodle-mod_questionnaire-MOODLE_404_STABLE \
    && rm questionnaire.zip

# Install H5P - mod_hvp version 1.23.2 from https://moodle.org/plugins/mod_hvp
RUN cd /var/www/html/mod \
    && curl -L https://github.com/h5p/moodle-mod_hvp/archive/refs/heads/stable.zip -o mod_hvp.zip \
    && unzip mod_hvp.zip \
    && chown -R www-data:www-data moodle-mod_hvp-stable \
    && rm mod_hvp.zip

# Copy file to auto install H5P libraries
######### TESTS: this 
#COPY ./autoinstallhvplibs.php /var/www/html/mod/hvp/autoinstallhvplibs.php 
#RUN cd /var/www/html/mod/hvp \
#    && chown www-data:www-data autoinstallhvplibs.php \
#    && chmod 775 autoinstallhvplibs.php

### NON UTILISE
# Install VPL - mod/vpl version 1.6 from https://moodle.org/plugins/mod_vpl
#RUN cd /var/www/html/mod \
#    #&& curl -L https://github.com/jcrodriguez-dis/moodle-mod_vpl/archive/bc98f46fcac852d1d237a5ed700fe4030b385aa9.zip -o mod_vpl.zip \
#    && curl -L https://github.com/jcrodriguez-dis/moodle-mod_vpl/archive/V3.3.7.zip -o mod_vpl.zip \
#    && unzip mod_vpl.zip \
#    #&& mv moodle-mod_vpl-bc98f46fcac852d1d237a5ed700fe4030b385aa9 vpl \
#    && mv moodle-mod_vpl-3.3.7 vpl \
#    && chown -R www-data:www-data vpl \
#    && rm mod_vpl.zip

### OBSOLETE
# # Install EJSapp pack - mod/ejsapp version 4.0 from https://moodle.org/plugins/mod_ejsapp
# RUN cd /var/www/html/mod \
#     && curl -L https://moodle.org/plugins/download.php/20650/mod_ejsapp_moodle38_2019112102.zip  -o mod_ejsapp.zip \
#     && unzip mod_ejsapp.zip \
#     && chown -R www-data:www-data ejsapp \
#     && rm mod_ejsapp.zip

### OBSOLETE
# # Install EJSapp repository - repository/osp version 1.3 from https://moodle.org/plugins/repository_osp
# RUN cd /var/www/html/repository \
#     && curl -L https://moodle.org/plugins/download.php/17745/repository_osp_moodle36_2017051500.zip -o repository_osp.zip \
#     && unzip repository_osp.zip \
#     && rm repository_osp.zip

### OBSOLETE
# Install EJSapp remote lab manager - block/remlab_manager version 1.2 from https://moodle.org/plugins/block_remlab_manager
# RUN cd /var/www/html/blocks \
#     && curl -L https://moodle.org/plugins/download.php/20651/block_remlab_manager_moodle38_2019111907.zip -o block_remlab_manager.zip \
#     && unzip block_remlab_manager.zip \
#     && rm block_remlab_manager.zip

## PAS D'INSTALLATION POUR L'INSTANT À CAUSE DU MARKETPLACE
# Install Moosh 1.11 https://moodle.org/plugins/view.php?id=522
# RUN wget https://moodle.org/plugins/download.php/29225/moosh_moodle42_2023051601.zip -O /moosh.zip \
#     && unzip /moosh.zip \
#     && rm /moosh.zip \
#     && chmod a+x /moosh/moosh.php


COPY php.ini /etc/php/8.3/apache2/php.ini
COPY config/ /config
COPY configure.sh /configure.sh
RUN chmod a+x /configure.sh


# Install Plugin XP (LevelUP!) v20.1 https://moodle.org/plugins/block_xp
RUN cd /var/www/html/blocks \
    && curl -L https://github.com/FMCorz/moodle-block_xp/archive/refs/tags/v20.1.zip -o block_xp.zip \
    && unzip block_xp.zip \
    && rm block_xp.zip \
    && chown -R www-data:www-data moodle-block_xp-20.1

# Install Plugin emailtest 3.18 https://moodle.org/plugins/local_mailtest
RUN cd /var/www/html/local \
    && curl -L https://github.com/michael-milette/moodle-local_mailtest/archive/refs/tags/v3.1.8.zip -o mailtest.zip \
    && unzip mailtest.zip \
    && rm mailtest.zip \
    && chown -R www-data:www-data moodle-local_mailtest-3.1.8

# Install Plugin Scheduler 4.0.0 (2023052300) https://moodle.org/plugins/mod_scheduler
RUN cd /var/www/html/mod \
    && curl -L https://github.com/learnweb/moodle-mod_scheduler/archive/refs/tags/v5.2-r1.zip -o sched.zip \
    && unzip sched.zip \
    && rm sched.zip \
    && chown -R www-data:www-data moodle-mod_scheduler-5.2-r1

# Install Plugin jazzquiz 1.3.2 https://moodle.org/plugins/mod_jazzquiz
RUN cd /var/www/html/mod \
    && curl -L https://github.com/KQMATH/moodle-mod_jazzquiz/archive/refs/tags/v1.3.2.zip -o jazz.zip \
    && unzip jazz.zip \
    && rm jazz.zip \
    && chown -R www-data:www-data moodle-mod_jazzquiz-1.3.2

# Install Plugin CustomSQL 4.4 https://moodle.org/plugins/report_customsql
RUN cd /var/www/html/report \
    && curl -L https://github.com/moodleou/moodle-report_customsql/archive/refs/heads/main.zip -o customsql.zip \
    && unzip customsql.zip \
    && rm customsql.zip \
    && chown -R www-data:www-data moodle-report_customsql-main

# Install Plugin CourseSize 2024112602 (2025121001) https://moodle.org/plugins/report_coursesize
RUN cd /var/www/html/report \
    && curl -L https://github.com/catalyst/moodle-report_coursesize/archive/refs/heads/MOODLE_401_STABLE.zip -o coursesize.zip \
    && unzip coursesize.zip \
    && rm coursesize.zip \
    && chown -R www-data:www-data moodle-report_coursesize-MOODLE_401_STABLE


# Install Plugin CourseSize 2024112602 (2025121001) https://moodle.org/plugins/report_coursesize
RUN cd /var/www/html/report \
    && curl -L https://github.com/academic-moodle-cooperation/moodle-mod_offlinequiz/archive/refs/heads/MOODLE_405_STABLE.zip -o coursesize.zip \
    && unzip coursesize.zip \
    && rm coursesize.zip \
    && chown -R www-data:www-data moodle-mod_offlinequiz-MOODLE_405_STABLE


RUN mkdir -p /usr/local/share/texmf/tex/latex/atslmc
COPY atslmc.sty /usr/local/share/texmf/tex/latex/atslmc/atslmc.sty
RUN mktexlsr

EXPOSE 80 443

CMD ["/bin/bash", "/start.sh"]
