pragma solidity ^0.8.7;

contract Todos{
    struct Todo {
        string todo;
        bool isCompleted;
    }

    Todos[] public todos;

    function addTodo(string memory _todo) public {
        todos.push({todo:_todo, isCompleted:false})
    }
    function updateTodo(uint index, string memory text) public{
        Todos[index].todo = text;

    }

    function completeTodo(uint index)public{
        Todos[index].isCompleted = Todos[index].!isCompleted;
    }

    function getTodo(uint index) public pure returns(string){
        return Todos[index].todo;
    }

}