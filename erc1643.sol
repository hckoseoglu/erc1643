// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IERC1643 {

    // Document Management
    function getDocument(bytes32 _name) external view returns (string memory, bytes32, uint256);
    function setDocument(bytes32 _name, string memory _uri, bytes32 _documentHash) external;
    function removeDocument(bytes32 _name) external;
    function getAllDocuments() external view returns (bytes32[] memory);

    // Document Events
    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);
}

contract DocumentManager is IERC1643 {

    struct Document {
        string uri;
        bytes32 documentHash;
        uint256 timestamp;
    }

    mapping(bytes32 => Document) private _documents; // name -> document
    mapping(uint => bytes32) private _docNames; // index -> document name
    uint256 public noOfDocs = 0;

    function getDocument(bytes32 _name) public view override returns (string memory, bytes32, uint256){
        Document memory doc = _documents[_name];
        return (doc.uri, doc.documentHash, doc.timestamp);
    }

    function setDocument(bytes32 _name, string memory _uri, bytes32 _documentHash) public override{
        Document storage doc = _documents[_name];
        if(doc.timestamp == 0){
            _docNames[noOfDocs] = _name;
            noOfDocs += 1;
        }
        else{
            emit DocumentUpdated(_name, _uri, _documentHash);
        }
        doc.timestamp = block.timestamp;
        doc.uri = _uri;
        doc.documentHash = _documentHash;
    }

    function removeDocument(bytes32 _name) public override {
        bool arrivedIdx = false;
        for(uint256 i = 0; i < noOfDocs; i++){
            if(_docNames[i] == _name){
                arrivedIdx = true;
            }
            if(arrivedIdx){
                _docNames[i] = _docNames[i + 1];
            }
        }
        Document memory doc = _documents[_name];
        require(doc.timestamp != 0);
        delete _documents[_name];
        noOfDocs -= 1;
        emit DocumentRemoved(_name, doc.uri, doc.documentHash);
    }

    function getAllDocuments() public view override returns (bytes32[] memory){
        bytes32[] memory names = new bytes32[](noOfDocs);
        for(uint256 i = 0; i < noOfDocs; i++){
            names[i] = _docNames[i];
        }
        return names;
    }
}
