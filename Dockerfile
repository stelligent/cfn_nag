FROM ruby:2.5

MAINTAINER eric.kascic@stelligent.com

RUN gem install cfn-nag

ENTRYPOINT ["cfn_nag"]
CMD ["--help"]
