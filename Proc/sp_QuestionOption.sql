
--stored insert QuestionOption take(quesId, optNum, OPtBody,  check(if has value -> correct) )
Create Procedure sp_InsertQuestionOption
  @QuestionID int,
  @OptionNum tinyint,
  @OptionBody varchar(50),
  @check varchar(20) = null
AS
Begin
  Begin try
    if not exists (select 1 from Question where ID =@QuestionID)
	begin 
		print 'Cannot insert option , Question is not exists ';
	end

	else
	begin 
		insert into QuestionOptions (QuestionID, OptionNum, OptionBody)
		values (@QuestionID, @OptionNum, @OptionBody)

		if @check is not null 
		Begin
			update Question
				set CorrectAnswer = @OptionNum
				where Question.ID = @QuestionID
		End

    print 'Option inserted successfully.';
	end

  End try

  Begin catch
    print 'Error Cannot insert, this Option already assigned to this question. ' ;
  End catch
End;
GO


--update body of option
--stored Update QuestionOption take(quesId, optNum, NewOPtBody,  check(if has value -> correct) )
Create Procedure sp_UpdateQuestionOption
  @QuestionID int,
  @OptionNum tinyint,
  @NewOptionBody varchar(50),
  @check varchar(20) = null
AS
Begin 
  Begin try
    if not exists (select 1 from QuestionOptions where QuestionID = @QuestionID and OptionNum = @OptionNum)
    Begin
      print 'Error: Option does not exist.';
      RETURN;
    End

	if not exists (select 1 from ExamQuestions where QuestionID = @QuestionID)
	begin 
		update QuestionOptions
		  set OptionBody = @NewOptionBody
		  where QuestionID = @QuestionID and OptionNum = @OptionNum;

		if @check is not null 
		Begin
			update Question
				set CorrectAnswer = @OptionNum
				where Question.ID = @QuestionID
		End

		print 'Option updated successfully.';
	end

	else
	Begin 
		 print 'Error occurred, Cannot update option , question in Exam';
    End 

    
  End try
  Begin catch
    print 'Error occurred, Cannot update option ';
  End catch
End;
GO


--stored Update QuestionOption take(quesId, optNum) if optnum is correct not delete
Create Procedure sp_DeleteQuestionOption
  @QuestionID int,
  @OptionNum tinyint

AS
Begin
  Begin try
    if not exists (select 1 from QuestionOptions where QuestionID = @QuestionID and OptionNum = @OptionNum)
    Begin
      print 'Error: Option does not exist.';
      RETURN;
    End

	if @OptionNum = (select CorrectAnswer from Question where Question.CorrectAnswer = @OptionNum)
	begin
		print 'Error cannot delete this option , this correct answer and assgin to question, yon can update it ';
		return;
	end

    delete from QuestionOptions
    where QuestionID = @QuestionID and OptionNum = @OptionNum;

    print 'Option deleted successfully.';
  End try

  Begin catch
    print 'Error occurred , cannot delete option.' ;
  End catch
End;
GO

--stored select Question Option
alter  Procedure sp_SelectQuestionOptions
  @QuestionID int = null
AS
Begin
  Begin try
  if @QuestionID is null
  Begin
		select  QuestionID , q.Body , STRING_AGG(concat(qo.OptionNum, ' - ', qo.OptionBody) , '         ' )within group (order by qo.OptionNum ) as Options
		from  QuestionOptions qo
		inner join Question q
		on q.ID = qo.QuestionID
		group by QuestionID , q.Body
	
  End
  else
  Begin

    if not exists (select 1 from QuestionOptions where QuestionID = @QuestionID)
    Begin
      print 'This question does not have any options.';
      return;
    End

    select  QuestionID , q.Body , STRING_AGG(concat(qo.OptionNum, ' - ', qo.OptionBody) , '         ' )within group (order by qo.OptionNum ) as Options
		from  QuestionOptions qo
		inner join Question q
		on q.ID = qo.QuestionID and QuestionID = @QuestionID
		group by QuestionID , q.Body


  end
  End try
  Begin catch
    print 'Error occurred, cannot get Question';
  End catch
