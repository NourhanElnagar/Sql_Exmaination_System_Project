
-- stored insert into Question take(q-Body, q-mark, q-typeId, CrsId, insId)
Create Procedure  sp_InsertQuestion
  @Body          varchar(150),
  @Mark          tinyint,
  @TypeID        int,
  @CrsID         int,
  @InsID         int
AS
Begin
  Begin try
	--typeId exit or not
    if not exists (select 1 from QuestionTypes where ID = @TypeID)
    Begin
      print 'Error cannot insert question, TypeID not exist in QuestionTypes table.';
      RETURN;
    End

	 -- instructor  in course
	 if not exists (select 1 from CoursesInstructors where CrsID=@CrsID and InsID =@InsID)
    Begin
      print 'Error cannot insert question, InsID not teach this Course.';
      RETURN;
    End

	--q-body exit in this course before or not
    if exists (select 1 from Question where CrsID = @CrsID and Body = @Body)
    Begin
      print 'Error cannot insert, question already in this course.';
      RETURN;
    End

    insert into Question (Body, Mark, TypeID, CrsID, InsID)
    values (@Body, @Mark, @TypeID, @CrsID, @InsID);

    print 'Question inserted successfully.';
  End try
  Begin catch
    print 'Error occurred: ' + ERROR_MESSAGE();
  End catch
End;
Go

 -- stored update into Question take (QuestionID , NewBody, newMark  )
Create Procedure sp_UpdateQuestion
  @QuestionID   int,
  @NewBody      varchar(150),
  @newMark      tinyint

AS
Begin
  Begin try
    if not exists (select 1 from Question where ID = @QuestionID)
    Begin
      print 'Error: Question ID does not exist in Question table.';
      RETURN;
    End

	if not exists (select 1 from ExamQuestions where QuestionID = @QuestionID)
	begin
		update Question
		set Body = @NewBody, Mark = @newMark, CorrectAnswer= null
		where ID = @QuestionID;

	   delete from QuestionOptions
		where QuestionID = @QuestionID;

	print 'Question updated successfully.';
	end

	else
	begin
		print 'Cannot  updated Question ,Question Exists in Exam .';
	end

   End try
   Begin catch
    print 'Error occurred: ' + ERROR_MESSAGE();
  End catch
End;
GO


 -- stored delete  Question take (QuestionID)
Create Procedure sp_DeleteQuestion
  @QuestionID int
AS
Begin
  Begin try
    if not exists (select 1 from Question where ID = @QuestionID)
    Begin
      print 'Error: Question ID does not exist in Question table.';
      return;
    End

	if  exists (select 1 from ExamQuestions where QuestionID = @QuestionID)
	Begin
		print 'Cannot Delete this question , already exists in Exam';
		return;
	End
	else
	Begin
		if  exists (select 1 from QuestionOptions where QuestionID = @QuestionID)
		Begin
			delete from QuestionOptions
			where QuestionID = @QuestionID;
		End
	
		delete from Question
		where ID = @QuestionID;
		print 'Successfully delete Question and this Options.';

	End
	 
  End try
  Begin catch
    print 'Error occurred: ' + ERROR_MESSAGE();
  End catch
End;
GO


--stored to select Question take(QuestionID )
alter  Procedure sp_SelectQuestion
  @QuestionID int = null
AS
Begin
  Begin try
    IF @QuestionID is null
    Begin
      select 
        Q.ID, QT.Type AS QuestionType, Q.Body, Q.Mark, Q.CorrectAnswer,
        C.Name AS Course, I.Fname + ' ' + I.Lname AS Instructor
      from Question Q
      join  QuestionTypes QT
	    on Q.TypeID = QT.ID
      join  Course C
	    on Q.CrsID = C.ID
      join  Instructor I 
	    on Q.InsID = I.ID
      order by Q.ID;
    End
    else
    Begin
      if not exists (select 1 from Question where ID = @QuestionID)
      Begin
        print 'Error: Question ID does not exist in Question table.';
        RETURN;
      End
       select 
        Q.ID, QT.Type AS QuestionType, Q.Body, Q.Mark, Q.CorrectAnswer,
        C.Name AS Course, I.Fname + ' ' + I.Lname AS Instructor
      from Question Q join QuestionTypes QT 
	   on Q.TypeID = QT.ID
      join Course C 
	   on Q.CrsID = C.ID
      join Instructor I 
		on Q.InsID = I.ID
      where 
        Q.ID = @QuestionID;
    End
  End try
  Begin catch
    print 'Error occurred: ' + ERROR_MESSAGE();
  End catch
End;
GO


-- change insid -type
-- insert True/False questions in c# course
Execute sp_InsertQuestion 
  @Body = 'C# is a case-sensitive programming language. (True/False)', 
  @Mark = 3, 
  @TypeID = 2,  
  @CrsID = 6,   
  @InsID = 1; 
  go
Execute sp_InsertQuestion 
  @Body = 'C# supports multiple inheritance for classes. (True/False)', 
  @Mark = 3, 
  @TypeID = 2,  
  @CrsID = 6,   
  @InsID = 1; 
  go
Execute sp_InsertQuestion 
  @Body = 'The "var" keyword in C# allows implicit typing. (True/False)', 
  @Mark = 3, 
  @TypeID = 2,  
  @CrsID = 6,   
  @InsID = 1; 
  go
