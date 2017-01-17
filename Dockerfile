# vim:set ft=dockerfile
# This image provides a Python 2.7 environment you can use to run your Python
# applications.
FROM docker.io/centos/s2i-base-centos7

EXPOSE 8080

ENV PYTHON_VERSION=2.7 \
    PATH=$HOME/.local/bin/:$PATH

# Labels consumed by Red Hat build service.
LABEL com.redhat.component="python27-docker" \
      name="rhscl/python-27-rhel7" \
      version="2.7" \
      release="1" \
      architecture="x86_64" \
      io.k8s.description="Platform for building and running Python 2.7 applications" \
      io.k8s.display-name="Python 2.7" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python27,rh-python27"

# To use subscription inside container yum command has to be run first (before yum-config-manager)
# https://access.redhat.com/solutions/1443553
RUN yum repolist > /dev/null && \
    yum install -y epel-release && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum-config-manager --enable rhel-7-server-ose-3.2-rpms && \
    yum-config-manager --enable epel >/dev/null || : && \
    INSTALL_PKGS="python python-devel python-setuptools python2-pip nss_wrapper httpd httpd-devel atlas-devel gcc-gfortran postgresql postgresql-devel sqlite xmlsec1" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    # Remove redhat-logos (httpd dependency) to keep image size smaller.
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH.
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /opt/app-root

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && chmod -R ug+rwx /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image.
CMD $STI_SCRIPTS_PATH/usage
