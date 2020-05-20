pragma solidity 0.5.16;

contract HelloWorld {
    string private message = "Hello World !!";

    function getMessage() public returns(string memory) {
        return message;
    }

    function setMessage(string memory _message) public {
        message = _message;
    }
}