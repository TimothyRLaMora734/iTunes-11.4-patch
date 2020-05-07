#!/bin/bash

parameters="${1}${2}${3}${4}${5}${6}${7}${8}${9}"

Escape_Variables()
{
	text_progress="\033[38;5;113m"
	text_success="\033[38;5;113m"
	text_warning="\033[38;5;221m"
	text_error="\033[38;5;203m"
	text_message="\033[38;5;75m"

	text_bold="\033[1m"
	text_faint="\033[2m"
	text_italic="\033[3m"
	text_underline="\033[4m"

	erase_style="\033[0m"
	erase_line="\033[0K"

	move_up="\033[1A"
	move_down="\033[1B"
	move_foward="\033[1C"
	move_backward="\033[1D"
}

Parameter_Variables()
{
	if [[ $parameters == *"-v"* || $parameters == *"-verbose"* ]]; then
		verbose="1"
		set -x
	fi
}

Path_Variables()
{
	script_path="${0}"
	directory_path="${0%/*}"

	resources_path="$directory_path/resources"
}

Input_Off()
{
	stty -echo
}

Input_On()
{
	stty echo
}

Output_Off()
{
	if [[ $verbose == "1" ]]; then
		"$@"
	else
		"$@" &>/dev/null
	fi
}

Check_Environment()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system environment."${erase_style}

	if [ -d /Install\ *.app ]; then
		environment="installer"
	fi

	if [ ! -d /Install\ *.app ]; then
		environment="system"
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked system environment."${erase_style}
}

Check_Resources()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for resources."${erase_style}
	if [[ -d "$resources_path" ]]; then
		resources_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Resources check passed."${erase_style}
	fi
	if [[ ! -d "$resources_path" ]]; then
		resources_check="failed"
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Resources check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with the required resources."${erase_style}
		Input_On
		exit
	fi
}

Check_Resources()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for resources."${erase_style}
	if [[ -d "$resources_path" ]]; then
		resources_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Resources check passed."${erase_style}
	fi
	if [[ ! -d "$resources_path" ]]; then
		resources_check="failed"
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Resources check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with the required resources."${erase_style}
		Input_On
		exit
	fi
}

Check_Codesign()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for Xcode command line tools."${erase_style}
	if [[ "$(which codesign)" == "/usr/bin/codesign" ]]; then
		codesign_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Xcode command line tools check passed."${erase_style}
	fi
	if [[ ! "$(which codesign)" == "/usr/bin/codesign" ]]; then
		codesign_check="failed"
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Xcode command line tools check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with the required Xcode command line tools installed."${erase_style}
		Input_On
		exit
	fi
}

Input_Folder()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What save folder would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input a save folder path."${erase_style}

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " save_folder
	Input_Off
}

Check_Write()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for write permissions on save folder."${erase_style}

	if [[ -w "$save_folder" ]]; then
		write_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Write permissions check passed."${erase_style}
	else
		root_check="failed"
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Write permissions check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with a writable save folder."${erase_style}

		Input_On
		exit
	fi
}

Input_Package()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What iTunes package would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an iTunes package path."${erase_style}
	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " package_path
	Input_Off
}

Patch_iTunes()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Expanding iTunes packages."${erase_style}
	mkdir /tmp/iTunes\ 11.4-patch

	pkgutil --expand "$package_path" /tmp/iTunes\ 11.4-patch/Install\ iTunes
	Output_Off tar -xvf /tmp/iTunes\ 11.4-patch/Install\ iTunes/iTunesX.pkg/Payload -C /tmp/iTunes\ 11.4-patch
	Output_Off tar -xvf /tmp/iTunes\ 11.4-patch/Install\ iTunes/CoreADI.pkg/Payload -C /tmp/iTunes\ 11.4-patch
	Output_Off tar -xvf /tmp/iTunes\ 11.4-patch/Install\ iTunes/CoreFP.pkg/Payload -C /tmp/iTunes\ 11.4-patch
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Expanded iTunes packages."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching iTunes version number."${erase_style}
	sed -i '' 's/<string>11.4<\/string>/<string>13.4<\/string>/' /tmp/iTunes\ 11.4-patch/Applications/iTunes.app/Contents/Info.plist
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched iTunes version number."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching iTunes frameworks."${erase_style}
	cp -R /tmp/iTunes\ 11.4-patch/System/Library/PrivateFrameworks/CoreADI.framework /tmp/iTunes\ 11.4-patch/Applications/iTunes.app/Contents/Frameworks
	cp -R /tmp/iTunes\ 11.4-patch/System/Library/PrivateFrameworks/CoreFP.framework /tmp/iTunes\ 11.4-patch/Applications/iTunes.app/Contents/Frameworks

	chmod +x "$resources_path"/insert_dylib
	Output_Off "$resources_path"/insert_dylib @executable_path/../Frameworks/CoreADI.framework/Versions/A/CoreADI /tmp/iTunes\ 11.4-patch/Applications/iTunes.app/Contents/MacOS/iTunes --inplace --no-strip-codesig
	Output_Off "$resources_path"/insert_dylib @executable_path/../Frameworks/CoreFP.framework/Versions/A/CoreFP /tmp/iTunes\ 11.4-patch/Applications/iTunes.app/Contents/MacOS/iTunes --inplace --no-strip-codesig
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched iTunes frameworks."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Preparing iTunes application."${erase_style}
	Output_Off codesign -f -s - /tmp/iTunes\ 11.4-patch/Applications/iTunes.app
	mv /tmp/iTunes\ 11.4-patch/Applications/iTunes.app "$save_folder"/iTunes\ 11.4.app
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Prepared iTunes iTunes application."${erase_style}
}

End()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing temporary files."${erase_style}
	Output_Off rm -R /tmp/iTunes\ 11.4-patch
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed temporary files."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Thank you for using the iTunes 11.4 patch."${erase_style}
	Input_On
	exit
}

Input_Off
Escape_Variables
Parameter_Variables
Path_Variables
Check_Environment
Check_Resources
Check_Codesign
Input_Folder
Check_Write
Input_Package
Patch_iTunes
End