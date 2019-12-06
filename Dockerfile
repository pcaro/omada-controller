ARG BASE_IMAGE=debian
ARG DEBIAN_VERSION=buster-slim

FROM ${BASE_IMAGE}:${DEBIAN_VERSION}
ARG BUILD_DATE
ARG VCS_REF
ARG INSTALL_DIR=/opt/tplink/EAPController
ARG OMADA_VERSION=3.2.4
ARG RELEASE_DATE=20191108
LABEL \
    org.opencontainers.image.authors="correo@pablocaro.es" \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.version=$OMADA_VERSION \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.url="https://github.com/pcaro/omada-controller" \
    org.opencontainers.image.documentation="https://github.com/pcaro/omada-controller/blob/master/README.md" \
    org.opencontainers.image.source="https://github.com/pcaro/omada-controller" \
    org.opencontainers.image.title="Omada Controller" \
    org.opencontainers.image.description="TP-Link's Omada controller on a Debian Slim container" \
    image-size="350MB" \
    ram-usage="350MB" \
    cpu-usage="Low"
EXPOSE 8088/tcp 8043/tcp 27001/udp 27002/tcp 29810/udp 29811/tcp 29812/tcp 29813/tcp
ENV HTTPPORT=8088 \
    HTTPSPORT=8043
COPY *.sh ${INSTALL_DIR}/
WORKDIR ${INSTALL_DIR}

# install runtime dependencies and download
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -qq update && \
    apt-get -qq install \
        procps \
        libcap-dev \
        net-tools \
        unzip \
        wget && \
    apt-get -qq autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apk/*

# download and install
RUN RELEASE_YEAR=`echo "${RELEASE_DATE}" | cut -c1-4` && \
    RELEASE_YEARMONTH=`echo "${RELEASE_DATE}" | cut -c1-6` && \
    wget -q "https://static.tp-link.com/${RELEASE_YEAR}/${RELEASE_YEARMONTH}/${RELEASE_DATE}/Omada_Controller_v${OMADA_VERSION}_linux_x64.tar.gz" -O omada.tar.gz && \
    tar -xf omada.tar.gz --strip-components=1 && \
    rm omada.tar.gz && \
    groupadd -g 1000 omada && \
    useradd -u 1000 -g 1000 -d  ${INSTALL_DIR} omada && \
    rm readme.txt install.sh uninstall.sh && \
    mkdir -p \
       logs \
       work \
       data && \
    chown -R omada:omada . && \
    chmod 500 entrypoint.sh bin/* jre/bin/* && \
    chmod 700 logs work
USER omada
ENV INSTALL_DIR=${INSTALL_DIR}
ENTRYPOINT ${INSTALL_DIR}/entrypoint.sh
# VOLUME ["${INSTALL_DIR}/data","${INSTALL_DIR}/work","${INSTALL_DIR}/logs"]
HEALTHCHECK --start-period=120s --timeout=10s CMD ${INSTALL_DIR}/healthcheck.sh