#!/bin/bash

# Check package
function check_package() {

	echo "Checking $1 is installed or not!!"
	dpkg-query -s $1 | grep "Status: install ok installed"

	if [ $? != 0 ] ; then
		return 1;
	else
		return 0;
	fi
	
}

# Install package
function install_command() {
	
			echo "installing $1"
			apt-get install -y $1
}

# check command if present then execute else install
function check_command () {

	command="$1";
	exec_command="$@";

	check_package $command
	if [ $? != 0 ] ;  then
		install_command $command
	fi
	
	$($exec_command)
	
}

check_command curl https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb