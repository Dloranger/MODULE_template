###############################################################################
#  SVXlink TCL Module example Coded by Dan Loranger (KG7PAR)
#  
#  ADD YOUR MODULE DESCRIPTION HERE, BE VERBOSE.
#
#  comment - this is not intended to be functional but rather to provide the
#  basic framework
#
###############################################################################
#
# This is the namespace in which all functions and variables below will exist. 
# The name must match the configuration variable "NAME" in the [ModuleTcl] 
# section in the configuration file. The name may be changed but it must be 
# changed in both places.
#
###############################################################################
namespace eval Template {
	# Check if this module is loaded in the current logic core
	#
	if {![info exists CFG_ID]} {
		return;
	}
	#
	# Extract the module name from the current namespace
	#
	set module_name [namespace tail [namespace current]]
	
	
	# A convenience function for printing out info prefixed by the module name
	#
	#   msg - The message to print
	#
	proc printInfo {msg} {
		variable module_name
		puts "$module_name: $msg"
	}
	 
	proc activateInit {} {
		# do activities one time when the module is initialized
	}
	
	###########################################################################
	#
	#  Define your variables for the module here, note that TCL has a great
	#  feature of being able to use a loop to create indexed variables outside
	#  of an array for those of you less comfortable with arrays.
	#
	#  If a variable is used only in this module, and is not read from the 
	#  config file, just name it as you want.
	#
	#  If the variable is to be read from the config file <the correct way>
	#  then preface the code with "CFG_", this tells the svxlink framework it 
	#  needs to get this value from the modules config file
	#
	###########################################################################
	
	# Define a single uninitialized variable
	variable SingleVariable
	
	# Define a series of preinitialized variables with an indexed name
	#for {set i 0} {$i < $NumberOfIndexedVariables} {incr i} {
		# define place holder variables that is indexed to $i
	#	set CFG_variable1_$i
	#}
	
	###########################################################################	
	# Read in the values from the config file and set them in local variables
	########################################################################### 
	
	for {set i 0} {$i < $CFG_NumberOfIndexedVariables} {incr i} {
		# create the config variable, cant read it if it doesn't exist....
		variable CFG_variable1_$i
		variable variable1_contents
		
		# make sure there is a setting in the module config file
		if {[info exists CFG_variable1_$i]} {
			
			# read in the config varible data
			set variable1 "CFG_variable1_$i"
			#this is just a pointer to the actual config variable
			printInfo "variable1 - $variable1_$i"
			
			# expand the variable to actual contents, nice for file paths
			set variable1 [subst $$variable1_$i]
			printInfo "Variable1_contents - $variable1_contents"
			
			# read in the value from a file read 
			#set value [exec cat /var/log/log.txt]

		} else {
			printInfo "Config variable -variable1- is not defined"
		}
	}
	
	
	proc main_every_second {} {
		# do tasks on a 1 second cadence
	}
	
	
	#basic function to announce the variable on the TX
	#proc SomeFunction {varName VarValue} {
	#	if {$VarValue == 1} {
	#		playMsg "1"
	#		#printInfo "VarName has a value of 1 announced"
	#	} else {
	#		playMsg "0"
	#		#printInfo "VarName has a value of 0 announced"
	#	}
	#}
	
	
	# Executed when this module is being deactivated
	#
	proc deactivateCleanup {} {
		printInfo "Module deactivated"
	}
	
	# notify svxlink this function will run on the everySecond timer
	append func $module_name "::main_every_second";
	Logic::addSecondTickSubscriber $func;
	
	# end of namespace
}
#
# This file has not been truncated
#
