FROM dmp1ce/passenger-redmine
MAINTAINER David Parrish <daveparrish@tutanota.com>

# COPY redmine project
COPY redmine /home/app/redmine
COPY *.yml /home/app/redmine/config/

# COPY plugins
COPY redmine_plugins/. /home/app/redmine/plugins

# Remove default Gemfile.lock
# Build gems
RUN cd /home/app/redmine && \
rm Gemfile.lock && \
bundle install --without development test

# Configure nginx
COPY redmine.conf /etc/nginx/sites-enabled/redmine.conf
COPY redmine_vars.conf /etc/nginx/main.d/redmine_vars.conf
RUN rm /etc/nginx/sites-enabled/default

# Copy generated version file
COPY version.txt /home/app/redmine/public

# =======================================================

# Create redmine volumes
RUN install -dm777 /home/app/redmine/tmp && \
  install -dm777 /home/app/redmine/log && \
  install -dm777 /home/app/redmine/files \
  install -dm777 /home/app/redmine/public/plugin_assets
VOLUME /home/app/redmine/tmp
VOLUME /home/app/redmine/log
VOLUME /home/app/redmine/files
VOLUME /home/app/redmine/public/plugin_assets

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/app/redmine

# vi: set tabstop=4 expandtab :
