// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Global Model Storage
 * @dev Store, retrieve and aggregate global model parameters
 */
contract GlobalModelStorage {

    
    bytes32 private gid; // hash value of unique global model id
    bytes32[] private model_config; // array of model configuration serialized values
    bytes32[] private model_weights; // array of model weights serialized values
    bytes32[][] private client_params; // 2D array of each client model serialized parameters
    address[] private clients; // array of clients participate in the current round
    address private last_upload_client; // address of last client who uploaded his parameters
    address private aggregator; // address of aggregation server in the current round
    uint256 private round = 1; // round counter

    // events
    event ModelParametersUploded(bytes32 _gid, uint256 _round, uint _timestamp);
    event ModelWeightsUpdated(bytes32 _gid, uint256 _round, uint _timestamp);
    event AggregatorPropagation(bytes32 _gid, uint256 _round, address indexed _aggregator);

    function setModelConfig(bytes32[] memory _config) public {
        for (uint i=0; i < _config.length; i++) {
            model_config.push(_config[i]);
        }
    }

    function getModelConfig() public view returns (bytes32[] memory) {
        return model_config;
    }

    function setBaseModelWeights(bytes32[] memory _model_weights) public {
        for (uint i=0; i < _model_weights.length; i++) {
            model_weights.push(_model_weights[i]);
        }
    }

    // each client that retrieves the model, participates in the current round
    function getModelWeights() public returns (bytes32[] memory) {
        clients.push(msg.sender);
        return model_weights;
    }

    // each client locally takes one step of gradient descent 
    // on the current model using his local data
    // and uploads the results
    // if he is the last one, picks up an aggregator
    function uploadClientParameters(bytes32[] memory k_params) public {
        client_params.push(k_params);
        if (client_params.length == clients.length) {
            last_upload_client = msg.sender;
            emit ModelParametersUploded(gid, round, block.timestamp);
            pickAggregator();
        }
    }

    // create a random hash
    function random() private view returns(uint) {
        return uint (keccak256(abi.encode(block.timestamp,  clients)));
    }

    // pick randomly the node 
    // that aggregates all the client parameters 
    // and applies the update
    function pickAggregator() private {
        require(msg.sender == last_upload_client);
        uint k = random() % clients.length;
        aggregator = clients[k];
        emit AggregatorPropagation(gid, round, aggregator);
    }

    // fetch current model & all client parameters (Aggregator only)
    function fetch_model() public view restricted returns (bytes32[] memory, bytes32[][] memory) {
        return (model_weights, client_params);
    }

    // model update (Aggregator only)
    function update_model(bytes32[] memory _model_weights) public restricted returns (bool) {
        model_weights = new bytes32[](0);
        for (uint i=0; i < _model_weights.length; i++) {
            model_weights.push(_model_weights[i]);
        }
        clients = new address[](0);
        client_params = new bytes32[][](0);
        emit ModelWeightsUpdated(gid, round, block.timestamp);
        round += 1;
        return true;
    }

    modifier restricted() {
        require(msg.sender == aggregator);
        _;
    }
}
