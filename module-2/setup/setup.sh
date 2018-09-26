#!/bin/bash

# Download Istio
cd $HOME
export ISTIO_VERSION=1.0.2
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
cd istio-$ISTIO_VERSION
export PATH=$PATH:$HOME/istio-$ISTIO_VERSION/bin


# Krompt the prompt
cd $HOME
cat $HOME/advanced-kubernetes-bootcamp/module-2/setup/krompt.txt >> $HOME/.bashrc
source $HOME/.bashrc

