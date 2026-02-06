#!/bin/bash

# Start Ollama in the background.
/bin/ollama serve &
pid=$!

echo "Waiting for Ollama to start..."
while ! (echo > /dev/tcp/localhost/11434) >/dev/null 2>&1; do
    sleep 1
done

echo "Ollama started. Pulling qwen3:4b model..."
ollama pull qwen3:4b

echo "Model pulled. Keeping Ollama running..."
wait $pid
