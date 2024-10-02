table.insert(alsa_monitor.rules, {
    matches = {
        {
            { "application.process.binary", "equals", "spotify_player" }
        },
    },
    apply_properties = {
      " ["target.node"] = "alsa_output.platform-snd_aloop.0.analog-stereo",
        ["target.node"] = "input.loop0",
    },
})

