import hre from "hardhat";

const { ethers } = hre

async function main() {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  console.log("\n Deployer Address:", deployer)
  console.log(
    "\n Deploying Dummy Impl deterministically \n ---------------------"
  );

  const DummyImpl = await deploy("DummyImpl", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: ethers.utils.formatBytes32String("xyz-abc-123-5"),
  });

  console.log("Deployed DummyImpl to", DummyImpl.address);

  console.log(
    "\n Deploying Lite Bridge contracts deterministically \n ---------------------"
  );

  console.log(
    "\n Deploying Dummy Impl deterministically \n ---------------------"
  );

  const LiteProxyAdmin = await deploy("LiteProxyAdmin", {
    from: deployer,
    args: [deployer],
    log: true,
    deterministicDeployment: ethers.utils.formatBytes32String("xyz-abc-123-5"),
  });

  console.log("Deployed LiteProxyAdmin to", LiteProxyAdmin.address);

  console.log(
    "\n Deploying Lite Bridge contracts deterministically \n ---------------------"
  );


  const LiteBridge = await deploy("LiteBridgeProxy", {
    from: deployer,
    args: [
      DummyImpl.address,
      LiteProxyAdmin.address,
      "0x"
    ],
    log: true,
    deterministicDeployment: ethers.utils.formatBytes32String("xyz-abc-123"),
  });

  console.log("Deployed LiteBridge to", LiteBridge.address);

  if (hre.network.name !== 'hardhat') {
    try {
      await hre.run('verify:verify', {
          address: LiteBridge.address,
          contract: "contracts/liteBridge/proxy.sol:LiteBridgeProxy",
          constructorArguments: [
            DummyImpl.address,
            LiteProxyAdmin.address,
            "0x"
          ],
      })
    } catch (error) {
      console.log(error)
    }

    try {
      await hre.run('verify:verify', {
          address: LiteProxyAdmin.address,
          contract: "contracts/liteBridge/proxyAdmin.sol:LiteProxyAdmin",
          constructorArguments: [deployer],
      })
    } catch (error) {
      console.log(error)
    }
  } else {
    console.log("Contracts deployed")
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
