// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract CarPark{
    struct Car{
        address payable owner;
        string name;
        string description;
        string image;
        uint amount;
        uint likes;
        uint dislikes;
        bool isSold;
    }

    event carBought(address indexed seller, address buyer, uint256 carIndex);
    event carAdded(address indexed owner, uint256 carIndex);
    event LikedCar(address indexed sender, uint256 carIndex, uint256 totalLikes);
    event DislikedCar(address indexed sender, uint256 carIndex, uint256 totalLikes);

    uint carLength = 0;

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    mapping(uint256=>Car) internal cars;
    mapping(address => mapping(uint256 => bool)) carLiked;
    mapping (address => mapping(uint256 => bool)) carDisliked;

    function addCar(
        string memory _name,
        string memory _description,
        string memory _image,
        uint _amount
    )public{
        cars[carLength] = Car(
            payable(msg.sender),
            _name,
            _description,
            _image,
            _amount,
            0,
            0,
            false
        );
        emit carAdded(msg.sender, carLength);
        carLength++;
    }

    function getCar(uint _index)public view returns(
        address payable,
        string memory,
        string memory,
        string memory,
        uint,
        uint,
        uint,
        bool
    ){
        Car memory car = cars[_index];
        return (
            car.owner,
            car.name,
            car.description,
            car.image,
            car.amount,
            car.likes,
            car.dislikes,
            car.isSold
        );
    }

    function likeCar(uint index) public {
        // uncomment the below line if you don't want people un-like the car.
        // require (carLiked[msg.sender][index] == false, "You have already liked this Car")
        if (carLiked[msg.sender][index] == false) {
            carLiked[msg.sender][index] = true; // liked the car
            cars[index].likes++;
            if (carDisliked[msg.sender][index] == true) {
                carDisliked[msg.sender][index] = false; // if the car was previously disliked by this person, we now decrement the dislikes as it likes the car now
                cars[index].dislikes--;
            }
        }
        emit LikedCar(msg.sender, index, cars[index].likes);
    }

    function dislikeCar(uint index) public {
        // uncomment the below line if you don't want people "un-dislike" the car.
        // require (carDisliked[msg.sender][index] == false, "You have already Disliked this Car")
        if (carDisliked[msg.sender][index] == false) {
            carDisliked[msg.sender][index] = true; // disliked the car
            cars[index].dislikes++;
            if (carLiked[msg.sender][index] == true) {
                carLiked[msg.sender][index] = false; // if the car was previously liked by this person, we now decrement the likes as it dislikes the car now
                cars[index].likes--;
            }
        }
        emit DislikedCar(msg.sender, index, cars[index].dislikes);
    }

    function buyCar(uint index) public payable {
        require(
             IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                cars[index].owner,
                cars[index].amount * 1000000000000000000
            ),
            "Transaction could not be performed"
        );
        cars[index].isSold = true;
        emit carBought(cars[index].owner, msg.sender, index);
        cars[index].owner = payable(msg.sender);

    }

    function sellCar(uint _index) public {
        require(cars[_index].owner == msg.sender, "Only owners can sell car");
        cars[_index].isSold = false;
    }

    function getCarLength() public view returns(uint){
        return carLength;
    }
}
