
const MultiOwnable = artifacts.require("MultiOwnable");


contract('MultiOwnable', function (accounts) {

    it("Check Co-Owners", async function () {
        let instance = await MultiOwnable.new(
            [accounts[1]],
            2
        );
        assert.equal(accounts.length, 10);
        assert.isTrue(await instance.isOwner(accounts[0]));
        assert.isTrue(await instance.isOwner(accounts[1]));
        assert.isFalse(await instance.isOwner(accounts[2]));
    });

});

