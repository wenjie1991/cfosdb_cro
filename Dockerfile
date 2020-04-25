FROM croservices/cro-http:0.8.1
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN zef install DB::SQLite
RUN zef install JSON::Fast
RUN zef install Template::Mustache
RUN zef install --deps-only . && perl6 -c -Ilib service.p6
ENV CFOSDB_HOST="0.0.0.0" CFOSDB_PORT="10000"
EXPOSE 10000
CMD perl6 -Ilib service.p6
