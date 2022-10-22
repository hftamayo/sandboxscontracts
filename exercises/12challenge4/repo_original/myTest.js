const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("Challenge 4: ⚖️ 🪙 Minimun Viable Exchange", function () {
  let myContract;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("DEX: Standard Path", function () {
    // TODO: need to add tests that the other functions do not work if we try calling them without init() started.
    /* TODO checking `price` calcs. Preferably calculation test should be provided by somebody who didn't implement this functions in 
    challenge to not reproduce mistakes systematically.*/
    describe("init()", function () {
      describe("ethToToken()", function () {
        it("should send 1ether to Dex in exchange for BAL, AND emit EthToTokenSwap(msg.sender, msg.value, tokenOutput) event", async () => {
          const value = ethers.utils.parseEther("1");
          const initialDexBalance = await ethers.provider.getBalance(
            dexContract.address
          );
          const initialDexTokens = await balloonsContract.balanceOf(
            dexContract.address
          );
          let tx1 = await dexContract.ethToToken({
            value: value,
          });
          let txReceipt = await tx1.wait(1);
          const finalDexBalance = await ethers.provider.getBalance(
            dexContract.address
          );
          await expect(tx1).emit(dexContract, "EthToTokenSwap");
          assert.equal(txReceipt.events[1].args.caller, deployer.address);
          assert.equal(
            txReceipt.events[1].args.ethAmount.toString(),
            value.toString()
          );
          assert.equal(
            finalDexBalance.toString(),
            initialDexBalance.add(value).toString()
          );
        });
        it("Should send less tokens after the first trade (ethToToken called)", async function () {
          const tx1 = await dexContract.ethToToken({
            value: ethers.utils.parseEther("1"),
          });
          const tx1Receipt = await tx1.wait(1);
          const tokenOutput1 = tx1Receipt.events[1].args.tokenOutput;
          let user2contract = dexContract.connect(user2);
          let tx2 = await user2contract.ethToToken({
            value: ethers.utils.parseEther("1"),
          });
          expect(tx2).emit(dexContract, "EthToTokenSwap");
          const tx2Receipt = await tx2.wait(1);
          const tokenOutput2 = tx2Receipt.events[1].args.tokenOutput;
          assert(tokenOutput1.sub(tokenOutput2).toString() > "0");
        });
      });
      describe("tokenToEth", async () => {
        it("Should send 1 $BAL to DEX in exchange for _ $ETH, and emit TokenToEthSwap(msg.sender, tokenInput, ethOutput) event", async function () {
          const balloons_bal_start = await balloonsContract.balanceOf(
            dexContract.address
          );
          const initialUserBalance = await ethers.provider.getBalance(
            deployer.address
          );
          // console.log(`initial dex ballons : ${balloons_bal_start.toString()}`);
          const value = ethers.utils.parseEther("1");
          const txApprove = await balloonsContract.approve(
            dexContract.address,
            ethers.utils.parseEther("5")
          );
          await txApprove.wait(1);
          let tx1 = await dexContract.tokenToEth(value);
          let tx1Receipt = await tx1.wait(1);
          await expect(tx1).emit(dexContract, "TokenToEthSwap");
          assert.equal(tx1Receipt.events[2].args.caller, deployer.address);
          assert.equal(
            tx1Receipt.events[2].args.tokenInput.toString(),
            value.toString()
          );
          expect(
            await balloonsContract.balanceOf(dexContract.address)
          ).to.equal(balloons_bal_start.add(value));
          const finalUserBalance = await ethers.provider.getBalance(
            deployer.address
          );
          assert(initialUserBalance.lt(finalUserBalance));
          assert(
            finalUserBalance.toString() <
              initialUserBalance
                .add(tx1Receipt.events[2].args.ethAmount)
                .toString()
          );
        });
        it("Should send less eth after the first trade (tokenToEth() called)", async function () {
          const value = ethers.utils.parseEther("1");
          const txApprove = await balloonsContract.approve(
            dexContract.address,
            ethers.utils.parseEther("10")
          );
          await txApprove.wait(1);
          let tx1 = await dexContract.tokenToEth(value);
          const tx1_receipt = await tx1.wait();
          let tx2 = await dexContract.tokenToEth(value);
          const tx2_receipt = await tx2.wait();

          const ethSent_1 = tx1_receipt.events[2].args.ethAmount;
          const ethSent_2 = tx2_receipt.events[2].args.ethAmount;
          assert(ethSent_2.lt(ethSent_1));
        });
      });
      describe("deposit", async () => {
        it("Should deposit 1 ETH and 1 $BAL when pool at 1:1 ratio, and emit LiquidityProvided(msg.sender,msg.value,tokensDeposited,mintedLiquidity,totalLiquidity) event", async function () {
          const value = ethers.utils.parseEther("5");
          const tokenReserves = await balloonsContract.balanceOf(
            dexContract.address
          );
          const ethReserves = await ethers.provider.getBalance(
            dexContract.address
          );
          const initialUserReserves = await ethers.provider.getBalance(
            deployer.address
          );
          const initialUserTokens = await balloonsContract.balanceOf(
            deployer.address
          );
          const totalLiquidity = await dexContract.totalLiquidity();
          const expectedTokenToDeposit = value
            .mul(tokenReserves)
            .div(ethReserves);
          const expectedMintedLiquidity = value
            .mul(totalLiquidity)
            .div(ethReserves);
          const txApprove = await balloonsContract.approve(
            dexContract.address,
            ethers.utils.parseEther("15")
          );

          await txApprove.wait(1);

          const txDeposit = await dexContract.deposit({ value: value });
          const txDepositReceipt = await txDeposit.wait(1);
          expect(txDeposit).to.emit(dexContract.address, "LiquidityProvided");
          const finalTotalLiquidity = await dexContract.totalLiquidity();
          const finalTokenReserves = await balloonsContract.balanceOf(
            dexContract.address
          );
          const finalEthReserves = await ethers.provider.getBalance(
            dexContract.address
          );
          const finalUserReserves = await ethers.provider.getBalance(
            deployer.address
          );
          const finalUserTokens = await balloonsContract.balanceOf(
            deployer.address
          );
          assert.equal(
            txDepositReceipt.events[2].args.depositer,
            deployer.address
          );
          assert.equal(
            txDepositReceipt.events[2].args.ethAmount,
            value.toString().toString()
          );
          assert.equal(
            txDepositReceipt.events[2].args.tokenAmount.toString(),
            expectedTokenToDeposit.toString()
          );
          assert.equal(
            txDepositReceipt.events[2].args.mintedLiquidity.toString(),
            expectedMintedLiquidity.toString()
          );
          assert.equal(
            txDepositReceipt.events[2].args.totalLiquidity.toString(),
            finalTotalLiquidity.toString()
          );
          assert.equal(
            finalTokenReserves.toString(),
            tokenReserves.add(expectedTokenToDeposit).toString()
          );
          assert.equal(
            finalEthReserves.toString(),
            ethReserves.add(value).toString()
          );
          assert(
            initialUserReserves.toString() >=
              finalUserReserves.add(value).toString()
          );
          assert(
            initialUserTokens.toString() >=
              finalUserTokens.add(expectedTokenToDeposit).toString()
          );
          // TODO: SYNTAX - Write expect() assessing changed liquidty within the pool. Should have an emitted event!
        });
      });
      describe("withdraw", async () => {
        it("Should withdraw 1 ETH and 1 $BAL when pool at 1:1 ratio", async function () {
          const value = ethers.utils.parseEther("1");
          const txApprove = await balloonsContract.approve(
            dexContract.address,
            ethers.utils.parseEther("10")
          );
          await txApprove.wait(1);
          const txdeposit = await dexContract.deposit({
            value: ethers.utils.parseEther("1.5"),
          });
          await txdeposit.wait(1);
          const tokenReserves = await balloonsContract.balanceOf(
            dexContract.address
          );
          const ethReserves = await ethers.provider.getBalance(
            dexContract.address
          );
          const initialUserReserves = await ethers.provider.getBalance(
            deployer.address
          );
          const initialUserTokens = await balloonsContract.balanceOf(
            deployer.address
          );
          const totalLiquidity = await dexContract.totalLiquidity();
          const userLiquidity = await dexContract.getLiquidity(
            deployer.address
          );
          const expectedEthtoWithdraw = value
            .mul(ethReserves)
            .div(totalLiquidity);
          const expectedTokentoWithdraw = value
            .mul(tokenReserves)
            .div(totalLiquidity);

          const txWithdraw = await dexContract.withdraw(value);
          const txWithdrawReceipt = await txWithdraw.wait(1);
          expect(txWithdraw).to.emit(dexContract, "LiquidityRemoved");

          const finalUserLiquidity = await dexContract.getLiquidity(
            deployer.address
          );
          const finalTotalLiquidity = await dexContract.totalLiquidity();
          const finalUserReserves = await ethers.provider.getBalance(
            deployer.address
          );
          const finalUserTokens = await balloonsContract.balanceOf(
            deployer.address
          );
          assert.equal(
            txWithdrawReceipt.events[1].args.withdrawer,
            deployer.address
          );
          assert.equal(
            txWithdrawReceipt.events[1].args.amount.toString(),
            value.toString()
          );
          assert.equal(
            txWithdrawReceipt.events[1].args.eth_amount.toString(),
            expectedEthtoWithdraw.toString()
          );
          assert.equal(
            txWithdrawReceipt.events[1].args.token_amount.toString(),
            expectedTokentoWithdraw.toString()
          );
          assert.equal(
            txWithdrawReceipt.events[1].args.userLiquidity.toString(),
            userLiquidity.sub(value).toString()
          );
          assert.equal(
            txWithdrawReceipt.events[1].args.totalLiquidity.toString(),
            totalLiquidity.sub(value).toString()
          );
          assert(
            finalUserReserves.toString() <=
              initialUserReserves.add(expectedEthtoWithdraw).toString()
          );
          assert(
            finalUserTokens.toString() <=
              initialUserTokens.add(expectedTokentoWithdraw).toString()
          );
        });
      });
    });
  });
});
