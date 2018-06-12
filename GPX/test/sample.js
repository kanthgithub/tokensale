
const Sample = artifacts.require("Sample");


contract('Sample', function (accounts) {

    it("Check Variable 1", async function () {

        var instance = await Sample.new();
        
        console.log(await instance.add.call());
        console.log(await instance.add.call());
        console.log(await instance.add.call());

    });

    it("Check Variable 2", function () {

        var instance;
        return Sample.new().then(function(_instance) {
            instance = _instance;
            return instance.add.call();
        }).then(function(num) {
            console.log(num);
            return instance.add.call();
        }).then(function(num) {
            console.log(num);
            return instance.add.call();
        }).then(function(num) {
            console.log(num);
        });

    });


});

