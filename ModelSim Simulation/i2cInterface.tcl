#Script for simulating the i2cInterface file
#Copyright (c) 2018 Alexander Knapik, Keane-Gene Yew
#under the GNU General Public License v3.0 or any other later version
#27.05.2018


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

	add wave refClock
	add wave stateClock
	add wave dataIn
	add wave i2cGo 
	add wave endOK 
	add wave ackOK 
	add wave i2cSDAOut
	add wave SDAOut
	add wave sda
	add wave scl
	add wave byteCounter
	add wave bitCounter
	add wave dataCounter
	add wave currentState
	add wave nextState

	# Set the radix of the buses.
	property wave -radix hexadecimal *
	
	#force -freeze dataIn 10100011010101000111110101010
	force -freeze dataIn 11100100100000100010000
	
	# Generate a clock to push the data though.
	# Generate the system clock that will be used for
	# the simulation.
	force -deposit refClock 1 0, 0 {100ns} -repeat 200ns

	run 2us
	
	# Start i2c
	force -freeze i2cGo 1
	run 90us
	
	#force -freeze i2cSDAOut 1
	
	#Set so i2c won't continue after initial data.
	#force -freeze i2cGo 0
	
	run 850us
	
	force -freeze ackOK 1
	
	#force -freeze i2cSDAOut 1
	#run 20us
	
	#force -freeze sda z
	
	#force -freeze sda 0
	run 2ms
	
	force -freeze dataIn 11100101001100000000011
	
	run 2.5ms
	
	force -freeze i2cGo 0
	
	run 1ms
	
}