Execute sp_InsertQuestion 
  @Body = 'C# does not support garbage collection. (True/False)', 
  @Mark = 3, 
  @TypeID = 2,  
  @CrsID = 6,   
  @InsID = 1; 
  go
Execute sp_InsertQuestion 
  @Body = 'A struct in C# can inherit from a class. (True/False)', 
  @Mark = 3, 
  @TypeID = 2,  
  @CrsID = 6,   
  @InsID = 1; 
  go


-- insert choose one questions in c# course

Execute sp_InsertQuestion 
  @Body = 'Which keyword is used to define a class in C#?', 
  @Mark = 5, 
  @TypeID = 1,  
  @CrsID = 6,   
  @InsID = 1; 
go
Execute sp_InsertQuestion 
  @Body = 'Which data type is used to store a single character in C#?', 
  @Mark = 5, 
  @TypeID = 1,  
  @CrsID = 6,   
  @InsID = 1; 
  go
Execute sp_InsertQuestion 
  @Body = 'What is the default access modifier for a class in C#?', 
  @Mark = 5, 
  @TypeID = 1,  
  @CrsID = 6,   
  @InsID = 1; 
  go
Execute sp_InsertQuestion 
  @Body = 'Which loop is used when the number of iterations is known in advance?', 
  @Mark = 5, 
  @TypeID = 1,  
  @CrsID = 6,   
  @InsID = 1; 
  go
Execute sp_InsertQuestion 
  @Body = 'Which of the following is NOT a valid access modifier in C#? a) private  b) protected  c) external  d) internal', 
  @Mark = 5, 
  @TypeID = 1,  
  @CrsID = 6,   
  @InsID = 1; 
  go



-- html t/f questions

-- Question: "HTML stands for HyperText Markup Language." (Correct: True)
EXEC sp_InsertQuestion 
	@Body = 'HTML stands for HyperText Markup Language.', 
	@Mark = 1, 
	@TypeID = 2,
	@CrsID = 8, 
	@InsID = 8;
go
-- Question: "The <title> tag is used to define the main heading of a webpage." (Correct: False)
EXEC sp_InsertQuestion 
	@Body = 'The <title> tag is used to define the main heading of a webpage.', 
	@Mark = 1, 
	@TypeID = 2, 
	@CrsID = 8, 
	@InsID = 8;
go
-- Question: "The <img> tag in HTML requires a closing tag." (Correct: False)
EXEC sp_InsertQuestion 
	@Body = 'The <img> tag in HTML requires a closing tag.', 
	@Mark = 1, 
	@TypeID = 2, 
	@CrsID = 8, 
	@InsID = 8;
go

-- html choose one questions

-- Question: "Which tag is used to create a hyperlink in HTML?" (Correct: <a>)
EXEC sp_InsertQuestion 
	@Body = 'Which tag is used to create a hyperlink in HTML?', 
	@Mark = 1, 
	@TypeID = 1, 
	@CrsID = 8, 
	@InsID = 8;

go
-- Question: "Which HTML element is used to define an unordered list?" (Correct: <ul>)
EXEC sp_InsertQuestion 
	@Body = 'Which HTML element is used to define an unordered list?', 
	@Mark = 1, 
	@TypeID = 1, 
	@CrsID = 8, 
	@InsID = 8;
go

-- Question: "Which attribute is used to specify an image source in the <img> tag?" (Correct: src)
EXEC sp_InsertQuestion 
	@Body = 'Which attribute is used to specify an image source in the <img> tag?', 
	@Mark = 1, 
	@TypeID = 1, 
	@CrsID = 8, 
	@InsID = 8;
go


---------------------------------
--sql t/f questions 

-- Question: "The PRIMARY KEY constraint allows NULL values in SQL." (Correct: False)
EXEC sp_InsertQuestion 
	@Body = 'The PRIMARY KEY constraint allows NULL values in SQL.', 
	@Mark = 1, 
	@TypeID = 2, 
	@CrsID = 15, 
	@InsID = 8;
go

-- Question: "The SQL JOIN  is used to combine rows from two or more tables based on a related column." (Correct: True)
EXEC sp_InsertQuestion 
	@Body = 'The SQL JOIN clause is used to combine rows from two or more tables based on a related column.',
	@Mark = 1, 
	@TypeID = 2, 
	@CrsID = 15, 
	@InsID = 8;
go
-- Question: "In SQL, the COUNT(*) function ignores NULL values in a column." (Correct: False)
EXEC sp_InsertQuestion 
	@Body = 'In SQL, the COUNT(*) function ignores NULL values in a column.', 
	@Mark = 1, 
	@TypeID = 2, 
	@CrsID = 15, 
	@InsID = 8;
go

-- sql choose questions

-- Question: "Which SQL clause is used to filter results based on a condition?" (Correct: WHERE)
EXEC sp_InsertQuestion 
	@Body = 'Which SQL clause is used to filter results based on a condition?', 
	@Mark = 1,
	@TypeID = 1, 
	@CrsID = 15, 
	@InsID = 8;

go
-- Question: "Which SQL statement is used to remove all records from a table without deleting the table structure?" (Correct: TRUNCATE)
EXEC sp_InsertQuestion 
	@Body = 'Which SQL statement is used to remove all records from a table without deleting the table structure?', 
	@Mark = 1, 
	@TypeID = 1, 
	@CrsID = 15, 
	@InsID = 8;
go


Execute sp_SelectQuestion ;

Execute sp_SelectCoursesInstructor ;