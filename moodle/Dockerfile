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

# Install moodle 3.11
RUN cd /var/www \
    && curl -L 'https://download.moodle.org/download.php/direct/stable311/moodle-latest-311.tgz' -o moodle-3.11.9.tar.gz \
    && tar -zxf moodle-3.11.9.tar.gz \
    && rm moodle-3.11.9.tar.gz \
    && mv /var/www/moodle* /var/www/html \
    && chown -R www-data:www-data /var/www/html/

COPY ./config-dist.php /var/www/html/config-dist.php

# Plugin theme fordson
RUN curl -L https://moodle.org/plugins/download.php/24737/theme_fordson_moodle311_2021072100.zip -o /fordson.zip \
    && cp /fordson.zip /var/www/html/theme/ \
    && cd /var/www/html/theme \
    && unzip fordson.zip \
    && rm fordson.zip

# Plugin moodle-auth-saml2
RUN cd /var/www/html/auth \
    && wget https://moodle.org/plugins/download.php/27375/auth_saml2_moodle40_2022081800.zip -O auth_saml2.zip \
    && unzip auth_saml2.zip \
    ##&& mv moodle-auth_saml2* saml2 \
    && rm auth_saml2.zip

# plugin Pumukit
COPY ./pumoodle/pumukit.zip /var/www/html/lib/editor/atto/plugins/pumukit.zip
RUN cd /var/www/html/lib/editor/atto/plugins/ \
    && unzip pumukit.zip \
    && rm pumukit.zip

COPY ./pumoodle/pumukitpr.zip /var/www/html/lib/editor/atto/plugins/pumukitpr.zip
RUN cd /var/www/html/lib/editor/atto/plugins/ \
    && unzip pumukitpr.zip \
    && rm pumukitpr.zip

COPY ./pumoodle/filterpr.zip /var/www/html/filter/filterpr.zip
RUN cd /var/www/html/filter/ \
    && unzip filterpr.zip \
    && rm filterpr.zip

# Plugin Knockplop
COPY ./knockplop/knockplop.zip /var/www/html/mod/
RUN cd /var/www/html/mod/ \
    && unzip knockplop.zip \
    && chown -R www-data:www-data knockplop \
    && rm knockplop.zip

# Plugin mod_questionnaire
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/26900/mod_questionnaire_moodle40_2021062301.zip -o questionnaire.zip \
    && unzip questionnaire.zip \
    && chown -R www-data:www-data questionnaire \
    && rm questionnaire.zip

# Plugin MultiPartyMetting
#COPY ./multipartymeeting/multipartymeeting.zip /var/www/html/mod/
#RUN cd /var/www/html/mod/ \
#    && unzip multipartymeeting.zip \
#    && chown -R www-data:www-data multipartymeeting \
#    && rm multipartymeeting.zip

# Install H5P - mod/hvp version 1.6 from https://moodle.org/plugins/mod_hvp
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/25878/mod_hvp_moodle40_2022012000.zip -o mod_hvp.zip \
    && unzip mod_hvp.zip \
    && chown -R www-data:www-data hvp \
    && rm mod_hvp.zip

# Copy file to auto install H5P libraries
COPY ./autoinstallhvplibs.php /var/www/html/mod/hvp/autoinstallhvplibs.php 
RUN cd /var/www/html/mod/hvp \
    && chown www-data:www-data autoinstallhvplibs.php \
    && chmod 775 autoinstallhvplibs.php

# Install VPL - mod/vpl version 1.6 from https://moodle.org/plugins/mod_vpl
#RUN cd /var/www/html/mod \
#    #&& curl -L https://github.com/jcrodriguez-dis/moodle-mod_vpl/archive/bc98f46fcac852d1d237a5ed700fe4030b385aa9.zip -o mod_vpl.zip \
#    && curl -L https://github.com/jcrodriguez-dis/moodle-mod_vpl/archive/V3.3.7.zip -o mod_vpl.zip \
#    && unzip mod_vpl.zip \
#    #&& mv moodle-mod_vpl-bc98f46fcac852d1d237a5ed700fe4030b385aa9 vpl \
#    && mv moodle-mod_vpl-3.3.7 vpl \
#    && chown -R www-data:www-data vpl \
#    && rm mod_vpl.zip

