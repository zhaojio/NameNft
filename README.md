## Overview
    
Minting the username into NFT, make the username on the chain unique, turn it into a digital asset, and can be used between multiple chains.

## 

## How it works

1. Publish a dapp named NameNft DApp on all supported chains, providing the function of minting nft, an nft is a string, such as ‘zhaojie’.
2. When minting nft through NameNft DApp, set ownership and usage rights for nft.
3. The ownership of an nft exists only on one chain, and the right to use can exist on multiple chains at the same time.
4. Users who hold nft ownership on chain A can authorize the username to a certain address on chain B. At this time, nft exists on chain A and chain B at the same time, and there can be multiple usage rights. Authorization on multiple chains.
5. Ownership can be transferred on different chains, but can only exist on one chain.
6. Ownership can revoke the right to use.

## Final goal
The nft is minted by a string (username) and can be used on multiple chains, and the nft holder has a unique username on multiple chains.

The environment is the same as axelar-local-gmp-examples
 
    sudo npm i -g n
    sudo n v16.15.0
    
Clone this repo:

    git clone https://github.com/zhaojio/NameNft
    cd name Nft
    npm install
    
Check your own private key.

    cp.env.example.env

Run local test environment

    node-script/createLocal

Edit and publish contracts
    
    npm run build
    node script/deployment contract/nft-name local
    
Run Local Test

    node script/deployment contract/nft-name local
    
Copy the front-end resource file(*important)

    chmod +x copy.sh
    ./copy.sh

Run the front-end page with npm http-server
    
    npm install -g http-server
    cd frontend/publish
    http-server

Open the page in a browser
   
   http://127.0.0.1:8080/
   
![image](https://github.com/zhaojio/NameNft/blob/main/frontend/name-nft-ui.png)

## Why have the right to own and use
If the user name is only minted on multiple chains at the time of registration, due to the problem of time difference, it cannot be guaranteed that the minting will be successful on multiple chains. For example, if two addresses are minted on two chains at the same time, conflicts will occur. After the ownership is introduced and only exists on one chain, when casting, first query whether the user name on other chains exists, which can ensure uniqueness, but at this time the user name can only exist on one chain, and the usability is limited, so it needs to be introduced again The concept of usage rights can guarantee uniqueness and can be used in more places.

## Use Cases(assumption)

1. Find the corresponding address by name.
2. Confirm user identity by name when transferring money by address to avoid mistakes.
    E.g:
    1. The third-party wallet app integrates NameNftDapp, and the address of the other party can be found by the name when transferring money.
    2. The third-party chat app integrates NameNftDapp and finds a user through @xxxx.
    3. The third-party wallet app integrates NameNftDapp. When filling in the address, it prompts the name corresponding to the address, which is used to confirm the user's identity and avoid errors.
