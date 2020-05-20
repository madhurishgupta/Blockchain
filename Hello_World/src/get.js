const get = async () => {               
    let message = await contract.methods.getMessage().call();    
    return message;
}    