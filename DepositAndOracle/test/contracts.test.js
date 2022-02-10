const A = artifacts.require('A');
const B = artifacts.require('B');
const ERC = artifacts.require('ERC20');

function arrEquals(arr1, arr2) {
    if(arr1.length != arr2.length) return false;
    for(let i = 0; i < arr1.length; i++) {
      if(arr1[i] != arr2[i]) return false;
    }
    return true;
}

async function successCheck (storage, dep) {
    let accounts = await web3.eth.getAccounts();
    let res = await storage.locateDeposit(accounts[0], 0);
    let cmp = [res[0], res[1], res[2].toNumber()];
    return assert(arrEquals(cmp, dep));
}

contract('Test', () => {
    it('Deposit information gets passed', async () => {
        let accounts = await web3.eth.getAccounts();
        let tokenAmount = 1;
        let [a, b, erc] = [await A.deployed(), await B.deployed(), await ERC.deployed()];
        let dep = [accounts[0], erc.address, tokenAmount];
        await a.updateContract(b.address);
        await b.updateOwnership("a", a.address);
        await erc._mint(accounts[0], tokenAmount);
        await erc.approve(a.address, tokenAmount);
        await a.deposit(erc.address, tokenAmount);
        assert(successCheck(b, dep));
    });

    it('Insert deposit succeeds', async () => {
        let accounts = await web3.eth.getAccounts();
        let tokenAmount = 1;
        let [b, erc] = [await B.deployed(), await ERC.deployed()];
        let dep = [accounts[0], erc.address, tokenAmount];
        await b.updateOwnership("admin", accounts[0]);
        await b.depositComplete(dep[0], dep[1], dep[2]);
        assert(successCheck(b, dep));
    })
});
