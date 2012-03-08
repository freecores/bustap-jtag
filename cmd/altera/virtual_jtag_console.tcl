proc reset_fifo {{jtag_index_0 0}} {
	device_lock -timeout 10000
	device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 2 -no_captured_ir_value 
	device_virtual_dr_shift -instance_index $jtag_index_0  -length 32 -dr_value 00000000 -value_in_hex -no_captured_dr_value 
	device_unlock
	return 0
}

proc query_usedw {{jtag_index_0 0}} {
	global fifoUsedw
	device_lock -timeout 10000
	device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 1 -no_captured_ir_value
	set usedw [device_virtual_dr_shift -instance_index $jtag_index_0 -length 9 -value_in_hex]
	device_unlock
		set tmp 0x
		append tmp $usedw
		set usedw [format "%i" $tmp]
	set fifoUsedw $usedw
	return $usedw
}

proc read_fifo {{jtag_index_0 0}} {
	device_lock -timeout 10000
	device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 1 -no_captured_ir_value
	device_virtual_ir_shift -instance_index $jtag_index_0 -ir_value 3 -no_captured_ir_value
	set fifo_data [device_virtual_dr_shift -instance_index $jtag_index_0 -length 48 -value_in_hex]
	device_unlock
	return $fifo_data
}

proc config_addr {{jtag_index_1 1} {mask_1 100000000}} {
	device_lock -timeout 10000
	device_virtual_ir_shift -instance_index $jtag_index_1 -ir_value 1 -no_captured_ir_value
	set addr_mask [device_virtual_dr_shift -instance_index $jtag_index_1 -dr_value $mask_1 -length 36 -value_in_hex]
	device_unlock
	return $addr_mask
}

proc config_trig {{jtag_index_2 2} {trig_1 0000000000000}} {
	device_lock -timeout 10000
	device_virtual_ir_shift -instance_index $jtag_index_2 -ir_value 1 -no_captured_ir_value
	set addr_trig [device_virtual_dr_shift -instance_index $jtag_index_2 -dr_value $trig_1 -length 50 -value_in_hex]
	device_unlock
	return $addr_trig
} 

proc open_jtag_device {{test_cable "USB-Blaster [USB-0]"} {test_device "@2: EP2SGX90 (0x020E30DD)"}} {
	open_device -hardware_name $test_cable -device_name $test_device
	# Retrieve device id code.
	device_lock -timeout 10000
	device_ir_shift -ir_value 6 -no_captured_ir_value
	set idcode "0x[device_dr_shift -length 32 -value_in_hex]"
	device_unlock
	return $idcode
}

proc close_jtag_device {} {
	close_device
}

proc scan_chain {} {
	global log
	$log insert end "JTAG Chain Scanning report:\n"
	$log insert end "****************************************\n"
	set blaster_cables [get_hardware_names]
	set cable_num 0
	foreach blaster_cable $blaster_cables {
		incr cable_num
		$log insert end "@$cable_num: $blaster_cable\n"
	}
	$log insert end "\n****************************************\n"
	global device_list
	set device_list ""
	foreach blaster_cable $blaster_cables {
		$log insert end "$blaster_cable:\n"
		lappend device_list $blaster_cable
		if [catch {get_device_names -hardware_name $blaster_cable} error_msg] {
			$log insert end $error_msg
			lappend device_list $error_msg
		} else {
			foreach test_device [get_device_names -hardware_name $blaster_cable] {
				$log insert end "$test_device\n"
			}
			lappend device_list [get_device_names -hardware_name $blaster_cable]
		}
	}
}

proc select_device {{cableNum 1} {deviceNum 1}} {
	global log
	global device_list
	$log insert end "\n****************************************\n"
	set test_cable [lindex $device_list [expr 2*$cableNum-2]]
	$log insert end "Selected Cable : $test_cable\n"
	set test_device [lindex [lindex $device_list [expr 2*$cableNum-1]] [expr $deviceNum-1]]
	$log insert end "Selected Device: $test_device\n"
	set jtagIdCode [open_jtag_device $test_cable $test_device]
	$log insert end "Device ID code : $jtagIdCode\n"
	updateAddrConfig
	reset_fifo 0
	query_usedw 0
}

