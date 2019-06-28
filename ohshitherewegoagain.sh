#!/usr/bin/env bash

# installing xcode
xcode-select -p
if [[ $? -eq 0 ]]; then
    echo "xcode already installed"
else
    echo "installing xcode..."
    xcode-select --install
fi

# installing Brew
which -s brew
if [[ $? -eq 0 ]]; then
    echo "brew already installed"
else
    echo "installing brew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# configuring .bash_profile
echo "configuring .bash_profile"
touch ~/.bash_profile
echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile
source ~/.bash_profile

if brew doctor| grep -q 'Your system is ready to brew.'; then
    echo "brew is ready"
else
    echo "brew doctor failed (maybe because of output is changed)"
fi

# installing python
echo "Checking if python3 is already installed.."
which -s python3
if [[ $? -eq 0 ]]; then
    echo "Python3 is already installed"
else
    echo "installing python3..."
    brew install python3
fi

python3 --version
alias python=python3
alias pip=pip3

# install virtualenv
echo "installing virtualenv"
pip3 install virtualenv
# installing virtualenvwrapper
echo "installing virtualenvwrapper"
pip3 install virtualenvwrapper

# configuring virtualenv wrapper
echo "configuring virtualenv wrapper..."
echo "VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bash_profile
echo "configured"

brew install openssl
echo 'export PATH="/usr/local/opt/openssl/bin:$PATH"' >> ~/.bash_profile

source ~/.bash_profile

# install PostgreSQL
echo "installing postgres..."
brew install postgres
echo "installing postgis..."
brew install postgis
echo "Start PostgreSQL server.."
pg_ctl -D /usr/local/var/postgres start
echo "Create Database"
initdb /usr/local/var/postgres
if [[ $? -eq 0 ]]; then
    echo "db created"
else
    echo "Removing old database file"
    rm -r /usr/local/var/postgres
    echo "creating db again.."
    initdb /usr/local/var/postgres
    pg_ctl -D /usr/local/var/postgres -l logfile start
fi

# install some utilities
echo "Installing pv"
brew install pv
echo "installing mc"
brew install mc
echo "installing tree"
brew install tree
echo "installing htop"
brew install htop

# installing redis
echo "Checking if redis is already installed.."
which -s redis
if [[ $? -eq 0 ]]; then
    echo "Redis is already installed"
else
    echo "installing redis..."
    brew install redis
fi

echo "Configured redis.."
echo "launching redis on computer starts"
ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
echo "starting redis.."
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist

# installing zsh
echo "installing zsh.."
brew install zsh

echo "copy bosh_profile settings to zsh"
cat ~/.bash_profile >> ~/.zshrc

echo "making it default shell"
chsh -s zsh
