#!/bin/sh
set -e

SUPPORT_MAP="
x86_64-centos-7
x86_64-fedora-26
x86_64-fedora-27
x86_64-fedora-28
x86_64-debian-wheezy
x86_64-debian-jessie
x86_64-debian-stretch
x86_64-debian-buster
x86_64-ubuntu-trusty
x86_64-ubuntu-xenial
x86_64-ubuntu-bionic
x86_64-ubuntu-artful
s390x-ubuntu-xenial
s390x-ubuntu-bionic
s390x-ubuntu-artful
ppc64le-ubuntu-xenial
ppc64le-ubuntu-bionic
ppc64le-ubuntu-artful
aarch64-ubuntu-xenial
aarch64-ubuntu-bionic
aarch64-debian-jessie
aarch64-debian-stretch
aarch64-debian-buster
aarch64-fedora-26
aarch64-fedora-27
aarch64-fedora-28
aarch64-centos-7
armv6l-raspbian-jessie
armv7l-raspbian-jessie
armv6l-raspbian-stretch
armv7l-raspbian-stretch
armv7l-debian-jessie
armv7l-debian-stretch
armv7l-debian-buster
armv7l-ubuntu-trusty
armv7l-ubuntu-xenial
armv7l-ubuntu-bionic
armv7l-ubuntu-artful
"

get_distribution() {
  lsb_dist=""
  # Every system that we officially support has /etc/os-release
  if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
  fi
  # Returning an empty string here should be alright since the
  # case statements don't act unless you provide an actual value
  echo "$lsb_dist"
}

# Check if this is a forked Linux distro
check_forked() {

  # Check for lsb_release command existence, it usually exists in forked distros
  if command_exists lsb_release; then
    # Check if the `-u` option is supported
    set +e
    lsb_release -a -u >/dev/null 2>&1
    lsb_release_exit_code=$?
    set -e

    # Check if the command has exited successfully, it means we're in a forked distro
    if [ "$lsb_release_exit_code" = "0" ]; then
      # Print info about current distro
      cat <<-EOF
			You're using '$lsb_dist' version '$dist_version'.
			EOF

      # Get the upstream release info
      lsb_dist=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'id' | cut -d ':' -f 2 | tr -d '[:space:]')
      dist_version=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'codename' | cut -d ':' -f 2 | tr -d '[:space:]')

      # Print info about upstream distro
      cat <<-EOF
			Upstream release is '$lsb_dist' version '$dist_version'.
			EOF
    else
      if [ -r /etc/debian_version ] && [ "$lsb_dist" != "ubuntu" ] && [ "$lsb_dist" != "raspbian" ]; then
        if [ "$lsb_dist" = "osmc" ]; then
          # OSMC runs Raspbian
          lsb_dist=raspbian
        else
          # We're Debian and don't even know it!
          lsb_dist=debian
        fi
        dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
        case "$dist_version" in
        9)
          dist_version="stretch"
          ;;
        8 | 'Kali Linux 2')
          dist_version="jessie"
          ;;
        7)
          dist_version="wheezy"
          ;;
        esac
      elif [ -r /etc/redhat-release ] && [ "$lsb_dist" = "" ]; then
        lsb_dist=redhat
      fi
    fi
  fi
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

check_command_status() {
  if [ "$1" -eq 0 ]; then
    echo
    echo "$2"
    echo
  elif [ "$1" -eq 777 ]; then
    echo
    echo "$4"
    echo
  else
    echo
    echo "$3"
    echo
    exit "$1"
  fi
}

add_repo_if_not_exists() {
  repo="$1"
  if ! grep -Fxq "$repo" /etc/apt/sources.list; then
    (
      set -x
      $sh_c "echo \"$repo\" >> /etc/apt/sources.list"
      set +x
    )
  fi
}

add_initial_apt_repos_if_not_exist() {
  case "$lsb_dist" in
  debian)
    if [ "$dist_version" = "stretch" ]; then
      add_repo_if_not_exists "deb http://deb.debian.org/debian stretch main"
      add_repo_if_not_exists "deb-src http://deb.debian.org/debian stretch main"
      add_repo_if_not_exists "deb http://deb.debian.org/debian-security/ stretch/updates main"
      add_repo_if_not_exists "deb-src http://deb.debian.org/debian-security/ stretch/updates main"
      add_repo_if_not_exists "deb http://deb.debian.org/debian stretch-updates main"
      add_repo_if_not_exists "deb-src http://deb.debian.org/debian stretch-updates main"
    elif [ "$dist_version" = "jessie" ]; then
      add_repo_if_not_exists "deb http://ftp.de.debian.org/debian jessie main"
    fi
    ;;
  esac
  $sh_c 'apt-get update -qq >/dev/null'
}

