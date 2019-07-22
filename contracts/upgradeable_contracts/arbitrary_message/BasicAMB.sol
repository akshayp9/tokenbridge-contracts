pragma solidity 0.4.24;

import "../../upgradeability/EternalStorage.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../Validatable.sol";
import "../BasicBridge.sol";

contract BasicAMB is BasicBridge {
    bytes internal constant SUBSIDIZED_MODE = bytes(abi.encodePacked("AMB-subsidized-mode"));
    bytes internal constant DEFRAYAL_MODE = bytes(abi.encodePacked("AMB-defrayal-mode"));

    function initialize(
        address _validatorContract,
        uint256 _maxGasPerTx,
        uint256 _gasPrice,
        uint256 _requiredBlockConfirmations,
        address _owner
    ) public returns (bool) {
        require(!isInitialized());
        require(_validatorContract != address(0) && isContract(_validatorContract));
        require(_gasPrice > 0);
        require(_requiredBlockConfirmations > 0);
        require(_maxGasPerTx > 0);
        addressStorage[keccak256(abi.encodePacked("validatorContract"))] = _validatorContract;
        uintStorage[keccak256(abi.encodePacked("deployedAtBlock"))] = block.number;
        uintStorage[keccak256(abi.encodePacked("maxGasPerTx"))] = _maxGasPerTx;
        uintStorage[keccak256(abi.encodePacked("gasPrice"))] = _gasPrice;
        uintStorage[keccak256(abi.encodePacked("requiredBlockConfirmations"))] = _requiredBlockConfirmations;
        bytesStorage[keccak256(abi.encodePacked("homeToForeignMode"))] = DEFRAYAL_MODE;
        bytesStorage[keccak256(abi.encodePacked("foreignToHomeMode"))] = DEFRAYAL_MODE;
        setOwner(_owner);
        setInitialize();
        return isInitialized();
    }

    function getBridgeMode() external pure returns (bytes4 _data) {
        return bytes4(keccak256(abi.encodePacked("arbitrary-message-bridge-core")));
    }

    function setSubsidizedModeForHomeToForeign() external onlyOwner {
        bytesStorage[keccak256(abi.encodePacked("homeToForeignMode"))] = SUBSIDIZED_MODE;
    }

    function setDefrayalModeForHomeToForeign() external onlyOwner {
        bytesStorage[keccak256(abi.encodePacked("homeToForeignMode"))] = DEFRAYAL_MODE;
    }

    function setSubsidizedModeForForeignToHome() external onlyOwner {
        bytesStorage[keccak256(abi.encodePacked("foreignToHomeMode"))] = SUBSIDIZED_MODE;
    }

    function setDefrayalModeForForeignToHome() external onlyOwner {
        bytesStorage[keccak256(abi.encodePacked("foreignToHomeMode"))] = DEFRAYAL_MODE;
    }

    function homeToForeignMode() public view returns (bytes) {
        return bytesStorage[keccak256(abi.encodePacked("homeToForeignMode"))];
    }

    function foreignToHomeMode() public view returns (bytes) {
        return bytesStorage[keccak256(abi.encodePacked("foreignToHomeMode"))];
    }

    function maxGasPerTx() public view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("maxGasPerTx"))];
    }

    function setMaxGasPerTx(uint256 _maxGasPerTx) external onlyOwner {
        require(_maxGasPerTx > 0);
        uintStorage[keccak256(abi.encodePacked("maxGasPerTx"))] = _maxGasPerTx;
    }
}
