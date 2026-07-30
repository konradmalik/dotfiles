# The llama-swap endpoint contract, shared by the nixos module next to this file
# and by home/konrad/common/modules/opencode, so neither side repeats it.
#
# Only one model is resident at a time, so each has to fit the GTT ceiling the
# nixos module sets (48GB) on its own, together with its kv cache and compute
# buffers. Keep that in mind when raising a quant or a context size.
{
  port = 8080;

  # framework's tailscale ip. clients that do not run llama-swap themselves
  # reach it here; magicdns names do not resolve through nsswitch.
  remoteHost = "100.83.43.115";

  models = {
    "qwen3.6-35b-a3b" = {
      name = "Qwen3.6 35B A3B";
      description = "Q8_0, ~34GB";
      # exactly one model must carry this, clients pick it as their default
      default = true;
      hf = "ggml-org/Qwen3.6-35B-A3B-GGUF:Q8_0";
      contextSize = 65536;
      aliases = [ "qwen3.6" ];
    };

    "glm-4.7-flash" = {
      name = "GLM 4.7 Flash";
      description = "Q8_0, ~30GB";
      hf = "ggml-org/GLM-4.7-Flash-GGUF:Q8_0";
      contextSize = 65536;
    };

    # NOTE: the A4B mixture is deliberate over the dense gemma-4-31B. Only ~4B
    # params are active per token, so it generates roughly 8x faster on this
    # bandwidth-bound igpu, which matters far more than the dense model's edge
    # per token when an agent is driving it.
    "gemma-4-26b-a4b" = {
      name = "Gemma 4 26B A4B";
      description = "Q8_0, ~25GB";
      hf = "ggml-org/gemma-4-26B-A4B-it-GGUF:Q8_0";
      contextSize = 65536;
      aliases = [ "gemma-4" ];
    };
  };
}