End;
GO


exec sp_SelectQuestionOptions 
----------------------------------------------------

-- insert options for t/f c# questions
 --change @QuestionID

-- Question: "C# is a case-sensitive programming language." (Correct: True)
EXEC sp_InsertQuestionOption 
	@QuestionID = 1, @OptionNum = 1, @OptionBody = 'True', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 1, @OptionNum = 2, @OptionBody = 'False';
go

-- Question: "C# supports multiple inheritance for classes." (Correct: False)
EXEC sp_InsertQuestionOption 
	@QuestionID = 2, @OptionNum = 1, @OptionBody = 'True';
go
EXEC sp_InsertQuestionOption
	@QuestionID = 2, @OptionNum = 2, @OptionBody = 'False', @check = 'correct';
go

-- Question: "The 'var' keyword in C# allows implicit typing." (Correct: True)
EXEC sp_InsertQuestionOption 
	@QuestionID = 3, @OptionNum = 1, @OptionBody = 'True', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 3, @OptionNum = 2, @OptionBody = 'False';
go

-- Question: "C# does not support garbage collection." (Correct: False)
EXEC sp_InsertQuestionOption 
	@QuestionID = 4, @OptionNum = 1, @OptionBody = 'True';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 4, @OptionNum = 2, @OptionBody = 'False', @check = 'correct';
go

-- Question: "A struct in C# can inherit from a class." (Correct: False)
EXEC sp_InsertQuestionOption 
	@QuestionID = 5, @OptionNum = 1, @OptionBody = 'True';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 5, @OptionNum = 2, @OptionBody = 'False', @check = 'correct';
go

-- insert options chooseOne c# questions

-- Question: "Which keyword is used to define a class in C#?" (Correct: class)
EXEC sp_InsertQuestionOption 
	@QuestionID = 6, @OptionNum = 1, @OptionBody = 'define';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 6, @OptionNum = 2, @OptionBody = 'class', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 6, @OptionNum = 3, @OptionBody = 'struct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 6, @OptionNum = 4, @OptionBody = 'new';
go


-- Question: "Which data type is used to store a single character in C#?" (Correct: char)
EXEC sp_InsertQuestionOption 
	@QuestionID = 7, @OptionNum = 1, @OptionBody = 'string';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 7, @OptionNum = 2, @OptionBody = 'char', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 7, @OptionNum = 3, @OptionBody = 'int';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 7, @OptionNum = 4, @OptionBody = 'bool';
go


-- Question: "What is the default access modifier for a class in C#?" (Correct: internal)
EXEC sp_InsertQuestionOption 
	@QuestionID = 8, @OptionNum = 1, @OptionBody = 'public';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 8, @OptionNum = 2, @OptionBody = 'private';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 8, @OptionNum = 3, @OptionBody = 'protected';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 8, @OptionNum = 4, @OptionBody = 'internal', @check = 'correct';
go


-- Question: "Which loop is used when the number of iterations is known in advance?" (Correct: for loop)
EXEC sp_InsertQuestionOption 
	@QuestionID = 9, @OptionNum = 1, @OptionBody = 'while';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 9, @OptionNum = 2, @OptionBody = 'for', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 9, @OptionNum = 3, @OptionBody = 'foreach';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 9, @OptionNum = 4, @OptionBody = 'do-while';
go


-- Question: "Which of the following is NOT a valid access modifier in C#?" (Correct: external)
EXEC sp_InsertQuestionOption 
	@QuestionID = 10, @OptionNum = 1, @OptionBody = 'private';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 10, @OptionNum = 2, @OptionBody = 'protected';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 10, @OptionNum = 3, @OptionBody = 'external', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 10, @OptionNum = 4, @OptionBody = 'internal';
go

--------------------------------------------------
-- html t/f questions options

-- Question: "HTML stands for HyperText Markup Language." (Correct: True)
EXEC sp_InsertQuestionOption 
	@QuestionID = 11, @OptionNum = 1, @OptionBody = 'True', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 11, @OptionNum = 2, @OptionBody = 'False';
