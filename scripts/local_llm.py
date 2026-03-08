"""local_llm.py — Shared client for local LLM backends (Ollama + Foundry).

Provides a unified interface over the OpenAI-compatible /v1/chat/completions
endpoint that both Ollama and Foundry Local expose.

Usage:
    from local_llm import complete, is_available, suggest_model

    if is_available():
        result = complete(
            messages=[
                {"role": "system", "content": "You classify documents."},
                {"role": "user", "content": file_content},
            ],
            model="qwen2.5:3b",
        )
        print(result["response"])

Environment variables:
    OLLAMA_URL      — Ollama base URL (default: http://localhost:11434)
    OLLAMA_MODEL    — Default model for Ollama (default: qwen2.5:3b)
    FOUNDRY_URL     — Foundry Local base URL (default: http://127.0.0.1:56805)
    LLM_BACKEND     — Force a specific backend: "ollama" or "foundry"
    LLM_DISABLED    — Set to "1" to disable all local LLM calls
"""

import json
import os
import urllib.request
import urllib.error
from typing import Any


# ── Configuration ─────────────────────────────────────────────────

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.environ.get("OLLAMA_MODEL", "qwen2.5:3b")
FOUNDRY_URL = os.environ.get("FOUNDRY_URL", "http://127.0.0.1:56805")
FORCED_BACKEND = os.environ.get("LLM_BACKEND", "").lower()
LLM_DISABLED = os.environ.get("LLM_DISABLED", "") == "1"

# Probe timeout for backend discovery (seconds)
DISCOVERY_TIMEOUT = 2.0


# ── Backend state (cached after first discovery) ──────────────────

_discovery_done = False
_ollama_available = False
_ollama_models: list[str] = []
_foundry_available = False
_foundry_models: list[str] = []


def _probe_json(url: str, timeout: float = DISCOVERY_TIMEOUT) -> Any | None:
    """GET a URL and return parsed JSON, or None on failure."""
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read())
    except Exception:
        return None


def _discover() -> None:
    """Probe backends once and cache the results."""
    global _discovery_done, _ollama_available, _ollama_models
    global _foundry_available, _foundry_models

    if _discovery_done:
        return
    _discovery_done = True

    if LLM_DISABLED:
        return

    # Probe Ollama
    if FORCED_BACKEND in ("", "ollama"):
        data = _probe_json(f"{OLLAMA_URL}/api/tags")
        if data and "models" in data:
            _ollama_available = True
            _ollama_models = [m["name"] for m in data["models"]]

    # Probe Foundry
    if FORCED_BACKEND in ("", "foundry"):
        data = _probe_json(f"{FOUNDRY_URL}/v1/models")
        if data:
            models = data.get("data", [])
            if isinstance(models, list) and models:
                _foundry_available = True
                _foundry_models = [
                    m["id"] if isinstance(m, dict) else str(m)
                    for m in models
                ]
            # Also try simpler endpoint
            if not _foundry_models:
                simple = _probe_json(f"{FOUNDRY_URL}/openai/models")
                if isinstance(simple, list) and simple:
                    _foundry_available = True
                    _foundry_models = [str(m) for m in simple]


# ── Public API ────────────────────────────────────────────────────

def is_available() -> bool:
    """True if at least one LLM backend is reachable."""
    _discover()
    return _ollama_available or _foundry_available


def available_backends() -> list[str]:
    """Return list of available backend names."""
    _discover()
    result = []
    if _ollama_available:
        result.append("ollama")
    if _foundry_available:
        result.append("foundry")
    return result


def available_models() -> dict[str, list[str]]:
    """Return {backend_name: [model_names]} for all available backends."""
    _discover()
    result = {}
    if _ollama_available:
        result["ollama"] = list(_ollama_models)
    if _foundry_available:
        result["foundry"] = list(_foundry_models)
    return result


def suggest_model(task: str = "classification") -> str:
    """Suggest the best available model for a task type.

    Task types:
        "classification" — simple labeling, scoring, tagging (fast, small ok)
        "generation"     — producing prose, definitions, summaries (quality matters)
        "extraction"     — structured output from text (balance of speed and quality)

    Prefers NPU (Foundry) models when available for speed and power efficiency.
    Falls back to Ollama models ordered by suitability for the task.
    """
    _discover()

    # Foundry models are always preferred when available — NPU is faster
    # and frees the CPU for other work
    if _foundry_available and _foundry_models:
        return _foundry_models[0]

    # Ollama fallback: pick by task type
    # Classification: small and fast is fine
    # Generation: prefer larger models for quality
    # Extraction: middle ground
    preference_order = {
        "classification": [
            "qwen2.5:3b", "qwen3:1.7b", "phi4-mini", "llama3.2:3b",
            "gemma3:4b", "qwen3:4b", "qwen2.5:7b",
        ],
        "generation": [
            "qwen2.5:7b", "mistral-7b", "deepseek-r1-7b", "qwen3:8b",
            "gemma3:12b", "gemma3:4b", "qwen3:4b", "qwen2.5:3b", "phi4-mini",
        ],
        "extraction": [
            "qwen2.5:7b", "mistral-7b", "qwen2.5:3b", "qwen3:4b",
            "gemma3:4b", "phi4-mini", "llama3.2:3b",
        ],
        "reasoning": [
            "deepseek-r1-7b", "qwen2.5:7b", "mistral-7b", "gemma3:12b",
            "qwen3:8b", "phi4-mini",
        ],
        # long-context: prefer models with large context windows (128k+)
        # for tasks like summarizing large files before enrichment.
        "long-context": [
            "phi-3-mini-128k", "qwen2.5:7b", "qwen2.5:3b", "phi4-mini",
        ],
    }

    order = preference_order.get(task, preference_order["classification"])
    if _ollama_available:
        for model in order:
            # Check with and without :latest tag
            if model in _ollama_models:
                return model
            if f"{model}:latest" in _ollama_models:
                return f"{model}:latest"
        # Nothing matched preference list — return first available
        if _ollama_models:
            return _ollama_models[0]

    return OLLAMA_MODEL  # fallback to configured default


