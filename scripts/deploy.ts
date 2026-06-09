import { network } from "hardhat";

async function main() {
  console.log("Deploying IRIS Chain...");

  const { ethers } = await network.create();

  const token = await ethers.deployContract("IRISChain");

  await token.waitForDeployment();

  const tokenAddress = await token.getAddress();

  console.log("IRIS Chain deployed to:", tokenAddress);
  console.log("Token Name: IRIS Chain");
  console.log("Symbol: IRC");
  console.log("Decimals: 18");
  console.log("Total Supply: 2,000,000,000 IRIS");
}

main().catch(function (error) {
  console.error(error);
  process.exitCode = 1;
});