proc inclusiveAddrConfig {} {
	global address_span1
	global address_span2
	global address_span3
	global address_span4
	global address_span5
	global address_span6
	global address_span7
	global address_span8
	for {set i 1} {$i<=8} {incr i} {
		set mask [format "%1X" [expr $i-1]]
		append mask [set address_span$i]
		config_addr 1 $mask
	}
}

proc exclusiveAddrConfig {} {
	global address_span9
	global address_span10
	global address_span11
	global address_span12
	global address_span13
	global address_span14
	global address_span15
	global address_span16
	for {set i 9} {$i<=16} {incr i} {
		set mask [format "%1X" [expr $i-1]]
		append mask [set address_span$i]
		config_addr 1 $mask
	}
}

proc updateAddrConfig {} {
	global log
	global address_span1
	global address_span2
	global address_span3
	global address_span4
	global address_span5
	global address_span6
	global address_span7
	global address_span8
	global address_span9
	global address_span10
	global address_span11
	global address_span12
	global address_span13
	global address_span14
	global address_span15
	global address_span16
	for {set i 1} {$i<=8} {incr i} {
		set address_span$i ffff0000
	}
	for {set i 9} {$i<=16} {incr i} {
		set address_span$i 00000000
	}
}

proc enableTrigger {} {
	global triggerAddr
	global triggerData
	# enable but stop triggering
	set triggerValue 2
	append triggerValue $triggerAddr
	append triggerValue $triggerData
	config_trig 2 $triggerValue
}

proc disableTrigger {} {
	global triggerAddr
	global triggerData
	# disable and stop triggering
	set triggerValue 0
	append triggerValue $triggerAddr
	append triggerValue $triggerData
	config_trig 2 $triggerValue
}

proc startTrigger {} {
	global triggerAddr
	global triggerData
	# enable and start triggering
	set triggerValue 3
	append triggerValue $triggerAddr
	append triggerValue $triggerData
	config_trig 2 $triggerValue
}

proc stopTrigger {} {
	global triggerAddr
	global triggerData
	# enable and stop triggering
	set triggerValue 2
	append triggerValue $triggerAddr
	append triggerValue $triggerData
	config_trig 2 $triggerValue
}

proc reset_fifo_ptr {} {
	reset_fifo 0
	query_usedw 0
}

proc query_fifo_usedw {} {
	query_usedw 0
}

proc read_fifo_content {} {
	global log
	global fifoUsedw
	$log insert end "\n****************************************\n"
	for {set i 0} {$i<$fifoUsedw} {incr i} {
		set fifoContent [read_fifo 0]
		$log insert end "wr [string range $fifoContent 0 3] [string range $fifoContent 4 11]\n"
	}
	query_usedw 0
}

proc clear_log {} {
	global log
	$log delete insert end
}

proc quit {} {
	global exit_console
	destroy .console
	set exit_console 1
}

# set the QuartusII special Tk command
init_tk
set exit_console 0

# set the main window
toplevel .console
wm title .console "Virtual JTAG: uP transaction monitor"
pack propagate .console true

# set the JTAG utility
frame .console.fig -bg white
pack .console.fig -expand true -fill both

button .console.fig.scan -text {Scan JTAG Chain} -command {scan_chain}
button .console.fig.select -text {Select JTAG Device :} -command {select_device $cableNum $deviceNum}
button .console.fig.deselect -text {DeSelect JTAG Device} -command {close_jtag_device}
label .console.fig.cable -text {Cable No.}
label .console.fig.devic -text {Device No.}
entry .console.fig.cable_num -textvariable cableNum -width 2
entry .console.fig.devic_num -textvariable deviceNum -width 2
pack 	.console.fig.scan .console.fig.select \
	.console.fig.cable .console.fig.cable_num \
       	.console.fig.devic .console.fig.devic_num \
	.console.fig.deselect \
	-side left -ipadx 10

