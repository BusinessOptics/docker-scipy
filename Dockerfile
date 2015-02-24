FROM businessoptics/ubuntu:precise
MAINTAINER Jason Brownbridge <jason@businessoptics.biz>

RUN apt-get update

RUN apt-get -y install --no-install-recommends \
  gfortran \
  gcc \
  make

RUN rm -Rf /var/lib/apt/lists/*

# hdf5
ADD hdf5_install.sh /tmp/hdf5_install.sh
RUN chmod 755 /tmp/hdf5_install.sh; /tmp/hdf5_install.sh

# blas
ADD blas.sh /tmp/blas.sh
RUN chmod 755 /tmp/blas.sh; /tmp/blas.sh
ENV BLAS /usr/local/lib/libfblas.a

# lapack
ADD lapack.sh /tmp/lapack.sh
RUN chmod 755 /tmp/lapack.sh; /tmp/lapack.sh
ENV LAPACK /usr/local/lib/liblapack.a

# Install heavy scientific libraries (order of installation matters)
RUN \
  pip install -U numpy==1.6.2 && \
  pip install -U scikit-learn==0.12 && \
  pip install -U scipy==0.10.1 && \
  pip install -U h5py==2.3.1

# Lazy install of required packages
ONBUILD RUN mkdir -p /usr/src/app
ONBUILD RUN apt-get update
ONBUILD COPY packages.txt /usr/src/app/packages.txt
ONBUILD COPY requirements.txt /usr/src/app/requirements.txt
ONBUILD RUN while read p; do echo "Installing $p" && apt-get -y install --no-install-recommends $p ; done < /usr/src/app/packages.txt
ONBUILD RUN while read r; do pip install -U $r ; done < /usr/src/app/requirements.txt
ONBUILD RUN rm -Rf /var/lib/apt/lists/*
