import hre from "hardhat";
import {ethers} from "hardhat";
import { ContractTransaction } from "ethers";

const CONSTANTS = {
    nativeToken: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
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
    return ["1", "5"].includes((await getChainId())) ? Mode.ROOT : Mode.CHILD
}


export {
    deployContract,
    getChainId,
    waitTx,
    getMode,
    Mode,
    CONSTANTS
}
