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


if [ ! -f /root/.multichain/_connected ]; then
    echo "No chain found yet. Initializing first peer connection..."

    set -x
    multichaind -daemon $PEER_CHAINNAME@$PEER_HOST:$PEER_PORT $RUNTIME_PARAMS \
      -port=$NETWORK_PORT -rpcallowip=$RPC_ALLOW_IP -rpcport=$RPC_PORT \
      -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD
    set +x

    sleep 3

    #rpcport and rpcpassword are not configured correctly by default. forcing it.
    cat << EOF > /root/.multichain/$PEER_CHAINNAME/multichain.conf
rpcuser=$RPC_USER
rpcpassword=$RPC_PASSWORD
rpcport=$RPC_PORT
EOF

    echo "Testing if connected to peer succesfully..."
    multichain-cli $PEER_CHAINNAME ping
    LE=$?

    if [ $LE -eq 0 ]; then
        echo "Connected to peer node successfuly. Local chain initialized."
        touch /root/.multichain/_connected

        multichain-cli $PEER_CHAINNAME stop
        sleep 3
        
    else
        echo "Failed to connect to peer. See instructions on how to grant permission to this node above."
        exit $?
    fi

fi

echo ""
echo ""
echo "/root/.multichain/$PEER_CHAINNAME/params.dat contents:"
cat /root/.multichain/$PEER_CHAINNAME/params.dat
echo ""
echo ""

echo ""
echo "Starting Multichain Explorer..."
python -m Mce.abe --config /root/.multichain/explorer.conf&

echo ""
echo "Starting Multichain and connecting it to a peer node..."
set -x
multichaind $PEER_CHAINNAME@$PEER_HOST:$PEER_PORT $RUNTIME_PARAMS \
      -port=$NETWORK_PORT -rpcallowip=$RPC_ALLOW_IP -rpcport=$RPC_PORT \
      -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD
