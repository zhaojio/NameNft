'use strict';
const { sleep } = require('../../utils');

const {
    getDefaultProvider,
    Contract,
    constants: { AddressZero },
    utils: { keccak256, defaultAbiCoder },
} = require('ethers');
const {
    utils: { deployContract },
} = require('@axelar-network/axelar-local-dev');
const { deployUpgradable } = require('@axelar-network/axelar-gmp-sdk-solidity');

const ExampleProxy = require('../../artifacts/contracts/Proxy.sol/ExampleProxy.json');
const NameNft = require('../../artifacts/contracts/nft-name/NftName.sol/NameNft.json');


async function deploy(chain, wallet) {
    console.log(`Deploying NftName for ${chain.name}.`);
    const provider = getDefaultProvider(chain.rpc);
    const contract = await deployUpgradable(
        chain.constAddressDeployer,
        wallet.connect(provider),
        NameNft,
        ExampleProxy,
        [chain.gateway, chain.gasReceiver],
        [],
        defaultAbiCoder.encode(['string'], [chain.name]),
        'NftName',
    );
    chain.NftName = contract.address;
    console.log(`Deployed NftName for ${chain.name} at ${chain.NftName}.`);
}

async function addSupportedChain(chains, wallet) {
    console.log('addSupportedChain');
    for (const chain of chains) {
        const provider = getDefaultProvider(chain.rpc);
        chain.wallet = wallet.connect(provider);
        chain.contract = new Contract(chain.NftName, NameNft.abi, chain.wallet);

        for (const chain_ of chains) {
            // console.log(chain_.name +":" + chain.contract.address );
            await chain.contract.addOrUpdateSupportedChain(chain_.name, chain.contract.address);
        }
    }
}


async function test(chains, wallet, options) {
    const args = options.args || [];

    console.log('--- Initially ---');

    const gas = { value: BigInt(Math.floor(3e5 * 100)) };

    for (const chain of chains) {
        const provider = getDefaultProvider(chain.rpc);
        chain.wallet = wallet.connect(provider);
        chain.contract = new Contract(chain.NftName, NameNft.abi, chain.wallet);

        for (const chain_ of chains) {
            // console.log(chain_.name +":" + chain.contract.address );
            await chain.contract.addOrUpdateSupportedChain(chain_.name, chain.contract.address);
        }
    }

    async function mintNft(name) {
        console.log(`Test minting nameNft on the chain ${chains[0].name}`);
        const tx = await chains[0].contract.startMint(name, 0, gas);
        await tx.wait();

        var nft = await chains[0].contract.queryByName(name);

        while (nft.name !== name) {
            nft = await chains[0].contract.queryByName(name);
            await sleep(2000);
        }

        console.log(nft);
        console.log(`Minting sucess!`);
    }

    async function authorization() {
        console.log(`Authorization from ${chains[0].name} to ${chains[1].name}`);

        const tx = await chains[0].contract.authorization(wallet.address, chains[1].name, "zhaojie", 0, gas);
        await tx.wait();

        var nft = await chains[1].contract.queryByName("zhaojie");

        while (nft.userAddress !== wallet.address) {
            nft = await chains[1].contract.queryByName("zhaojie");
            await sleep(2000);
        }

        console.log(nft);
        console.log(`Authorization sucess! namenft:zhaojie can user on ${chains[1].name}`);
    }

    async function deauthorization() {
        console.log(`Deauthorization from ${chains[0].name} to ${chains[1].name}`);

        const tx = await chains[0].contract.deauthorization(wallet.address, chains[1].name, "zhaojie", 0, gas);
        await tx.wait();

        var nft = await chains[1].contract.queryByName("zhaojie");

        console.log(nft);
        while (nft.userAddress === wallet.address) {
            nft = await chains[1].contract.queryByName("zhaojie");
            await sleep(2000);
        }

        console.log(nft);
        console.log(`deauthorization sucess! namenft: zhaojie on ${chains[1].name}`);
    }

    async function transferLocal() {
        console.log(`TransferLocal from ${chains[0].name} to ${chains[0].name}`);

        // const toaddr = "0x4e9bfBE6925D85c888A6f23E546d30753B289DE0";
        const toaddr = wallet.address;

        const tx = await chains[0].contract.transfer(toaddr, chains[0].name, "zhaojie", 0, gas);
        await tx.wait();

        var nft = await chains[0].contract.queryByName("zhaojie");

        while (nft.userAddress !== toaddr) {
            nft = await chains[0].contract.queryByName("zhaojie");
            await sleep(2000);
        }

        console.log(nft);
        console.log(`TransferLocal sucess! namenft:zhaojie from ${wallet.address} to ${toaddr} on localchain ${chains[0].name}`);
    }

    async function transferRemote() {
        console.log(`TransferRemote from ${chains[0].name} to ${chains[1].name}`);

        const tx = await chains[0].contract.transfer(wallet.address, chains[1].name, "zhaojie", 0, gas);
        await tx.wait();

        var nft = await chains[1].contract.queryByName("zhaojie");

        while (nft.userAddress !== wallet.address) {
            nft = await chains[1].contract.queryByName("zhaojie");
            await sleep(2000);
        }

        console.log(nft);
        console.log(`TransferRemote sucess! namenft:zhaojie from ${chains[0].name} to ${chains[1].name} to same address: ${wallet.address}`);
    }


    /*
    1. 铸造nft
    2. 查询功能
    3. 在其他链的地址进行授权
    4. 撤销授权
    5. 转移nft所有权
    6. 跨链转移nft所有权
    */

    await mintNft('zhaojie');

    await authorization();

    await deauthorization();

    await transferLocal();

    await transferRemote();

    console.log('--- TEST END ---');

}

module.exports = {
    deploy,
    test,
    addSupportedChain
};
