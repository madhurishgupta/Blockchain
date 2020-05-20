const set = async () => {     
    var text = document.getElementById("newMessage").value;
    let result = await contract.methods.setMessage(text).send({"from":"0xf251004e28925cb1b4beb3abc6184e823d3c8499"});
    var message = await get();
    var elm = document.getElementById('message');
    elm.innerHTML = message;
}