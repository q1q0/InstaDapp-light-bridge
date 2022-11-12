import hre from "hardhat";
import {ethers} from "hardhat";
import { ContractTransaction } from "ethers";

const CONSTANTS = {
    nativeToken: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
}

const rootToChainChainId: Record<string, string> = {
    "1": "137",
    "5": "80001"
}

const deployContract = async (contractName: string, constructorArgs: any = [], options: any = [], blockConfirmation?: number) => {
  const Contract = await ethers.getContractFactory(contractName)
  const contract = await Contract.deploy(...constructorArgs, ...options)
  await contract.deployed()
  await contract.deployTransaction.wait(blockConfirmation)
  
  console.log(`${contractName} deployed: `, contract.address)

  return contract;
}

const getChainId = async (): Promise<string> => {
    return  (hre.network.config.chainId || (await ethers.provider.getNetwork()).chainId).toString();
}

const getChildChainId = async (): Promise<string> => {
    const rootChainId = (hre.network.config.chainId || (await ethers.provider.getNetwork()).chainId).toString()
    return rootToChainChainId[rootChainId];
}

const waitTx = async (contractCall: Promise<ContractTransaction>, blockConfirmation?: number, log: boolean = false): Promise<string> =>{
    const tx = await contractCall
    await tx.wait(blockConfirmation)
    if (log) console.log("Transaction Confirmed: ", tx.hash)
    return tx.hash
}

enum Mode {
    ROOT,
    CHILD
}

const getMode = async (): Promise<Mode> => {
    return Object.keys(rootToChainChainId).includes((await getChainId())) ? Mode.ROOT : Mode.CHILD
}


export {
    deployContract,
    getChainId,
    getChildChainId,
    waitTx,
    getMode,
    Mode,
    CONSTANTS,
    rootToChainChainId
}
