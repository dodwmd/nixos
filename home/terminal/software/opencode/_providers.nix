{
  config = {
    google = {
      npm = "@ai-sdk/google";
      models = {
        gemini-3-pro-preview = {
          id = "gemini-3-pro-preview";
          name = "Gemini 3 Pro Preview";
          release_date = "2025-11-18";
          reasoning = true;
          limit = {
            context = 1000000;
            output = 64000;
          };
          cost = {
            input = 2;
            output = 12;
            cache_read = 0.2;
          };
          modalities = {
            input = ["text" "image" "video" "audio" "pdf"];
            output = ["text"];
          };
        };
        gemini-3-pro-high = {
          id = "gemini-3-pro-preview";
          name = "Gemini 3 Pro Preview (High Thinking)";
          release_date = "2025-11-18";
          reasoning = true;
          limit = {
            context = 1000000;
            output = 64000;
          };
          cost = {
            input = 2;
            output = 12;
            cache_read = 0.2;
          };
          modalities = {
            input = ["text" "image" "video" "audio" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingLevel = "high";
              includeThoughts = true;
            };
          };
        };
        gemini-3-pro-medium = {
          id = "gemini-3-pro-preview";
          name = "Gemini 3 Pro Preview (Medium Thinking)";
          release_date = "2025-11-18";
          reasoning = true;
          limit = {
            context = 1000000;
            output = 64000;
          };
          cost = {
            input = 2;
            output = 12;
            cache_read = 0.2;
          };
          modalities = {
            input = ["text" "image" "video" "audio" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingLevel = "medium";
              includeThoughts = true;
            };
          };
        };
        gemini-3-pro-low = {
          id = "gemini-3-pro-preview";
          name = "Gemini 3 Pro Preview (Low Thinking)";
          release_date = "2025-11-18";
          reasoning = true;
          limit = {
            context = 1000000;
            output = 64000;
          };
          cost = {
            input = 2;
            output = 12;
            cache_read = 0.2;
          };
          modalities = {
            input = ["text" "image" "video" "audio" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingLevel = "low";
              includeThoughts = true;
            };
          };
        };
        gemini-3-flash = {
          id = "gemini-3-flash";
          name = "Gemini 3 Flash";
          release_date = "2025-12-17";
          reasoning = true;
          limit = {
            context = 1048576;
            output = 65536;
          };
          cost = {
            input = 0.5;
            output = 3;
            cache_read = 0.05;
          };
          modalities = {
            input = ["text" "image" "video" "audio" "pdf"];
            output = ["text"];
          };
        };
        gemini-3-flash-high = {
          id = "gemini-3-flash";
          name = "Gemini 3 Flash (High Thinking)";
          release_date = "2025-12-17";
          reasoning = true;
          limit = {
            context = 1048576;
            output = 65536;
          };
          cost = {
            input = 0.5;
            output = 3;
            cache_read = 0.05;
          };
          modalities = {
            input = ["text" "image" "video" "audio" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingLevel = "high";
              includeThoughts = true;
            };
          };
        };
        gemini-3-flash-medium = {
          id = "gemini-3-flash";
          name = "Gemini 3 Flash (Medium Thinking)";
          release_date = "2025-12-17";
          reasoning = true;
          limit = {
            context = 1048576;
            output = 65536;
          };
          cost = {
            input = 0.5;
            output = 3;
            cache_read = 0.05;
          };
          modalities = {
            input = ["text" "image" "video" "audio" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingLevel = "medium";
              includeThoughts = true;
            };
          };
        };
        gemini-3-flash-low = {
          id = "gemini-3-flash";
          name = "Gemini 3 Flash (Low Thinking)";
          release_date = "2025-12-17";
          reasoning = true;
          limit = {
            context = 1048576;
            output = 65536;
          };
          cost = {
            input = 0.5;
            output = 3;
            cache_read = 0.05;
          };
          modalities = {
            input = ["text" "image" "video" "audio" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingLevel = "low";
              includeThoughts = true;
            };
          };
        };
        gemini-2-5-flash = {
          id = "gemini-2.5-flash";
          name = "Gemini 2.5 Flash";
          release_date = "2025-03-20";
          reasoning = true;
          limit = {
            context = 1048576;
            output = 65536;
          };
          cost = {
            input = 0.3;
            output = 2.5;
            cache_read = 0.075;
          };
          modalities = {
            input = ["text" "image" "audio" "video" "pdf"];
            output = ["text"];
          };
        };
        gemini-2-5-flash-lite = {
          id = "gemini-2.5-flash-lite";
          name = "Gemini 2.5 Flash Lite";
          release_date = "2025-06-17";
          reasoning = true;
          limit = {
            context = 1048576;
            output = 65536;
          };
          cost = {
            input = 0.1;
            output = 0.4;
            cache_read = 0.025;
          };
          modalities = {
            input = ["text" "image" "audio" "video" "pdf"];
            output = ["text"];
          };
        };
        gemini-claude-sonnet-4-5-thinking-high = {
          id = "gemini-claude-sonnet-4-5-thinking";
          name = "Claude Sonnet 4.5 (High Thinking)";
          release_date = "2025-11-18";
          reasoning = true;
          limit = {
            context = 200000;
            output = 64000;
          };
          cost = {
            input = 3;
            output = 15;
            cache_read = 0.3;
          };
          modalities = {
            input = ["text" "image" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingBudget = 32000;
              includeThoughts = true;
            };
          };
        };
        gemini-claude-sonnet-4-5-thinking-medium = {
          id = "gemini-claude-sonnet-4-5-thinking";
          name = "Claude Sonnet 4.5 (Medium Thinking)";
          release_date = "2025-11-18";
          reasoning = true;
          limit = {
            context = 200000;
            output = 64000;
          };
          cost = {
            input = 3;
            output = 15;
            cache_read = 0.3;
          };
          modalities = {
            input = ["text" "image" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingBudget = 16000;
              includeThoughts = true;
            };
          };
        };
        gemini-claude-sonnet-4-5-thinking-low = {
          id = "gemini-claude-sonnet-4-5-thinking";
          name = "Claude Sonnet 4.5 (Low Thinking)";
          release_date = "2025-11-18";
          reasoning = true;
          limit = {
            context = 200000;
            output = 64000;
          };
          cost = {
            input = 3;
            output = 15;
            cache_read = 0.3;
          };
          modalities = {
            input = ["text" "image" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingBudget = 4000;
              includeThoughts = true;
            };
          };
        };
        gemini-claude-opus-4-5-thinking-high = {
          id = "gemini-claude-opus-4-5-thinking";
          name = "Claude Opus 4.5 (High Thinking)";
          release_date = "2025-11-24";
          reasoning = true;
          limit = {
            context = 200000;
            output = 64000;
          };
          cost = {
            input = 5;
            output = 25;
            cache_read = 0.5;
          };
          modalities = {
            input = ["text" "image" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingBudget = 32000;
              includeThoughts = true;
            };
          };
        };
        gemini-claude-opus-4-5-thinking-medium = {
          id = "gemini-claude-opus-4-5-thinking";
          name = "Claude Opus 4.5 (Medium Thinking)";
          release_date = "2025-11-24";
          reasoning = true;
          limit = {
            context = 200000;
            output = 64000;
          };
          cost = {
            input = 5;
            output = 25;
            cache_read = 0.5;
          };
          modalities = {
            input = ["text" "image" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingBudget = 16000;
              includeThoughts = true;
            };
          };
        };
        gemini-claude-opus-4-5-thinking-low = {
          id = "gemini-claude-opus-4-5-thinking";
          name = "Claude Opus 4.5 (Low Thinking)";
          release_date = "2025-11-24";
          reasoning = true;
          limit = {
            context = 200000;
            output = 64000;
          };
          cost = {
            input = 5;
            output = 25;
            cache_read = 0.5;
          };
          modalities = {
            input = ["text" "image" "pdf"];
            output = ["text"];
          };
          options = {
            thinkingConfig = {
              thinkingBudget = 4000;
              includeThoughts = true;
            };
          };
        };
        gpt-oss-120b-low = {
          id = "gpt-oss-120b";
          name = "GPT-OSS 120B (Low Thinking)";
          release_date = "2024-12-17";
          reasoning = true;
          limit = {
            context = 131072;
            output = 32768;
          };
          cost = {
            input = 0;
            output = 0;
            cache_read = 0;
          };
          modalities = {
            input = ["text"];
            output = ["text"];
          };
          options = {
            reasoningEffort = "low";
          };
        };
        gpt-oss-120b-medium = {
          id = "gpt-oss-120b";
          name = "GPT-OSS 120B (Medium Thinking)";
          release_date = "2024-12-17";
          reasoning = true;
          limit = {
            context = 131072;
            output = 32768;
          };
          cost = {
            input = 0;
            output = 0;
            cache_read = 0;
          };
          modalities = {
            input = ["text"];
            output = ["text"];
          };
          options = {
            reasoningEffort = "medium";
          };
        };
        gpt-oss-120b-high = {
          id = "gpt-oss-120b";
          name = "GPT-OSS 120B (High Thinking)";
          release_date = "2024-12-17";
          reasoning = true;
          limit = {
            context = 131072;
            output = 32768;
          };
          cost = {
            input = 0;
            output = 0;
            cache_read = 0;
          };
          modalities = {
            input = ["text"];
            output = ["text"];
          };
          options = {
            reasoningEffort = "high";
          };
        };
      };
    };
  };
}
