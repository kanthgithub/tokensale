
const MultiOwnable = artifacts.require("MultiOwnable");


contract('MultiOwnable', function (accounts) {

    it("Check Single Owner", async function () {
        let instance = await MultiOwnable.new(
            [accounts[0], accounts[1], accounts[2]],
            2
        );
        assert.equal(accounts.length, 10);
        assert.isTrue(await instance.isOwner(accounts[0]));
        assert.isTrue(await instance.isOwner(accounts[1]));
        assert.isTrue(await instance.isOwner(accounts[2]));
        assert.isFalse(await instance.isOwner(accounts[3]));
    });

});

