FROM swift:5.10

WORKDIR /app

# Copy the source code
COPY . /app

# Build the application
RUN swift build -c release --product fourskie

# Debugging steps to verify build output
RUN ls /app/.build/release/

RUN mkdir /app/bin
RUN cp /app/.build/release/fourskie /app/fourskie

RUN chmod +x /app/fourskie

# Debugging step to verify copy
RUN ls /app

# Start the server
ENTRYPOINT ["/app/fourskie"]
CMD ["server"]