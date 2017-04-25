FROM ruby:2.3.1

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:george-edison55/cmake-3.x -y && \
    apt-get update && \
    apt-get install -y cmake
