#Script for simulating the top level entity
#Copyright (c) 2018 Alexander Knapik, Keane-Gene Yew 
#under the GNU General Public License v3.0 or any other later version
#28.05.2018


#   This file is part of FPGA-HDMI-Image-Overlay. 
#	https://github.com/AlexanderKnapik/FPGA-HDMI-Image-Overlay
#
#   FPGA-HDMI-Image-Overlay is free software: you can redistribute it and/or 
#	modify it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   FPGA-HDMI-Image-Overlay is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with FPGA-HDMI-Image-Overlay.
#	
#	If not, see <http://www.gnu.org/licenses/>.


proc runSim {} {

	# Clear the current simulation and add in all waveforms.
	restart -force -nowave
	add wave *
	
	# Set the radix of the buses.
	property wave -radix hexadecimal *
	
	#Generate a 50MHz reference clock
	force -deposit clock_50 1 0, 0 {10ns} -repeat 20ns
	
	run 50ms
	
}