handle_docker_unsuccessful_installation() {
  if ! command_exists docker; then
    # for fedora 28
    if [ "$lsb_dist" = "fedora" ] && [ "$dist_version" = "28" ]; then
      $sh_c "dnf -y -q install https://download.docker.com/linux/fedora/27/x86_64/stable/Packages/docker-ce-18.03.1.ce-1.fc27.x86_64.rpm >/dev/null 2>&1"
    fi
  fi
}

start_docker() {
  # check if docker is running
  if [ ! -f /var/run/docker.pid ]; then
    $sh_c "/etc/init.d/docker start >/dev/null 2>&1"
    command_status=$?
    if [ $command_status -ne 0 ]; then
      $sh_c "service docker start >/dev/null 2>&1"
      command_status=$?
    fi
  fi
}

do_install_jq() {
  echo "# Installing jq..."
  echo
  set -x
  # if variable need_to_install equals to 1 jq install is required
  need_to_install=1
  if command_exists jq; then
    need_to_install=0
  fi
  if [ "$need_to_install" -ne "0" ]; then
    case "$lsb_dist" in
    ubuntu | debian | raspbian)
      $sh_c "apt-get update -qq >/dev/null"
      $sh_c "apt-get install -qq jq >/dev/null"
      command_status=$?
      ;;
    fedora | centos)
      $sh_c "yum install -y -q jq"
      command_status=$?
      ;;
    esac
  else
    command_status=777
  fi

  set +x
}

do_install_docker() {
  echo "# Installing Docker..."
  echo
  sleep 3
  set -x

  if ! hash docker 2>/dev/null; then
    curl -fsSL https://get.docker.com/ | sh
    command_status=$?
  fi

  handle_docker_unsuccessful_installation
  start_docker

  set +x
}

do_install_docker_compose() {
  echo "# Installing docker-compose..."
  echo
  set -x

  if ! hash docker-compose 2>/dev/null; then
    $sh_c "curl -L 'https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose" >/dev/null
    $sh_c "chmod +x /usr/local/bin/docker-compose"
    command_status=$?
  fi

  set +x
}

do_install_demo() {
  echo "# Installing development environment..."
  echo
  set -x

  $sh_c "curl -L -o dev.tar.gz https://github.com/eclipse-iofog/demo/archive/v1.3.0-rc1.tar.gz" >/dev/null
  $sh_c "tar -zxvf dev.tar.gz --strip-components=1"
  command_status=$?

  set +x
}

#
# Check between apt or yum
#
install_iofogctl_linux() {
  echoInfo "# Installing iofogctl..."
  case "$lsb_dist" in
  ubuntu | debian | raspbian)
    $sh_c "curl -s https://packagecloud.io/install/repositories/iofog/iofogctl/script.deb.sh | sudo bash"
    $sh_c "sudo apt-get install iofogctl -y"
    command_status=$?
    ;;
  fedora | centos)
    $sh_c "curl -s https://packagecloud.io/install/repositories/iofog/iofogctl/script.rpm.sh | sudo bash"
    $sh_c "sudo yum install iofogctl -y"
    command_status=$?
    ;;
  esac
  if [ -z "$(command -v iofogctl)" ]; then
    echoInfo "Could not detect package installation system"
    echoInfo "Please follow github instructions to install iofogctl: https://github.com/eclipse-iofog/iofogctl"
    return 1
  else
    echo "iofogctl installed!"
    iofogctl version
    echo ""
    return 0
  fi
}

