#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

if [ -d .env ]; then
  set -o allexport; source .env; set +o allexport
fi

if [ -z "$ALCHEMY_API_KEY" ]; then
  echo "ALCHEMY_API_KEY is undefined in .env";
  exit 1;
fi

networks=(local mainnet goerli)
if [[ ! " ${networks[*]} " =~ " $1 " ]]; then 
  echo "Unsupported network '$1'";
  exit 1;
fi

if [ "$1" == "local" ]; then
  forge test --ffi --chain-id 99 --match-path src/test/local
elif [ "$1" == "mainnet" ]; then
  forge test --chain-id 99 --fork-url https://eth-$1.alchemyapi.io/v2/${ALCHEMY_API_KEY} --fork-block-number 13700000 --no-match-path src/test/rpc/LeverEPTActions.t.sol
  forge test --chain-id 99 --fork-url https://eth-$1.alchemyapi.io/v2/${ALCHEMY_API_KEY} --fork-block-number 15100000 --match-path src/test/rpc/LeverEPTActions.t.sol
else
  ETH_RPC_URL=https://eth-$1.alchemyapi.io/v2/${ALCHEMY_API_KEY}
  forge test --fork-url $ETH_RPC_URL
fi