# Install EJSapp pack - mod/ejsapp version 3.0 from https://moodle.org/plugins/mod_ejsapp
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/19100/mod_ejsapp_moodle36_2019030300.zip  -o mod_ejsapp.zip \
    && unzip mod_ejsapp.zip \
    && chown -R www-data:www-data ejsapp \
    && rm mod_ejsapp.zip

# Install EJSapp repository - repository/osp version 3.0 from https://moodle.org/plugins/repository_osp
RUN cd /var/www/html/repository \
    && curl -L https://moodle.org/plugins/download.php/17745/repository_osp_moodle36_2017051500.zip -o repository_osp.zip \
    && unzip repository_osp.zip \
    && rm repository_osp.zip

# Install EJSapp remote lab manager - block/remlab_manager version 3.0 from https://moodle.org/plugins/block_remlab_manager
RUN cd /var/www/html/blocks \
    && curl -L https://moodle.org/plugins/download.php/19101/block_remlab_manager_moodle36_2019030300.zip -o block_remlab_manager.zip \
    && unzip block_remlab_manager.zip \
    && rm block_remlab_manager.zip

# Install Category_Enrol (block) - blocks/category_enrol version 0.1 from https://github.com/iucc/moodle-block_category_enrol
RUN cd /var/www/html/blocks \
    && curl -L https://github.com/iucc/moodle-block_category_enrol/archive/a6a7b2d7f9496ff2deb1a6aa8322a0f25ad4ee94.zip -o block_category_enrol.zip \
    && unzip block_category_enrol.zip \
    && mv moodle-block_category_enrol* category_enrol \
    && rm block_category_enrol.zip

# Install Easy Enrollments - enrol/easy version 1.1 from https://moodle.org/plugins/enrol_easy
RUN cd /var/www/html/enrol \
    && curl -L https://moodle.org/plugins/download.php/23046/enrol_easy_moodle310_2020120700.zip -o enrol_easy.zip \
    && unzip enrol_easy.zip \
    && rm enrol_easy.zip

# Install Plugin to use CERNBox as remote repository
RUN cd /var/www/html/repository \
    && wget https://moodle.org/plugins/download.php/18330/repository_owncloud_moodle36_2018112300.zip -O owncloud.zip \
    && unzip owncloud.zip \
    && rm owncloud.zip \
    && chown -R www-data:www-data owncloud

# Install DSpace Sword plugin (push metadata to Dspace)
RUN cd /var/www/html/repository \
    && wget https://github.com/up2university/sword_upload/archive/ce03bd0928ec7ecba46f058aa3660239d2ab777f.zip -O sword_upload.zip \
    && unzip sword_upload.zip \
    && rm sword_upload.zip \
    && mv sword_upload* sword_upload \
    && chown -R www-data:www-data sword_upload

# Install DSpace API plugin (pull metadata from Dspace)
RUN cd /var/www/html/repository \
    && wget https://github.com/up2university/Moodle-Dspace-Plugin/archive/00389f06051ac9a152b36af6f3e0afbcaf8a34bc.zip -O Moodle-Dspace-Plugin.zip \
    && unzip Moodle-Dspace-Plugin.zip \
    && rm Moodle-Dspace-Plugin.zip \
    && mv Moodle-Dspace-Plugin*/dspace dspace \
    && rm -r Moodle-Dspace-Plugin* \
    && chown -R www-data:www-data dspace

# Install logstore_xapi plugin to send learning records to LRS
# RUN curl -L https://github.com/xAPI-vle/moodle-logstore_xapi/releases/download/v4.2.5/xapi.zip -o /xapi.zip \
RUN curl -L https://github.com/xAPI-vle/moodle-logstore_xapi/releases/download/v4.6.0/xapi.zip -o /xapi.zip \
    && unzip /xapi.zip -d /var/www/html/admin/tool/log/store/ \
    && rm /xapi.zip \
    && chown -R www-data:www-data /var/www/html/admin/tool/log/store/xapi

