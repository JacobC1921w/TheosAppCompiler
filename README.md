# TheosAppCompiler
An automatic multitool for compiling and launching applications developed with THEOS

## Usage:
```bash
./TAC.sh <IPAddress>
```

This tool will (in order):
* Check whether host is online
* Generate an SSH key (or use an old one)
* Send SSH key to host
* Show syntax highlighyed JSON information of application
* Remove old application from host
* Compile currant application for host
* Send `.deb` file to host
* Install `.deb` file onto host
* Execute a `uicache` command on host
* Open the application on the host

Yeah, you could do all of this yourself, but why waste the effort?

Throughout this script, you may encounter multiple errors to do with compiling, execution, etc. If this is the case, and google doesn't help you, please feel free to contact myself, and I will try to recitfy the issue as soon as possible.

This script also has error detection for each step, as to not screw anything up (you're welcome).

## Installation:
```bash
git clone https://github.com/JacobC1921/TheosAppCompiler
mv TheosAppCompiler/TAC.sh <ProjectDir>
chmod <ProjectDIR>/TAC.sh
cd <ProjectDir>
bash TAC.sh <IphoneIP>
```

or, using the raw file:
```bash
cd <ProjectDIR>
curl https://raw.githubusercontent.com/JacobC1921/TheosAppCompiler/main/TAC.sh -O TAC.sh
chmod +x TAC.sh
bash TAC.sh <IphoneIP>
```

## Dependencies:
### Linux:
* bash
* corutils
* grep
* make
* netcat
* openssh-client
* sshpass

### iPhone:
* coreutils-bin
* dpkg
* libactivator
* uikittools
