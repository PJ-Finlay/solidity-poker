pragma solidity >=0.7.0 <0.8.0;

contract Poker {
    uint constant STAKES = 100;
    uint constant RESERVE = 50;
    function getStakes() public view returns(uint) { return STAKES; }
    function getReserve() public view returns(uint) { return RESERVE; }
    
    int debug = 0;
    function getDebug() public view returns(int) { return debug; }
    
    // Registering
    address payable player1 = payable(address(this));
    int registeredValue1 = 0;
    uint player1Balance = 0;
    uint player1Reserve = 0;
    address payable player2 = payable(address(this));
    int registeredValue2 = 0;
    uint player2Balance = 0;
    uint player2Reserve = 0;
    function register(int value) public payable returns(bool) {
        if (value == 0) { return false; } // 0 is default value
        if (msg.value < STAKES) {
            return false;
        }
        bool player1Registered = registeredValue1 != 0;
        bool player2Registered = registeredValue2 != 0;
        if (!player1Registered) {
            registeredValue1 = value;
            player1 = msg.sender;
            player1Balance = msg.value - RESERVE;
            player1Reserve = RESERVE;
            return true;
        } else if (!player2Registered) {
            registeredValue2 = value;
            player2 = msg.sender;
            player2Balance = msg.value - RESERVE;
            player2Reserve = RESERVE;
            return true;
        }
        return false;
    }
    function getRegisteredValue1() public view returns(int) { return registeredValue1; }
    function getRegisteredValue2() public view returns(int) { return registeredValue2; }
    function getPlayer1() public view returns(address) { return player1; }
    function getPlayer2() public view returns(address) { return player2; }
    function getPlayer1Balance() public view returns(uint) { return player1Balance; }
    function getPlayer2Balance() public view returns(uint) { return player2Balance; }
    function getPlayer1Reserve() public view returns(uint) { return player1Reserve; }
    function getPlayer2Reserve() public view returns(uint) { return player2Reserve; }
    
    // Cash out
    function cashOut() public {
        if (payable(address(msg.sender)) == player1) {
            if (player1Balance > 0) {
                player1.transfer(player1Balance);
                player1Balance = 0;
            }
        }
        else if (payable(address(msg.sender)) == player2) {
            if (player2Balance > 0) {
                player2.transfer(player2Balance);
                player1Balance = 0;
            }
        }
        
        // End of game
        if (player1Balance == 0 && player2Balance == 0 &&
                player1Reserve == RESERVE && player2Reserve == RESERVE) {
            player1.transfer(player1Reserve);
            player2.transfer(player2Reserve);
            player1Reserve = 0;
            player2Reserve = 0;
            registeredValue1 = 0;
            registeredValue2 = 0;
        }
    }

    // Game
    enum GameState {NOT_STARTED, DONE}
    GameState gameState = GameState.NOT_STARTED;
    int player1Score = 0;
    int player2Score = 0;
    address payable winner = payable(address(this));
    function runGame() public {
        if (gameState != GameState.DONE) {
            player1Score = int(keccak256(abi.encodePacked(registeredValue1, msg.sender, blockhash(block.number - 1))));
            player2Score = int(keccak256(abi.encodePacked(registeredValue2, msg.sender, blockhash(block.number - 1))));
            if (player1Score > player2Score) {
                winner = player1;
            } else {
                winner = player2;
            }
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
