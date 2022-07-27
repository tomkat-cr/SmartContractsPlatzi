// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Reto 1: (1) Crear un contrato para un proyecto de Crownfunding y agregar variables de estado.

contract CrowdFundingCarlos {

    string public id;
    string public name;
    string public description;
    uint256 public fundraisingGoal; // wei
    address payable public author;

    string public state = "Opened";
    uint256 public funds;   // wei

    // Reto 4: (?) Crea una validacion para que el estado solo se pueda actualizar con valores predefinidos.
    error StateNotDefined(string id, string newState);

    // Reto 4: (1) Crea una validacion para que no se pueda aportar al proyecto si el estado es "Closed".
    error StateIsClosed(string id, string newState);

    // Reto 4: (2) Crea una validacion para que no se pueda actualizar un estado, este debe ser diferente al actual.
    error StateMustBeDifferent(string id, string newState);

    // Reto 4: (3) Crea una validacion para que no se pueda hacer aportes con valor cero.
    error ValueMustBeGreaterThanZero(string id, uint256 value);

    // Reto 3: (2) Piensa que informacion sera relevante para los subscriptores del evento.
    event ProjectFunded(string projectId, uint256 value);
    event ProjectStateChanged(string id, string state);

    // Reto 2: (1) Usa un function modifier para permitir que solo el autor pueda cambiar el estado.
    modifier isAuthor() {
        require(
            author == msg.sender,
            "You need to be the project author to change this contract's state variables"
        );
        // Aqui en e; lugar del "_" se inserta la funcion modificada.
        _;
    }

    // Reto 2: (2) Usa un function modifier para evitar que un autor pueda aportar a su propio proyecto.
    modifier isNotAuthor() {
        require(
            author != msg.sender,
            "As author you can not fund your own project"
        );
        _;
    }

    constructor(
        string memory _id,
        string memory _name,
        string memory _description,
        uint256 _fundraisingGoal
    ) {
        id = _id;
        name = _name;
        description = _description;
        fundraisingGoal = _fundraisingGoal; // wei
        // Se debe aplicar la funcion payable() a msg.sender
        // para equipararlo a la condicion payable de author.
        author = payable(msg.sender);
    }

    // Reto 1: (2) Crear una funcion fundProject que permita enviar ether a un proyecto.
    // Reto 3: (1) Añade eventos a las funciones 'fundProject' y 'changeProjectState'.
    function fundProject() public payable isNotAuthor {
        if (!compareStrings(state, "Closed")) {
            if (msg.value > 0) {
                // El valor de msg.value esta en terminos de wei,
                // asi que todos los montos del contrato se deben tratar de la misma manera...
                author.transfer(msg.value);
                funds += msg.value;
                emit ProjectFunded(id, msg.value);
            } else {
                // Reto 4: (3) Crea una validacion para que no se pueda hacer aportes con valor cero.
                revert ValueMustBeGreaterThanZero(id, msg.value);
            }
        } else {
            // Reto 4: (1) Crea una validacion para que no se pueda aportar al proyecto si el estado es "Closed".
            revert StateIsClosed(id, state);
        }
    }

    // Reto 1: (3) Crear una funcion ChangeProjectState que permita cambiar el estado proyecto.
    // Reto 3: (1) Añade eventos a las funciones 'fundProject' y 'changeProjectState'.
    function changeProjectState(string calldata newState) public isAuthor {
        //require(newState != "Opened" && newState != "Closed", "This state is not defined");
        //require(newState == state, "The new state must be diffenrent than the current one");
        if(compareStrings(newState, "Opened") || compareStrings(newState, "Closed")) {
            if(!compareStrings(newState, state)) {
                state = newState;
                emit ProjectStateChanged(id, state);
            } else {
                // Reto 4: (2) Crea una validacion para que no se pueda actualizar un estado, este debe ser diferente al actual.
                revert StateMustBeDifferent(id, newState);
            }
        } else {
            // Reto 4: (?) Crea una validacion para que el estado solo se pueda actualizar con valores predefinidos.
            revert StateNotDefined(id, newState);
        }
    }

    // https://ethereum.stackexchange.com/questions/30912/how-to-compare-strings-in-solidity
    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
