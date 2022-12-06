import {
    AxelarGMPRecoveryAPI,
    Environment,
    AddGasOptions,
    EvmChain
  } from "@axelar-network/axelarjs-sdk";
  
  // Optional
  const options: AddGasOptions = {
    amount: "10000000", // Amount of gas to be added. If not specified, the sdk will calculate the amount automatically.
    refundAddress: "0x1AE978F987e9d4CCC32850D995C62F3f6e575EfD", // If not specified, the default value is the sender address.
    estimatedGasUsed: 700000, // An amount of gas to execute `executeWithToken` or `execute` function of the custom destination contract. If not specified, the default value is 700000.
    evmWalletDetails: { useWindowEthereum: false, privateKey: "0x25121fb9a63992d9d0187eafa646c5d540118c2bd84e2db3c6774b16f0d9d3fe" }, // A wallet to send an `addNativeGas` transaction. If not specified, the default value is { useWindowEthereum: true}.
  };
  
  const api = new AxelarGMPRecoveryAPI({
    environment: Environment.TESTNET,
  });
  
  const txHash: string = "0x2c852e740B62308c46DD29B982FBb650D063Bd07";
//   const { success, transaction, error } = await 
  api.addNativeGas(
    EvmChain.POLYGON,
    txHash,
    options
  ).then(console.log);
  
//   if (success) {
//     console.log("Added native gas tx:", transaction?.transactionHash);
//   } else {
//     console.log("Cannot add native gas", error);
//   }