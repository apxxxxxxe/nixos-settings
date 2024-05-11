{ pkgs, ... }:

let
  json = pkgs.formats.json { };
  rnnoise_config = {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";

          "filter.graph" = {
            nodes = [
              # {
              #   type = "lv2";
              #   name = "noise-repellent";
              #   plugin = "https://github.com/lucianodato/noise-repellent#new";
              # }
              {
                type = "ladspa";
                name = "rnnoise";
                plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                label = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 50.0;
                  "VAD Grace Period (ms)" = 150;
                  "Retroactive VAD Grace (ms)" = 0;
                };
              }
            ];
          };

          "capture.props" = {
            "node.name" = "capture.rnnoise_source";
            "node.passive" = true;
            "audio.rate" = 48000;
          };

          "playback.props" = {
            "node.name" = "rnnoise_source";
            "media.class" = "Audio/Source";
            "audio.rate" = 48000;
          };
        };
      }
      {
        name = "libpipewire-module-loopback";
        args = {
          "node.description" = "CM106 Stereo Pair 2";
          #target.delay.sec = 1.5;
          "capture.props" = {
              "node.name" = "CM106_stereo_pair_2";
              "media.class" = "Audio/Sink";
              "audio.position" = "[ FL FR ]";
          };
          "playback.props" = {
              "node.name" = "playback.CM106_stereo_pair_2";
              "audio.position" = "[ RL RR ]";
              "target.object" = "rnnoise";
              "node.dont-reconnect" = true;
              "stream.dont-remix" = true;
              "node.passive" = true;
          };
        };
      }
    ];
  };
in {
  # environment.variables."LV2_PATH" = "${pkgs.noise-repellent}/lib/lv2";
  environment.etc."pipewire/pipewire.conf.d/99-input-denoising.conf" = {
    source = json.generate "source-rnnoise.conf" rnnoise_config;
  };
}