# set the inclusive address entries
frame .console.f1 -relief groove -borderwidth 5
pack .console.f1
entry .console.f1.address_span1 -textvariable address_span1 -width 5
entry .console.f1.address_span2 -textvariable address_span2 -width 5
entry .console.f1.address_span3 -textvariable address_span3 -width 5
entry .console.f1.address_span4 -textvariable address_span4 -width 5
entry .console.f1.address_span5 -textvariable address_span5 -width 5
entry .console.f1.address_span6 -textvariable address_span6 -width 5
entry .console.f1.address_span7 -textvariable address_span7 -width 5
entry .console.f1.address_span8 -textvariable address_span8 -width 5
button .console.f1.config -text {Included Address Filter} -command {inclusiveAddrConfig}
pack .console.f1.address_span1 .console.f1.address_span2 .console.f1.address_span3 .console.f1.address_span4 \
     .console.f1.address_span5 .console.f1.address_span6 .console.f1.address_span7 .console.f1.address_span8 \
     .console.f1.config -side left -ipadx 10

# set the exclusive address entries
frame .console.f2 -relief groove -borderwidth 5
pack .console.f2
entry .console.f2.address_span9  -textvariable address_span9  -width 5
entry .console.f2.address_span10 -textvariable address_span10 -width 5
entry .console.f2.address_span11 -textvariable address_span11 -width 5
entry .console.f2.address_span12 -textvariable address_span12 -width 5
entry .console.f2.address_span13 -textvariable address_span13 -width 5
entry .console.f2.address_span14 -textvariable address_span14 -width 5
entry .console.f2.address_span15 -textvariable address_span15 -width 5
entry .console.f2.address_span16 -textvariable address_span16 -width 5
button .console.f2.config -text {Excluded Address Filter} -command {exclusiveAddrConfig}
pack .console.f2.address_span9  .console.f2.address_span10 .console.f2.address_span11 .console.f2.address_span12 \
     .console.f2.address_span13 .console.f2.address_span14 .console.f2.address_span15 .console.f2.address_span16 \
     .console.f2.config -side left -ipadx 10

# set the transaction trigger controls
frame .console.f3 -relief groove -borderwidth 5
pack .console.f3
button .console.f3.enabletrig -text {Enable Trigger} -command {enableTrigger}
button .console.f3.disabletrig -text {Disable Trigger} -command {disableTrigger}
button .console.f3.starttrig -text {Start Trigger} -command {startTrigger}
button .console.f3.stoptrig -text {Stop Trigger} -command {stopTrigger}
entry .console.f3.trigvalue_addr -textvar triggerAddr -width 2
set triggerAddr ffff
entry .console.f3.trigvalue_data -textvar triggerData -width 6
set triggerData a5a5a5a5
label .console.f3.trigaddr -text {@Address :}
label .console.f3.trigdata -text {@Data :}
pack .console.f3.enabletrig .console.f3.starttrig .console.f3.trigaddr .console.f3.trigvalue_addr \
     .console.f3.trigdata .console.f3.trigvalue_data .console.f3.stoptrig .console.f3.disabletrig \
     -side left -ipadx 8

# set the control buttons
frame .console.f0 -relief groove -borderwidth 5
pack .console.f0
button .console.f0.reset -text {Reset FIFO} -command {reset_fifo_ptr}
button .console.f0.loop -text {Query Used Word} -command {query_fifo_usedw}
label .console.f0.usedw  -textvariable fifoUsedw -relief sunken
button .console.f0.read	-text {Read FIFO} -command {read_fifo_content}
button .console.f0.clear -text {Clear Log} -command {clear_log}
button .console.f0.quit -text {Quit} -command {quit}
pack .console.f0.reset .console.f0.loop .console.f0.usedw .console.f0.read .console.f0.clear .console.f0.quit \
     -side left -ipadx 10

# set the log window
frame .console.log -relief groove -borderwidth 5
set log [text .console.log.text -width 80 -height 40 \
	-borderwidth 2 -relief sunken -setgrid true \
	-yscrollcommand {.console.log.scroll set}]
scrollbar .console.log.scroll -command {.console.log.text yview}
pack .console.log.scroll -side right -fill y
pack .console.log.text -side left -fill both -expand true
pack .console.log -side top -fill both -expand true

# make the program wait for exit signal
vwait exit_console

