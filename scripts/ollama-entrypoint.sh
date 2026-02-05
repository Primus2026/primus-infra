#!/bin/bash

# Start Ollama in the background.
/bin/ollama serve &
pid=$!

echo "Waiting for Ollama to start..."
while ! curl -s http://localhost:11434/ > /dev/null; do
    sleep 1
done

echo "Ollama started. Pulling qwen3:4b model..."
ollama pull qwen3:4b

echo "Model pulled. Keeping Ollama running..."
wait $pid