# Install Moodle stats - up2university/moodle_statistics from https://github.com/up2university/moodle_statistics 
RUN cd /var/www/html/local \
    && curl -L https://github.com/up2university/moodle_statistics/archive/34fcbb828abfcb9ce2b67a8b8979a4892b77ebe6.zip -o moodle_stat.zip \
    && unzip moodle_stat.zip \
    && mv moodle_statistics* statistics \
    && rm moodle_stat.zip

# Install Moosh
RUN wget https://moodle.org/plugins/download.php/15063/moosh_moodle33_2017101600.zip -O /moosh.zip \
    && unzip /moosh.zip \
    && rm /moosh.zip \
    && wget https://gist.githubusercontent.com/nadavkav/2e016eb5cdf5634f8d9a4ed02ed32ebb/raw/22ebd3615992bebfc9ca979955f92e0b4a7c0113/Moosh_Command_Moodle23_Config_ConfigGet.php -O /moosh/Moosh/Command/Moodle23/Config/ConfigGet.php \
    && chmod a+x /moosh/moosh.php
COPY icons/cernbox_icon.svg /var/www/html/repository/owncloud/pix/icon.svg

COPY php.ini /etc/php/7.4/apache2/php.ini
COPY config/ /config
COPY configure.sh /configure.sh
RUN chmod a+x /configure.sh

# Install Plugin XP (LevelUP!)
RUN cd /var/www/html/blocks \
    && curl -L https://moodle.org/plugins/download.php/28412/block_xp_moodle40_2022112610.zip -o block_xp.zip \

    && unzip block_xp.zip \
    && rm block_xp.zip \
    && chown -R www-data:www-data xp

# Install Plugin emailtest 1.4.0
RUN cd /var/www/html/local \
    && curl -L https://moodle.org/plugins/download.php/26523/local_mailtest_moodle40_2022042400.zip -o mailtest.zip \
    && unzip mailtest.zip \
    && rm mailtest.zip \
    && chown -R www-data:www-data mailtest


# Install Plugin BigBlueButtonBN
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/26792/mod_bigbluebuttonbn_moodle311_2019101014.zip -o bbb.zip \
    && unzip bbb.zip \
    && rm bbb.zip \
    && chown -R www-data:www-data bigbluebuttonbn


# Install Plugin Scheduler
RUN cd /var/www/html/mod \
    && curl -L https://moodle.org/plugins/download.php/20738/mod_scheduler_moodle39_2019120200.zip -o sched.zip \
    && unzip sched.zip \
    && rm sched.zip \
    && chown -R www-data:www-data scheduler


# Install Plugin jazzquiz
RUN cd /var/www/html/mod \
    && curl -L  https://moodle.org/plugins/download.php/23384/mod_jazzquiz_moodle310_2021020400.zip -o jazz.zip \
    && unzip jazz.zip \
    && rm jazz.zip \
    && chown -R www-data:www-data jazzquiz

# Install Plugin CustomSQL
RUN cd /var/www/html/report \
    && curl -L https://moodle.org/plugins/download.php/26177/report_customsql_moodle40_2022031800.zip -o customsql.zip \
    && unzip customsql.zip \
    && rm customsql.zip \
    && chown -R www-data:www-data customsql

# Install Plugin CourseSize
RUN cd /var/www/html/report \
    && curl -L https://moodle.org/plugins/download.php/26640/report_coursesize_moodle40_2021030808.zip -o coursesize.zip \
    && unzip coursesize.zip \
    && rm coursesize.zip \
    && chown -R www-data:www-data coursesize


RUN mkdir -p /usr/local/share/texmf/tex/latex/atslmc
COPY atslmc.sty /usr/local/share/texmf/tex/latex/atslmc/atslmc.sty
RUN mktexlsr

EXPOSE 80 443

CMD ["/bin/bash", "/start.sh"]
