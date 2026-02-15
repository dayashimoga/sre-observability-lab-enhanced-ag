#!/bin/bash
curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:/home/daya/.linkerd2/bin
linkerd check --pre
