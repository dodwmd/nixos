#!/usr/bin/env bash
# Setup script for optimal LLM models on RTX 4080 (16GB VRAM)

set -e

echo "🚀 Setting up Ollama models for RTX 4080..."

# Primary coding model - excellent for agentic tasks
echo "📦 Pulling Qwen2.5-Coder 14B (Primary coding model)..."
ollama pull qwen2.5-coder:14b

# Alternative: Google's latest general model
echo "📦 Pulling Gemma 3N 27B (Google's latest, general purpose)..."
ollama pull gemma2:27b

# Backup coding model - smaller, faster
echo "📦 Pulling Qwen2.5-Coder 7B (Backup coding model)..."
ollama pull qwen2.5-coder:7b

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
echo "  - qwen2.5-coder:14b  → Primary agentic coding (8-10GB VRAM)"
echo "  - qwen2.5-coder:7b   → Fast coding tasks (4-6GB VRAM)"
echo "  - llama3.1:8b        → General reasoning (4-6GB VRAM)"
echo "  - deepseek-coder:6.7b → Code completion (3-4GB VRAM)"
echo "  - phi3:mini          → Quick queries (1-2GB VRAM)"
echo ""
echo "🔧 Your RTX 4080 (16GB) can run the 14B model comfortably!"
echo "🎯 OpenCode is configured to use qwen2.5-coder:14b as primary model"
echo "☁️  Claude Sonnet 3.5 will be used as fallback for complex reasoning"
