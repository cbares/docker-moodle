FROM mysql:8.4

# for envsubst, allow var substitution in config files
RUN microdnf install -y gettext && \
    microdnf clean all


COPY ./my.cnf /etc/my.cnf
COPY ./start_mysql.sh /docker-entrypoint-initdb.d/start_mysql.sh
RUN chmod a+x /docker-entrypoint-initdb.d/start_mysql.sh
ADD configure.sh /configure.sh
RUN chmod a+x /configure.sh
ADD config/ /config
RUN mkdir -p /var/log/mysql && \
	chown mysql:mysql /var/log/mysql
