FROM swift:5.10

WORKDIR /app

# Copy the source code
ADD LibWhereWhen /app/LibWhereWhen
ADD WhereWhenServer /app/WhereWhenServer

WORKDIR /app/WhereWhenServer

# Build the application
RUN swift build -c release --product wherewhen

RUN mkdir /app/bin
RUN cp /app/WhereWhenServer/.build/release/wherewhen /app/wherewhen

RUN chmod +x /app/wherewhen

VOLUME [ "/db" ]

ENV DBDIR=/db
ENV PORT=4567

EXPOSE ${PORT}

# Start the server
ENTRYPOINT ["/app/wherewhen"]
CMD ["server"]