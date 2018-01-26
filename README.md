# multichain-node
Multichain node for participating on an existing blockchain by connecting to a peer (seed). This won't create a new blockchain.

The services exposed by this container are:

  * 7000 - Multichain Explorer
  * 8000 - Multichain RPC service
  * 9000 - Multichain Network

If the chain you are trying to participate is permissioned (not public), then the first run of this container will fail because you have to grant connect permission to this node's address on the peer node (the one that has the chain already running). See output log for instructions on the command line you have to run on the peer node to perform authorization.

## Usage
Run ```docker-compose up``` with the following docker-compose.yml contents:

```
version: '2'
services:
    multichain-node:
        image: stutzlab/multichain-node
        ports:
            - "7001:7000"
            - "8001:8000"
            - "9001:9000"
        environment:
            PEER_CHAINNAME: MyChain
            PEER_HOST: firstchain.com
            PEER_PORT: 9000
            RPC_USER: multichainrpc
            RPC_PASSWORD: multichain123
```

## Example
  ```
  git clone https://github.com/stutzlab/multichain-node.git
  cd multichain-node
  ./set-env.sh
  docker-compose up
  ```