go


-- Question: "The <title> tag is used to define the main heading of a webpage." (Correct: False)
EXEC sp_InsertQuestionOption 
	@QuestionID = 12, @OptionNum = 1, @OptionBody = 'True';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 12, @OptionNum = 2, @OptionBody = 'False', @check = 'correct';
go


-- Question: "The <img> tag in HTML requires a closing tag." (Correct: False)
EXEC sp_InsertQuestionOption 
	@QuestionID = 13, @OptionNum = 1, @OptionBody = 'True';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 13, @OptionNum = 2, @OptionBody = 'False', @check = 'correct';
go


-- html choose options

-- Question: "Which tag is used to create a hyperlink in HTML?" (Correct: <a>)
EXEC sp_InsertQuestionOption 
	@QuestionID = 14, @OptionNum = 1, @OptionBody = '<link>';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 14, @OptionNum = 2, @OptionBody = '<a>', @check = 'correct';
go
EXEC sp_InsertQuestionOption
	@QuestionID = 14, @OptionNum = 3, @OptionBody = '<href>';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 14, @OptionNum = 4, @OptionBody = '<hlink>';
go


-- Question: "Which HTML element is used to define an unordered list?" (Correct: <ul>)
EXEC sp_InsertQuestionOption 
	@QuestionID = 15, @OptionNum = 1, @OptionBody = '<li>';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 15, @OptionNum = 2, @OptionBody = '<ol>';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 15, @OptionNum = 3, @OptionBody = '<ul>', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 15, @OptionNum = 4, @OptionBody = '<list>';
go


-- Question: "Which attribute is used to specify an image source in the <img> tag?" (Correct: src)
EXEC sp_InsertQuestionOption 
	@QuestionID = 16, @OptionNum = 1, @OptionBody = 'alt';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 16, @OptionNum = 2, @OptionBody = 'href';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 16, @OptionNum = 3, @OptionBody = 'src', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 16, @OptionNum = 4, @OptionBody = 'link';
go



-- sql t/f options

-- Question: "The PRIMARY KEY constraint allows NULL values in SQL." (Correct: False)
EXEC sp_InsertQuestionOption 
	@QuestionID = 17, @OptionNum = 1, @OptionBody = 'True';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 17, @OptionNum = 2, @OptionBody = 'False', @check = 'correct';
go


-- Question: "The SQL JOIN  is used to combine rows from two or more tables based on a related column." (Correct: True)
EXEC sp_InsertQuestionOption 
	@QuestionID = 18, @OptionNum = 1, @OptionBody = 'True', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 18, @OptionNum = 2, @OptionBody = 'False';
go


-- Question: "In SQL, the COUNT(*) function ignores NULL values in a column." (Correct: False)

EXEC sp_InsertQuestionOption 
	@QuestionID = 19, @OptionNum = 1, @OptionBody = 'True';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 19, @OptionNum = 2, @OptionBody = 'False', @check = 'correct';
go


-- sql choose options

-- Question: "Which SQL clause is used to filter results based on a condition?" (Correct: WHERE)
EXEC sp_InsertQuestionOption 
	@QuestionID = 20, @OptionNum = 1, @OptionBody = 'ORDER BY';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 20, @OptionNum = 2, @OptionBody = 'GROUP BY';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 20, @OptionNum = 3, @OptionBody = 'WHERE', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 20, @OptionNum = 4, @OptionBody = 'HAVING';
go


-- Question: "Which SQL statement is used to remove all records from a table without deleting the table structure?" (Correct: TRUNCATE)
EXEC sp_InsertQuestionOption 
	@QuestionID = 21, @OptionNum = 1, @OptionBody = 'DELETE';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 21, @OptionNum = 2, @OptionBody = 'DROP';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 21, @OptionNum = 3, @OptionBody = 'TRUNCATE', @check = 'correct';
go
EXEC sp_InsertQuestionOption 
	@QuestionID = 21, @OptionNum = 4, @OptionBody = 'ALTER';


exec sp_SelectQuestionOptions;