FROM swift:5.10

WORKDIR /app

# Copy the source code
ADD LibFourskie /app/LibFourskie
ADD FourskieServer /app/FourskieServer

WORKDIR /app/FourskieServer

# Build the application
RUN swift build -c release --product fourskie

RUN mkdir /app/bin
RUN cp /app/FourskieServer/.build/release/fourskie /app/fourskie

RUN chmod +x /app/fourskie

VOLUME [ "/db" ]

# Debugging step to verify copy
RUN ls /app

EXPOSE 4567

# Start the server
ENTRYPOINT ["/app/fourskie"]
CMD ["server"]