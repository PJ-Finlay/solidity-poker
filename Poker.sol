pragma solidity >=0.7.0 <0.8.0;

contract Poker {
    uint constant STAKES = 100;
    function getStakes() public view returns(uint) { return STAKES; }
    
    int debug = 0;
    function getDebug() public view returns(int) { return debug; }
    
    // Registering
    address payable player1 = payable(address(this));
    int registeredValue1 = 0;
    address payable player2 = payable(address(this));
    int registeredValue2 = 0;
    function register(int value) public payable returns(bool) {
        if (msg.value < STAKES) {
            return false;
        }
        bool player1Registered = registeredValue1 != 0;
        bool player2Registered = registeredValue2 != 0;
        if (!player1Registered) {
            registeredValue1 = value;
            player1 = msg.sender;
            return true;
        } else if (!player2Registered) {
            registeredValue2 = value;
            player2 = msg.sender;
            return true;
        }
        return false;
    }
    function getRegisteredValue1() public view returns(int) { return registeredValue1; }
    function getRegisteredValue2() public view returns(int) { return registeredValue2; }
    function getPlayer1() public view returns(address) { return player1; }
    function getPlayer2() public view returns(address) { return player2; }

    // Game
    enum GameState {NOT_STARTED, DONE}
    GameState gameState = GameState.NOT_STARTED;
    int player1Score = 0;
    int player2Score = 0;
    address payable winner = payable(address(this));
    function runGame() public {
        if (gameState != GameState.DONE) {
            debug = 1;
            player1Score = int(keccak256(abi.encodePacked(registeredValue1, msg.sender, blockhash(block.number - 1))));
            player2Score = int(keccak256(abi.encodePacked(registeredValue2, msg.sender, blockhash(block.number - 1))));
            if (player1Score > player2Score) {
                debug = 2;
                winner = player1;
            } else {
                debug = 3;
                winner = player2;
            }
            winner.send(STAKES);
        }
    }
    function getPlayer1Score() public view returns(int) { return player1Score; }
    function getPlayer2Score() public view returns(int) { return player2Score; }
    
    // https://ethereum.stackexchange.com/questions/62375/best-practices-for-generating-a-random-uint256
    int randValue = 0;
    int randCounter = 0;
    function rand() public {
        randValue =  int(keccak256(abi.encodePacked(randCounter, msg.sender, blockhash(block.number - 1))));
    }
    function getRandValue() public view returns(int) {
        return randValue;
    }
}
