set_global_assignment -entity "PixelPll1080p60" -library "lib_PixelPll1080p60" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PixelPll1080p60" -library "lib_PixelPll1080p60" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "PixelPll1080p60" -library "lib_PixelPll1080p60" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PixelPll1080p60" -name SPD_FILE [file join $::quartus(sip_path) "PixelPll1080p60.spd"]

set_global_assignment -library "lib_PixelPll1080p60" -name MISC_FILE [file join $::quartus(sip_path) "PixelPll1080p60_sim/PixelPll1080p60.vo"]
