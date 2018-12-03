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
		
		 #define the array of commands and codes desired to activate them
		set InitialCode [subst $$CFG_InitialCode]
		global VariablesList

		list VariablesList {}
		# variableName DTMF Code Enable HelpfileName audioDirectory
   
		# Enabled options 1-enabled, 0-disabled, x-support not planned
		# All config variables should be represented, and will be status printed to the logs
		# so users can see what can be configured and what cant
		
		# variableName DTMF Code Enable HelpfileName audioDirectory
		lappend VariablesList 	Function1 	$InitialCode 1 Function1HelpFileName	Template
		set InitialCode [expr $InitialCode+1]
		lappend VariablesList 	Function2 	$InitialCode 1 Function2HelpFileName	Template
		set InitialCode [expr $InitialCode+1]
		lappend VariablesList 	Function3 	$InitialCode 1 Function3HelpFileName	Template
		
		global svxlinkCfgMenuLayer 
		set svxlinkCfgMenuLayer 0
		printInfo "Module activated"
		# Access Variables
		variable CFG_ACCESS_PIN
		variable CFG_ACCESS_ATTEMPTS_ALLOWED
		variable ACCESS_PIN_REQ
		variable ACCESS_GRANTED
		variable ACCESS_ATTEMPTS_ATTEMPTED
		if {[info exists CFG_ACCESS_PIN]} { 
			set ACCESS_PIN_REQ 1
			if {![info exists CFG_ACCESS_ATTEMPTS_ALLOWED]} { set CFG_ACCESS_ATTEMPTS_ALLOWED 3 }
		} else {
			set ACCESS_PIN_REQ 0
		}
		set ACCESS_GRANTED 0
		set ACCESS_ATTEMPTS_ATTEMPTED 0 

		printInfo "Module Activated"
		if {$ACCESS_PIN_REQ == "1"} {
			printInfo "--- PLEASE ENTER YOUR PIN FOLLOWED BY THE POUND SIGN ---"
			playMsg "access_enter_pin";
		} else {
			# No Pin Required but this is the first time the module has been run so play prompt
			#playMsg "enter_command";
		}
  
		# Iterate through the list, only play the ones that are available
    
		foreach {name code enable HelpFileName FolderName} $VariablesList {
	  
			if {$enable == 1} {
				##  module is enabled, announce name and code assigned
				playCodeName $code "$name"
				printInfo "$name:$code:Enabled"
			} elseif {$enable == 0} {
				printInfo "$name:$code:Disabled"
			} else {
				printInfo "$name:$code:NotPlanned"
			}
		}
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
	
	printInfo "Number of indexed variables - $CFG_NumberOfIndexedVariables"

	for {set i 0} {$i < $CFG_NumberOfIndexedVariables} {incr i} {
		# create the config variable, cant read it if it doesn't exist....
		variable CFG_variable1_$i
		variable variable1_contents
		
		# make sure there is a setting in the module config file
		if {[info exists CFG_variable1_$i]} {
			
			# read in the config varible data
			set variable1 "CFG_variable1_$i"
			#this is just a pointer to the actual config variable
			printInfo "variable1 - $variable1"
			
			# expand the variable to actual contents, nice for file paths
			set variable1_contents [subst $$variable1]
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
	
	proc dtmfCmdReceived {cmd} {
		global Channel
		global FunctionName
		global FunctionHelpFile
		global FunctionHelpFileDir
		global MenuLayer
		global VariablesList
		printInfo "DTMF command received: $cmd"
		## MODULE GLOBAL COMMANDS 
		if {$cmd == "0"} {
			#play the help information, including module names
			playMsg "config_help"
  
		if {$MenuLayer == 0} {
			set FunctionName ""
			set ModuleFound 0
			#Get the module number from user
			foreach {name code enable helpFile helpFileDir} $variablesList {
				printInfo "CODE:$code NAME:$name ENABLED:$enable"
				if {$cmd == $code} {
					# cmd is recognized, make sure its enabled
					if {$enable == "1"} {
						# selection is enabled, advance the menu, request channel
						set FunctionName $name
						set FunctionHelpFile $helpFile
						set FunctionHelpFileDir $helpFileDir
						set MenuLayer 1
						set ModuleFound 1
						break
					} else {
						playMsg "invalid_selection"
					break
					}
				}
			}
			if {$ModuleFound == 0} {
				playMsg "invalid_configuration_selection"
				return
			}
		}
		
		if {$MenuLayer == 1} {
			set $MenuLayer 2
		}
		
		if {$MenuLayer == 2} {
			set $MenuLayer 0
		}
	}
  ## we have received a command that should correlate with a Channel Number 
  if {$svxlinkCfgMenuLayer == 1} {
	set svxlinkCfgChannel $cmd
    set svxlinkCfgMenuLayer 2
	return
  }
  
  # we know the function,and channel, now to announce the help for the module
  if {$svxlinkCfgMenuLayer == 2} {
     # old syntax is 'playMsg "filename"'
	 playMsg "$SvxlinkCfgFunctionHelpFile"
	 # new syntax is 'playMsg "directory" "filename"' once it gets enabled
	 # playMsg "SvxlinkCfgFunctionHelpFileDir" "$SvxlinkCfgFunctionHelpFile"
	 set svxlinkCfgMenuLayer 3
  }
  
  # We have the command, channel and now expect the user to input the setting.
  #
  # initially the setting at each module will not be validated, there may be 
  # more work for this at some later point, but initially this would balloon 
  # the scope of the effort before the module has been reviewed for initial
  # acceptance.
  #
  # Also, be nice to those who follow, keep these entries alphabetized
  if {$svxlinkCfgMenuLayer == 3} {
    switch -exact -- $SvxlinkCfgFunctionName {
	  # A
	  # B
	  # C
	  # D
	  # E
	  # F
	  Function1 {
	    #do something related to function number 1	  
		}
	  Function2 {
	    #do something related to function number 2	  
		}
	  # G
	  # H
	  # I
	  # J
	  # K
	  # L
	  # M
	  # N
	  # O 
	  # P
	  # R
	  # S
	  # T
	  # U
	  # V
	  # W
	  # X
	  # Y
	  # Z
	  default {
	     printInfo "default state encountered"
	  }
    }
  }
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
