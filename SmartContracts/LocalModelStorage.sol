// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Local Storage
 * @dev Store & retrieve local model and dataset information
 */
contract LocalModelStorage {

    // Local model & dataset information
    struct LocalModel {
        bytes32 lid; // hash value of unique local model id
        bytes32 gid; // hash value of unique global model id
        bytes32 hyperparameters; // serialized value of hyperparameters (local & global model)
        bytes32 initial_parameters; // serialized value of initial parameters (local & global model)
        bytes32[] training_samples; // array of training samples hash values
        bytes32[] mini_batches; // array of mini-batches hash values
    }

	// mapping local model id to local model information
    mapping (bytes32 => LocalModel) private models;
    bytes32[] private ids;

	// emit the corresponding event when a local model 
	// is successfully stored in the blockchain
    event NewModelAdded(bytes32 _id, uint _timestamp, address indexed _from);

    function addModel(
        bytes32 _lid,
        bytes32 _gid,
        bytes32 _hyperparameters,
        bytes32 _initial_parameters,
        bytes32[] memory _training_samples,
        bytes32[] memory _mini_batches
    ) public returns (bool) {
        bool success = false;
        bool found = false;
        for (uint i=0; i < ids.length; i++) {
            if (ids[i] == _lid) {
                found = true;
                break;
            }
        }
        if (!found) {
            models[_lid] = LocalModel({
                lid: _lid,
                gid: _gid,
                hyperparameters: _hyperparameters,
                initial_parameters: _initial_parameters,
                training_samples: _training_samples,
                mini_batches: _mini_batches
            });
            ids.push(_lid);
            emit NewModelAdded(_lid, block.timestamp, msg.sender);
            success = true;
        }
        return success;
    }

    function addTrainingSample(bytes32 _lid, bytes32 _training_sample) public {
        models[_lid].training_samples.push(_training_sample);
    }

    function addMiniBatch(bytes32 _lid, bytes32 _mini_batch) public {
        models[_lid].mini_batches.push(_mini_batch);
    }

    function getModelIds()  public view returns (bytes32[] memory) {
        return ids;
    }

    function getLocalModels() public view returns (LocalModel[] memory) {
        LocalModel[] memory localModels = new LocalModel[](ids.length);
        for (uint i=0; i < ids.length; i++) {
            localModels[i] = models[ids[i]];
        }
        return localModels;
    }
	
    function getModelInformation(bytes32 _lid) public view returns 
        (
            bytes32,
            bytes32,
            bytes32,
            bytes32,
            bytes32[] memory,
            bytes32[] memory
        ) {
        LocalModel memory model = models[_lid];
        return (
            model.lid,
            model.gid,
            model.hyperparameters,
            model.initial_parameters,
            model.training_samples,
            model.mini_batches
        );
    }
}