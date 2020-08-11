#!/bin/bash

if [ "$EUID" -ne 0 ]
then
  printf "\nYou must run $0 as root\n\n"
  exit
fi

MRSWATSON_DIR="/home/${SUDO_USER}/.mrswatson"
MRSWATSON_REPO="https://github.com/CarlosBalladares/MrsWatson"

error_exit(){
  printf  "\nAn internal command in this script caused a problem. Exiting\n"
}

# add i386 architecture and necessary packages
add_32bit_arch()
{
	printf "\n%sAdding i386 architecture and necessary packages%s\n" "${RED}" "${NC}"
	dpkg --add-architecture i386 || error_exit
	apt-get update || error_exit
	apt-get -y install g++-multilib || error_exit
	apt-get -y install libc6-dev || error_exit
	apt-get -y install libc6-dev-i386 || error_exit
	apt-get -y install libx11-dev || error_exit
	apt-get -y install libx11-6:i386 || error_exit
	apt-get -y install libxrender1:i386 || error_exit
	apt-get -y install libxinerama1:i386 || error_exit
}

# clones MrsWatson from github and builds it
initiate_mrswatson()
{
    printf "%sFetching MrsWatson from github%s\n" "${RED}" "${NC}"
    apt-get -y install git || error_exit
    mkdir "$MRSWATSON_DIR" || error_exit
    git clone "$MRSWATSON_REPO" "$MRSWATSON_DIR" || error_exit
    cd $MRSWATSON_DIR || error_exit
    git submodule sync || error_exit
    git submodule update --init --recursive || error_exit
    # Patches libaudiofile to make it compatible with the compiler config
    sed -i -e 's/-1 << kScaleBits/-1U << kScaleBits/g' vendor/audiofile/libaudiofile/modules/SimpleModule.h || error_exit
    mkdir build || error_exit
    cd build || error_exit
    printf "%sMrsWatson fetched...building%s\n" "${RED}" "${NC}"
    apt-get -y install cmake || error_exit
    cmake -D CMAKE_BUILD_TYPE=Debug -DVERBOSE=TRUE .. || error_exit
    make || error_exit
    mv main/mrswatson /usr/bin/ || error_exit
    mv main/mrswatson64 /usr/bin/ || error_exit
    printf "%sSuccessfully built MrsWatson!%s\n" "${GRN}" "${NC}"
}

# ask for permission to install i386 architecture in order to process 32bit plugins
prompt_32bit_arch()
{
  printf "\n%sThis will add i386 architecture along with necessary packages. Confirm to continue%s y/n " "${RED}" "${NC}"
  read -r answer
  if [[ $answer == "y" ]]
  then
    add_32bit_arch
  else
    printf "aborted\n"
    exit
  fi
}


# check if MrsWatson is installed, ask permission to install if not
prompt_mrs_watson()
{
  printf "\nChecking if %s exists" "$MRSWATSON_DIR"
  if [[ -d ${MRSWATSON_DIR} ]]
  then
    printf "\nMrsWatson already installed!\n\n"
  else
    printf "\n%sMrsWatson is not installed. Confirm to fetch from github and build%s y/n" "${RED}" "${NC}"
    read -r answer
    if [[ $answer == "y" ]]
    then
      initiate_mrswatson
    else
      printf "\naborted\n"
      exit
    fi
  fi
}

prompt_32bit_arch
prompt_mrs_watson