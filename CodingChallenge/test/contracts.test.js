const A = artifacts.require('A');
const B = artifacts.require('B');
const ERC = artifacts.require('ERC20');

contract('Test', () => {
    it('Deposit information gets passed', async () => {
        let accounts = await web3.eth.getAccounts();
        let tokenAmount = 1;
        const [a, b, erc] = [await A.deployed(), await B.deployed(), await ERC.deployed()];
        await a.updateContract(b.address);
        await b.updateOwnership("a", a.address);
        await erc._mint(accounts[0], tokenAmount);
        await erc.approve(a.address, tokenAmount);
        await a.deposit(erc.address, tokenAmount);
        assert(b.locateDeposit(accounts[0], 0) != '');
    });

    it('Insert deposit returns', async () => {
        let accounts = await web3.eth.getAccounts();
        let tokenAmount = 1;
        const [b, erc] = [await B.deployed(), await ERC.deployed()];
        await b.updateOwnership("admin", accounts[0]);
        b.depositComplete(accounts[0], erc.address, tokenAmount);
        assert(b.locateDeposit(accounts[0], 0) != '');
    })
});