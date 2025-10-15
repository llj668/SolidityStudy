// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract StructExample{
    // 定义一个名为Book的结构体

    struct Book{
        uint id;
        string title;
        address author;
        bool isPublished;
    }

    // 状态变量，存储在 storage
    Book public myFavoriteBook; 

    // 初始化 方法一：使用键值对（推荐） 
    function createBookInMemory() public view returns (Book memory){
        Book memory newBook = Book({
            id: 1,
            title: "Learning Solidity",
            author: msg.sender,
            isPublished:true
        });
        return newBook;
    }

    // 方法二：使用位置参数
    // 按结构体成员定义的顺序传入参数。这种方法可读性较差，且容易出错
    function createAnotherBook() public view returns (Book memory) {
        // 必须严格按照 id, title, author, isPublished 的顺序
        Book memory anotherBook = Book(2, "Advanced Solidity", msg.sender, false);
        return anotherBook;
    }

    // 方法三：逐个成员赋值
    function setMyFavoriteBook() public {
        myFavoriteBook.id = 3;
        myFavoriteBook.title = "DeFi Deep Dive";
        myFavoriteBook.author = address(this);
        myFavoriteBook.isPublished = true;
    }

    // 方法三：逐个成员赋值
    function setMyFavoriteBook1() public view{
        Book memory myFavoriteBook1; 
        myFavoriteBook1.id = 3;
        myFavoriteBook1.title = "DeFi Deep Dive";
        myFavoriteBook1.author = address(this);
        myFavoriteBook1.isPublished = true;
    }


}