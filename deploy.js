const hre = require("hardhat");

async function main() {
  const BASE_TOKEN = "0x..."; 
  const QUOTE_TOKEN = "0x...";

  const Orderbook = await hre.ethers.getContractFactory("Orderbook");
  const ob = await Orderbook.deploy(BASE_TOKEN, QUOTE_TOKEN);

  await ob.waitForDeployment();
  console.log(`Orderbook deployed to: ${await ob.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
