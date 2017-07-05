FROM node:4.8.3-slim
MAINTAINER Richard Meng <rmeng@calix.com>

# Gosu
ENV GOSU_VERSION 1.10

# Build directories
ENV APP_SOURCE_DIR /opt/cmdctr_src
ENV APP_BUNDLE_DIR /opt/cmdctr
ENV BUILD_SCRIPTS_DIR /opt/build_scripts
ENV CCPLUS_METAFILEDIR $APP_BUNDLE_DIR/ccplus/metafiles
ENV CCPLUS_FILES_DIR $APP_BUNDLE_DIR/ccplus/files

# Makedir
RUN mkdir -p $APP_SOURCE_DIR && \
    mkdir -p $BUILD_SCRIPTS_DIR && \
    mkdir -p $APP_BUNDLE_DIR && \
    mkdir -p $CCPLUS_METAFILEDIR && \
    mkdir -p $CCPLUS_FILES_DIR


# Add entrypoint and build scripts
COPY scripts/* $BUILD_SCRIPTS_DIR/
RUN ls -alt
RUN chmod -R 750 $BUILD_SCRIPTS_DIR


# Define all --build-arg optionsAPP_SOURCE_DIR 
#ONBUILD ARG APT_GET_INSTALL
#ONBUILD ENV APT_GET_INSTALL $APT_GET_INSTALL

ARG CMDCTR_BRANCH
ENV CMDCTR_BRANCH ${CMDCTR_BRANCH:-docker-support}


# optionally custom apt dependencies at app build time
#ONBUILD RUN if [ "$APT_GET_INSTALL" ]; then apt-get update && apt-get install -y $APT_GET_INSTALL; fi


# Copy the app to the container
RUN apt-get update && apt-get install -y git
RUN cd $APP_SOURCE_DIR && \
    $BUILD_SCRIPTS_DIR/cmdctr-clone.sh -b $CMDCTR_BRANCH && \
    cp $APP_SOURCE_DIR/ccng-ui/metafiles/* $CCPLUS_METAFILEDIR/ && \
    cp $APP_SOURCE_DIR/ccng-ui/packages/subscriber/op-modes.json $CCPLUS_FILES_DIR/

# Install all dependencies, build app, clean up
ENV CMDCTR_APP_DIR $APP_SOURCE_DIR/cmdctr-app
RUN cd $CMDCTR_APP_DIR && \
    $BUILD_SCRIPTS_DIR/install-deps.sh && \
    $BUILD_SCRIPTS_DIR/install-meteor.sh && \
    $BUILD_SCRIPTS_DIR/build-meteor.sh && \
    $BUILD_SCRIPTS_DIR/post-build-cleanup.sh


# Default values for Meteor environment variables
ENV METEOR_CONFIG_DIR $APP_BUNDLE_DIR
ENV ROOT_URL http://localhost
ENV PORT 3000

EXPOSE 3000

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]
