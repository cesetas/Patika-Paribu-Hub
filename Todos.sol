// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract Todos{
    //A todo model create as a struct
    struct Todo {
        string todo;
        bool isCompleted;
    }

    Todo[]  public  todos; //Each todo will keep in an array 

    //A newTodo will push into array just after creating it
    //with the string text parameter
    function addTodo(string calldata _todo) public {
        Todo memory newTodo = Todo(_todo,false);
        todos.push(newTodo);
    }

    //This function uptade a todo in an given index
    function updateTodo(uint index, string memory text) public{
        todos[index].todo = text;

    }

    //This function is for updating the completeness state of a todo 
    function completeTodo(uint index)public{
        todos[index].isCompleted = !todos[index].isCompleted;
    }

    //This functios is for getting a todo in a specified index
    function getTodo(uint index) public view returns(string memory, bool){
        Todo memory todo = todos[index];
        return (todo.todo, todo.isCompleted);
    }

}