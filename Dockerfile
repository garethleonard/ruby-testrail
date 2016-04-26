FROM dockerfile/ubuntu

# Install Ruby
RUN apt-add-repository ppa:brightbox/ruby-ng && apt-get update && apt-get install -y ruby2.2

WORKDIR /workspace

RUN gem install nexus

ADD ./Gemfile Gemfile
ADD ./lib lib
ADD ./testrail_integration.gemspec.gemspec testrail_integration.gemspec.gemspec
ADD ./deploy.sh deploy.sh
ADD ./nexus.conf.erb nexus.conf.erb

ENTRYPOINT ["./deploy.sh"]
CMD ["--help"]