getSystemInfo() {
  lowercase() {
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
  }
  OS=$(lowercase "$(uname)")
  KERNEL=$(uname -r)
  MACH=$(uname -m)

  if [ "${OS}" = "windowsnt" ]; then
    OS=windows
  elif [ "${OS}" = "darwin" ]; then
    OS=mac
  else
    OS=$(uname)
    if [ "${OS}" = "SunOS" ]; then
      OS=Solaris
      ARCH=$(uname -p)
      OSSTR="${OS} ${REV}(${ARCH} $(uname -v))"
    elif [ "${OS}" = "AIX" ]; then
      OSSTR="${OS} $(oslevel) ($(oslevel -r))"
    elif [ "${OS}" = "Linux" ]; then
      if [ -f /etc/redhat-release ]; then
        DistroBasedOn='RedHat'
        DIST=$(sed s/\ release.*// </etc/redhat-release)
        PSUEDONAME=$(sed s/.*\(// </etc/redhat-release | sed s/\)//)
        REV=$(sed s/.*release\ // </etc/redhat-release | sed s/\ .*//)
      elif [ -f /etc/SuSE-release ]; then
        DistroBasedOn='SuSe'
        PSUEDONAME=$(tr "\n" ' ' </etc/SuSE-release | sed s/VERSION.*//)
        REV=$(tr "\n" ' ' </etc/SuSE-release | sed s/.*=\ //)
      elif [ -f /etc/mandrake-release ]; then
        DistroBasedOn='Mandrake'
        PSUEDONAME=$(sed s/.*\(// </etc/mandrake-release | sed s/\)//)
        REV=$(sed s/.*release\ // </etc/mandrake-release | sed s/\ .*//)
      elif [ -f /etc/debian_version ]; then
        DistroBasedOn='Debian'
        if [ -f /etc/lsb-release ]; then
          DIST=$(grep '^DISTRIB_ID' /etc/lsb-release | awk -F= '{ print $2 }')
          PSUEDONAME=$(grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F= '{ print $2 }')
          REV=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F= '{ print $2 }')
        fi
      fi
      if [ -f /etc/UnitedLinux-release ]; then
        DIST="${DIST}[$(tr "\n" ' ' </etc/UnitedLinux-release | sed s/VERSION.*//)]"
      fi
      OS=$(lowercase $OS)
      DistroBasedOn=$(lowercase $DistroBasedOn)
      readonly OS
      readonly OSSTR
      readonly DIST
      readonly DistroBasedOn
      readonly PSUEDONAME
      readonly REV
      readonly KERNEL
      readonly MACH
    fi

  fi
}

check_iofogctl() {
  if [ -z "$(command -v iofogctl)" ]; then
    echoError "iofogctl not found!"
    if [ "${VERIFY}" -eq 1 ]; then
      command_status=1
      return 1
    else
      install_iofogctl_linux
      command_status=$?
      return $command_status
    fi
  else
    echo "iofogctl found in path!"
    iofogctl version
    echo ""
    command_status=777
    return 0
  fi
}

do_install() {
  echo "# Executing install script"

  command_status=0
  sh_c='sh -c'
  if [ "$USER" != 'root' ]; then
    if command_exists sudo; then
      sh_c='sudo -E sh -c'
    elif command_exists su; then
      sh_c='su -c'
    else
      cat >&2 <<-'EOF'
			Error: this installer needs the ability to run commands as root.
			We are unable to find either "sudo" or "su" available to make this happen.
			EOF
      exit 1
    fi
  fi

  echo "# Retrieving system information"
  lsb_dist=$(get_distribution)
  lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
  #  getSystemInfo

  case "$lsb_dist" in

  ubuntu)
    if command_exists lsb_release; then
      dist_version="$(lsb_release --codename | cut -f2)"
    fi
    if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
      dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
    fi
    ;;

  debian | raspbian)
    dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
    case "$dist_version" in
    9)
      dist_version="stretch"
      ;;
    8)
      dist_version="jessie"
      ;;
    7)
      dist_version="wheezy"
      ;;
    esac
    ;;

  centos)
    if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
      dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
    fi
    ;;

  rhel | ol | sles)
    ee_notice "$lsb_dist"
    exit 1
    ;;

  *)
    if command_exists lsb_release; then
      dist_version="$(lsb_release --release | cut -f2)"
    fi
    if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
      dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
    fi
    ;;

  esac

  # Check if this is a forked Linux distro
  check_forked

  echo "lsb_dist: $lsb_dist"
  echo "dist_version: $dist_version"

  # Check if we actually support this configuration
  if ! echo "$SUPPORT_MAP" | grep "$(uname -m)-$lsb_dist-$dist_version" >/dev/null; then
    cat >&2 <<-'EOF'

		Either your platform is not easily detectable or is not supported by this
		installer script.
		Please visit ioFog documentation for more detailed installation instructions:

		https://iofog.org/docs/getting-started/core-concepts.html

		EOF
    exit 1
  fi

  # Run setup for each distro accordingly
  set +e
  add_initial_apt_repos_if_not_exist
  check_command_status $command_status \
    "# Curl has been installed successfully" \
    "# Curl installation failed. Please proceed with installation manually" \
    "# Curl is already installed"

  do_install_jq
  check_command_status $command_status \
    "# 'jq' has been successfully installed" \
    "# 'jq' installation failed. Please proceed with installation manually" \
    "# 'jq' is already installed"

  do_install_docker
  check_command_status $command_status \
    "# Docker has been installed successfully" \
    "# Docker installation failed. Please proceed with installation manually" \
    "# Docker is already installed"

  do_install_docker_compose
  check_command_status $command_status \
    "# docker-compose has been installed successfully" \
    "# docker-compose installation failed. Please proceed with installation manually" \
    "# docker-compose is already installed"

  do_install_demo
  check_command_status $command_status \
    "# Demo repository has been cloned successfully" \
    "# Cloning demo repository failed. Please proceed with installation manually" ""

  check_iofogctl
  check_command_status $command_status \
    "# Iofogctl has been installed successfully" \
    "# Iofogctl installation failed, please install iofogctl manually. See https://iofog.org/docs/1.3.0/getting-started/quick-start.html for details." \
    "# Iofogctl is already installed"

}
do_install
