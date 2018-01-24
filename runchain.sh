#!/bin/bash

cat << "EOF"

  __  __       _ _   _      _           _       
 |  \/  |_   _| | |_(_) ___| |__   __ _(_)_ __  
 | |\/| | | | | | __| |/ __| '_ \ / _` | | '_ \ 
 | |  | | |_| | | |_| | (__| | | | (_| | | | | |
 |_|  |_|\__,_|_|\__|_|\___|_| |_|\__,_|_|_| |_|
                                            v1.0

EOF

RPC_ALLOW_IP=0.0.0.0/0
NETWORK_PORT=9000
RPC_PORT=8000
EXPLORER_PORT=7000

sleep 3

if [ ! -f /root/.multichain/explorer.conf ]; then
    echo "Preparing Multichain Explorer config..."
    mkdir /root/.multichain

    cat << EOF > /root/.multichain/explorer.conf
    port $EXPLORER_PORT
    host 0.0.0.0
    datadir += [{
            "dirname": "/root/.multichain/$PEER_CHAINNAME",
            "loader": "default",
            "chain": "$PEER_CHAINNAME",
            "policy": "MultiChain"
            }]
    dbtype = sqlite3
    connect-args = /root/.multichain/explorer.sqlite
EOF

fi


if [ ! -d /root/.multichain/$PEER_CHAINNAME ]; then
    echo "No chain found yet"
else
    echo "Chain $PEER_CHAINNAME found. params.dat:"
    cat /root/.multichain/$PEER_CHAINNAME/params.dat

    echo "Starting Multichain Explorer..."
    python -m Mce.abe --config /root/.multichain/explorer.conf&
fi


echo "Starting Multichain and connecting it to a peer node..."
set -x
multichaind $PEER_CHAINNAME@$PEER_HOST:$PEER_PORT $RUNTIME_PARAMS \
      -port=$NETWORK_PORT -rpcallowip=$RPC_ALLOW_IP -rpcport=$RPC_PORT \
      -rpcuser=$RPC_USER -rpcpassword=$RPC_PASS

