LIBRARY MANAGEMENT SYSTEM

Project Overview

This comprehensive Library Management System database provides a complete solution for modern libraries, handling everything from book inventory management to patron services.        The system manages:  
Book catalog with detailed metadata  
Physical book copies and their current status  
Library members and their membership information  
Staff management  
Book loans and returns  
Fines and payments  
Reservations  
Events and attendance

Features  
Core Functionality  
Book Management: Catalog and track books, authors, publishers, categories  
Inventory Control: Track individual book copies, their status, condition, and location  
Member Management: Register members, track membership status, handle renewals  
Circulation Management: Process loans, returns, and renewals  
Fine Management: Calculate and track fines for late returns or damaged books  
Reservation System: Allow members to reserve books  
Event Management: Organize and track library events and attendees    

Advanced Features  
Views for common queries (available books, active loans, overdue books)  
Stored Procedures for complex operations (check out books, return books, renew loans)  
Triggers for automated actions (updating book status, handling reservations)    

Database Schema  
The database consists of the following main tables:  
books: Stores book metadata (title, ISBN, etc.)  
book_copies: Tracks individual copies of books  
authors: Stores author information  
publishers: Stores publisher information  
categories: Stores book categories/genres  
members: Stores library member information  
staff: Stores library staff information  
book_loans: Tracks borrowing transactions  
fines: Tracks fines for late returns or damaged books  
reservations: Tracks book reservations  
events: Stores information about library events  
event_attendees: Tracks event participation    

Entity Relationship Diagram (ERD)    
                                  ┌──────────────┐
                                  │  categories  │
                                  └──────┬───────┘
                                         │
                                         │
┌──────────┐       ┌──────────┐     ┌────▼─────┐     ┌────────────┐
│  authors  │◄────►│book_authors│◄───┤   books  │────►│ publishers │
└──────────┘       └──────────┘     └────┬─────┘     └────────────┘
                                         │
                                         │
                                   ┌─────▼──────┐
                                   │book_copies │
                                   └─────┬──────┘
                                         │
                                         │
┌──────────┐     ┌──────────┐      ┌─────▼─────┐      ┌─────────┐
│   staff  │────►│book_loans │◄─────┤  members  │◄────►│  fines  │
└──────────┘     └─────┬────┘      └─────┬─────┘      └─────────┘
                       │                  │
                       │                  │
                  ┌────▼─────┐      ┌─────▼──────────┐
                  │  fines   │      │  reservations  │
                  └──────────┘      └────────────────┘
                                         │
                                         │
                                    ┌────▼────┐     ┌────────────────┐
                                    │  events │────►│event_attendees │
                                    └─────────┘     └────────────────┘

Setup Instructions  
Prerequisites  
MySQL Server 5.7+   
MySQL Workbench or similar client (optional)    

Installation  
Clone the repository  
git clone https://github.com/Barno-J/library-mgnt-system-Database-8.git  
cd library-management-system    

Import the database  
Using MySQL command line:  
mysql -u username -p < library_management.sql    

Verify installation  
mysql -u username -p  
USE library_management;  
SHOW TABLES;    

Technologies Used  
MySQL Workbench - Database system  
SQL - For database queries and operations    

Contributors  
Barno June
