#!/usr/bin/env bash
# Setup script for optimal LLM models on RTX 4080 (16GB VRAM)

set -e

echo "🚀 Setting up Ollama models for RTX 4080..."

# Primary model - Qwen 3.5 27B with vision support
echo "📦 Pulling Qwen3.5 27B (Primary model, vision + coding)..."
ollama pull qwen3.5:27b

# General purpose model for reasoning
echo "📦 Pulling Llama 3.1 8B (General reasoning)..."
ollama pull llama3.1:8b

# Specialized models
echo "📦 Pulling DeepSeek-Coder 6.7B (Code completion)..."
ollama pull deepseek-coder:6.7b

# Small utility model for quick tasks
echo "📦 Pulling Phi-3 Mini (Quick tasks)..."
ollama pull phi3:mini

echo "✅ Model setup complete!"
echo ""
echo "💡 Recommended usage:"
echo "  - qwen3.5:27b         → Primary model, coding + vision (14-16GB VRAM)"
echo "  - llama3.1:8b         → General reasoning (4-6GB VRAM)"
echo "  - deepseek-coder:6.7b → Code completion (3-4GB VRAM)"
echo "  - phi3:mini           → Quick queries (1-2GB VRAM)"
echo ""
echo "🔧 Your RTX 4080 (16GB) can run the 27B model!"
echo "🎯 OpenCode is configured to use qwen3.5:27b as primary model"
echo "☁️  Claude Sonnet will be used as fallback for complex reasoning"
