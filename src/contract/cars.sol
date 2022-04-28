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

contract CarPark {
    struct Car {
        address payable owner;
        string name;
        string description;
        string image;
        uint256 amount;
        address[] likes; 
        address[] dislikes;
        bool isSold;
    }

    uint256 carLength = 0;

    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    mapping(uint256 => Car) internal cars;

    function addCar(
        string memory _name,
        string memory _description,
        string memory _image,
        uint256 _amount
    ) public {
        address[] memory likes;
        address[] memory dislikes;
        cars[carLength] = Car(
            payable(msg.sender),
            _name,
            _description,
            _image,
            _amount,
            likes,
            dislikes,
            false
        );
        carLength++;
    }

    function getCar(uint256 _index)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            string memory,
            uint256,
            address[] memory,
            address[] memory,
            bool
        )
    {
        Car storage car = cars[_index];
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

    function likeCar(uint256 index) public {        
        address[] storage likesArr = cars[index].likes;
        address[] storage dislikesArr = cars[index].dislikes;

        // prevent users from liking infinite number of times
        for (uint i = 0; i < likesArr.length; i++) {
            if (payable(msg.sender) == likesArr[i]) {
                return; // exit the function
            }
        }

        // un-dislike car if user previously disliked car        
        for (uint i = 0; i < dislikesArr.length; i++) {
            if (payable(msg.sender) == dislikesArr[i]) {
                // remove users address from dislikes array
                dislikesArr[i] = dislikesArr[dislikesArr.length - 1];
                dislikesArr.pop();
                break;
            }        
        }

        // like the car
        likesArr.push(payable(msg.sender));
    }

    function dislikeCar(uint256 index) public {
        address[] storage likesArr = cars[index].likes;
        address[] storage dislikesArr = cars[index].dislikes;

         // prevent users from disliking infinite number of times
        for (uint i = 0; i < dislikesArr.length; i++) {
            if (payable(msg.sender) == dislikesArr[i]) {
                return; // exit the function
            }
        }

         // un-like car if user previously disliked car            
        for (uint i = 0; i < likesArr.length; i++) {
            if (payable(msg.sender) == likesArr[i]) {
                // remove users address from likes array
                likesArr[i] = likesArr[likesArr.length - 1];
                likesArr.pop();
                break;
            }
        }

        // dislike the car
        dislikesArr.push(payable(msg.sender));
    }

    function buyCar(uint256 index) public payable {
        // first check if has enough funds to spend
        require(payable(msg.sender).balance / 1 ether >= cars[index].amount, "Insufficient funds!");
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                cars[index].owner,
                cars[index].amount
            ),
            "Transaction could not be performed"
        );
        cars[index].isSold = true;
        cars[index].owner = payable(msg.sender);
    }

    function sellCar(uint256 _index) public {
        require(cars[_index].owner == msg.sender, "Only owners can sell car");
        cars[_index].isSold = false;
    }

    function getCarLength() public view returns (uint256) {
        return carLength;
    }
}
