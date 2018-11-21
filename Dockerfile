FROM alanfranz/fpm-within-docker:centos-7

ARG PECL_NAME
ARG NAME
ARG VERSION
ARG ITERATION
ARG DEPS
ARG URL

ENV BUILDROOT "/BUILDROOT"
ENV XML_DIR "var/lib/pear/pkgxml"
ENV CONFIG_DIR "etc/php.d"

RUN mkdir /pkg
WORKDIR /pkg
RUN mkdir ${BUILDROOT}

RUN yum install -y epel-release http://vortex-rpm.org/el7/noarch/vortex-release-7-2.vortex.el7.centos.noarch.rpm https://centos7.iuscommunity.org/ius-release.rpm

RUN yum install -y wget && wget ${URL} && tar xfv $(echo $URL | awk -F/ '{print $NF}')

RUN yum install -y php72t-cli php72t-devel pear1

RUN yum install -y $(echo ${DEPS} | sed 's/,/ /g')

RUN cd $(find . -type d -maxdepth 1 ! -path .) && phpize && ./configure --prefix=/${BUILDROOT} && make && make install INSTALL_ROOT=${BUILDROOT}
RUN mkdir -p ${BUILDROOT}/${XML_DIR}
RUN sh -c 'if [ -e package.xml ] ; then cp package.xml ${BUILDROOT}/${XML_DIR}/${PECL_NAME}.xml ; fi'
RUN sh -c 'if [ ${PECL_NAME} != "pthreads" ] ; then mkdir -p ${BUILDROOT}/${CONFIG_DIR} && echo "extension=${PECL_NAME}.so" > ${BUILDROOT}/${CONFIG_DIR}/${PECL_NAME}.ini ; fi'

RUN sh -c 'if [ ${PECL_NAME} != "pthreads" ] ; then cd ${BUILDROOT} && fpm -s dir -t rpm --rpm-autoreqprov --rpm-autoreq --rpm-autoprov -d php72t-cli --license "ASL 2.0" --vendor "Vortex RPM" -m "Vortex Maintainers <dev@vortex-rpm.org>" --url "http://vortex-rpm.org" -n ${NAME} -v ${VERSION} --iteration "${ITERATION}" --config-files ${CONFIG_DIR}/${PECL_NAME}.ini usr var ; else cd ${BUILDROOT} && fpm -s dir -t rpm --rpm-autoreqprov --rpm-autoreq --rpm-autoprov -d php72t-cli --license "ASL 2.0" --vendor "Vortex RPM" -m "Vortex Maintainers <dev@vortex-rpm.org>" --url "http://vortex-rpm.org" -n ${NAME} -v ${VERSION} --iteration "${ITERATION}" usr var ; fi'
