set_global_assignment -entity "pixelPLL" -library "lib_pixelPLL" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pixelPLL" -library "lib_pixelPLL" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "pixelPLL" -library "lib_pixelPLL" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pixelPLL" -name SPD_FILE [file join $::quartus(sip_path) "pixelPLL.spd"]

set_global_assignment -library "lib_pixelPLL" -name MISC_FILE [file join $::quartus(sip_path) "pixelPLL_sim/pixelPLL.vo"]
