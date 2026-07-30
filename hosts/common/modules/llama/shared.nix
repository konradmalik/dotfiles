# The llama-swap endpoint contract, shared by the nixos module next to this file
# and by home/konrad/common/modules/opencode, so neither side repeats it.
#
# Quants are sized to fit the ~31GB the framework igpu can address, together
# with the context below. Keep them under that when editing.
{
  port = 8080;

  # framework's tailscale ip. clients that do not run llama-swap themselves
  # reach it here; magicdns names do not resolve through nsswitch.
  remoteHost = "100.83.43.115";

  models = {
    "qwen3.6-35b-a3b" = {
      name = "Qwen3.6 35B A3B";
      description = "Q4_K_M, ~19GB";
      # exactly one model must carry this, clients pick it as their default
      default = true;
      hf = "ggml-org/Qwen3.6-35B-A3B-GGUF:Q4_K_M";
      contextSize = 65536;
      # f16 would be 5GB of kv cache here, which is too close to the ceiling
      extraArgs = [
        "--cache-type-k q8_0"
        "--cache-type-v q8_0"
      ];
      aliases = [ "qwen3.6" ];
    };

    "glm-4.7-flash" = {
      name = "GLM 4.7 Flash";
      description = "Q4_K, ~17GB";
      hf = "ggml-org/GLM-4.7-Flash-GGUF:Q4_K";
      contextSize = 65536;
    };

    "gemma-4-26b-a4b" = {
      name = "Gemma 4 26B A4B";
      description = "Q4_0, ~14GB";
      hf = "ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_0";
      contextSize = 65536;
      aliases = [ "gemma-4" ];
    };
  };
}
