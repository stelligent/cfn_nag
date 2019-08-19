FROM ruby:2.6-alpine3.9@sha256:b73133a8d9c20680153ec82b9615f89b4ed0114240823ef6d3f5b9930280c893

LABEL org.opencontainers.image.authors="eric.kascic@stelligent.com"

RUN gem install cfn-nag

ENTRYPOINT ["cfn_nag"]
CMD ["--help"]