def _find_foundry_model(model: str) -> str | None:
    """Check if a model (by Ollama name or Foundry name) is on Foundry.

    Foundry model names look like 'phi-4-mini-instruct-vitis-npu:2'.
    We match by checking if the short name appears as a prefix.
    """
    if not _foundry_available:
        return None

    # Normalize: ollama uses 'phi4-mini', foundry uses 'phi-4-mini-instruct-...'
    # Try exact match first
    if model in _foundry_models:
        return model

    # Try prefix matching: 'phi-4-mini' matches 'phi-4-mini-instruct-vitis-npu:2'
    # Also handle ollama names like 'phi4-mini' → 'phi-4-mini'
    normalized = model.split(":")[0]  # strip :tag
    for fm in _foundry_models:
        fm_base = fm.split("-instruct")[0].split("-generic")[0]
        if normalized == fm_base:
            return fm
        # Handle ollama→foundry name differences (phi4-mini → phi-4-mini)
        if normalized.replace("-", "") == fm_base.replace("-", ""):
            return fm

    return None


def _call_openai_compatible(
    base_url: str,
    messages: list[dict],
    model: str,
    temperature: float,
    max_tokens: int,
    timeout: int,
) -> dict:
    """Call an OpenAI-compatible /v1/chat/completions endpoint."""
    payload = json.dumps({
        "model": model,
        "messages": messages,
        "temperature": temperature,
        "max_tokens": max_tokens,
        "stream": False,
    }).encode()

    req = urllib.request.Request(
        f"{base_url}/v1/chat/completions",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    with urllib.request.urlopen(req, timeout=timeout) as resp:
        body = json.loads(resp.read())

    # Extract the response text from the OpenAI-compatible format
    choices = body.get("choices", [])
    if choices:
        # Handle both 'message' and 'delta' (Foundry uses both)
        choice = choices[0]
        msg = choice.get("message", choice.get("delta", {}))
        return msg.get("content", "")
    return ""


def complete(
    messages: list[dict],
    model: str = "",
    temperature: float = 0.3,
    max_tokens: int = 1024,
    timeout: int = 120,
) -> dict:
    """Send a chat completion request to the best available backend.

    Args:
        messages: OpenAI-format messages [{role, content}, ...]
        model: Model name (Ollama convention). Empty = use default.
        temperature: Sampling temperature (default 0.3 for determinism).
        max_tokens: Maximum tokens to generate.
        timeout: Request timeout in seconds.

    Returns:
        {
            "response": str,     # The generated text
            "model": str,        # Model name that was used
            "backend": str,      # "ollama" or "foundry"
            "error": str | None  # Error message, or None on success
        }
    """
    _discover()

    if LLM_DISABLED:
        return {
            "response": "",
            "model": model,
            "backend": "none",
            "error": "Local LLM disabled (LLM_DISABLED=1)",
        }

    if not is_available():
        return {
            "response": "",
            "model": model,
            "backend": "none",
            "error": "No local LLM backend available. Install Ollama or Foundry Local.",
        }

    model = model or OLLAMA_MODEL

    # Try Foundry first if the model is available there (NPU = faster, lower power)
    foundry_model = _find_foundry_model(model)
    if foundry_model and (FORCED_BACKEND in ("", "foundry")):
        try:
            text = _call_openai_compatible(
                FOUNDRY_URL, messages, foundry_model,
                temperature, max_tokens, timeout,
            )
            return {
                "response": text,
                "model": foundry_model,
                "backend": "foundry",
                "error": None,
            }
        except Exception as e:
            # Foundry failed — fall through to Ollama
            if FORCED_BACKEND == "foundry":
                return {
                    "response": "",
                    "model": foundry_model,
                    "backend": "foundry",
                    "error": f"Foundry error: {e}",
                }

    # Try Ollama
    if _ollama_available and (FORCED_BACKEND in ("", "ollama")):
        try:
            text = _call_openai_compatible(
                OLLAMA_URL, messages, model,
                temperature, max_tokens, timeout,
            )
            return {
                "response": text,
                "model": model,
                "backend": "ollama",
                "error": None,
            }
        except Exception as e:
            return {
                "response": "",
                "model": model,
                "backend": "ollama",
                "error": f"Ollama error: {e}",
            }

    return {
        "response": "",
        "model": model,
        "backend": "none",
        "error": f"Model '{model}' not available on any backend",
    }
