
--stored insert into ExamQuestion take(exam id, question id)
Create PROCEDURE sp_InsertExamQuestion
  @ExamID int,
  @QuestionID int
AS
Begin
  Begin try
    if not exists (select 1 from Exam where ID = @ExamID)
    Begin
      print 'Error: Exam ID does not exist in Exam table.';
      RETURN;
    End

    if not exists (select 1 from Question where ID = @QuestionID)
    Begin
      print 'Error: Question ID does not exist in Question table.';
	  RETURN;
    End

	if not exists (select 1 from QuestionOptions where QuestionID = @QuestionID)
    Begin
      print 'Error:cannot add this Question, have no options .';
	  RETURN;
    End


	-- check if question and exam  in the same course
	declare @ExamCourseID int;
    declare @QuestionCourseID int;

    select @ExamCourseID = CrsID from Exam where ID = @ExamID;
    select @QuestionCourseID = CrsID from Question where ID = @QuestionID;

	 if @ExamCourseID = @QuestionCourseID
	 begin
		insert into ExamQuestions (ExamID, QuestionID)
		  values (@ExamID, @QuestionID);
		update Exam
	     set TotalMark += (select Mark from Question where Question.ID = @QuestionID)
		 where Exam.ID = @ExamID

		print 'Record inserted successfully to ExamQuestions.';
	 end

	 else
	 begin
		print 'Cannot inserte question in exam, question exists in course defferent exam course';
	 end

  End try
  Begin catch
     print 'Error occurred: ' + ERROR_MESSAGE();
  End catch
End;
GO

--stored delete from ExamQuestion take(exam id, question id)
Create PROCEDURE sp_DeleteExamQuestion
  @ExamID int,
  @QuestionID int
AS
Begin
  BEGIN try
    if not exists (select 1 from ExamQuestions where ExamID = @ExamID AND QuestionID = @QuestionID)
    Begin
      print 'Error: The Exam-Question does not exist in ExamQuestions table.';
      RETURN;
    End

    delete from ExamQuestions
    where ExamID = @ExamID and QuestionID = @QuestionID;

	update Exam
	    set TotalMark -= (select Mark from Question where Question.ID = @QuestionID)
		where Exam.ID = @ExamID

    print 'Record deleted successfully from ExamQuestions.';
  End try
  Begin catch
    print 'Error occurred: ' + ERROR_MESSAGE();
  End catch
End;
GO


--stored select from ExamQuestion take(exam id)
Create PROCEDURE sp_SelectExamQuestions
  @ExamID int = null
AS
Begin
  Begin try

    if @ExamID is null
	Begin
		select EQ.ExamID, E.Name AS ExamName, EQ.QuestionID, Q.Body AS QuestionBody
		from ExamQuestions EQ
		join Exam E ON EQ.ExamID = E.ID
		join Question Q ON EQ.QuestionID = Q.ID
	End
	else
	Begin
		 IF  exists (SELECT 1 FROM ExamQuestions WHERE ExamID = @ExamID)
		 Begin
			select EQ.ExamID, E.Name AS ExamName, EQ.QuestionID, Q.Body AS QuestionBody
			from ExamQuestions EQ
			join Exam E ON EQ.ExamID = E.ID
			join Question Q ON EQ.QuestionID = Q.ID
			where (EQ.ExamID = @ExamID)
		 End
		 else
		 Begin
		 print 'Cannot get Exam Questions ,Exam Id Not Exists in ExamQuestions';
		 End

	End

  End try
  Begin catch
    print 'Error occurred: ' + ERROR_MESSAGE();
  End catch
End;
GO


--stored update  ExamQuestion
Create PROCEDURE sp_UpdateExamQuestion
  @OldExamID int,
  @OldQuestionID int,
  @NewQuestionID int
AS
Begin
  Begin TRY
    if not exists (select 1 from ExamQuestions where ExamID = @OldExamID AND QuestionID = @OldQuestionID)
    Begin
      print 'Error: The Exam-Question does not exist in ExamQuestions table.';
      RETURN;
    End

    if not exists (select 1 from Question where ID = @NewQuestionID)
    Begin
      print 'Error: New Question ID does not exist in Question table.';
      RETURN;
    End

	declare @ExamCourseID int;
    declare @QuestionCourseID int;

    select @ExamCourseID = CrsID from Exam where ID = @OldExamID;
    select @QuestionCourseID = CrsID from Question where ID = @NewQuestionID;

	 if @ExamCourseID = @QuestionCourseID
	 begin
		update ExamQuestions
        set  QuestionID = @NewQuestionID
        where ExamID = @OldExamID and QuestionID = @OldQuestionID;

		update Exam
		set TotalMark += (select Mark from Question where Question.ID = @NewQuestionID)-(select Mark from Question where Question.ID = @OldQuestionID)
        where Exam.ID = @OldExamID

		print 'Record updated successfully in ExamQuestions.';
	 end
	 else
	 begin
		print 'Cannot update question in exam, question exists in course defferent exam course';
	 end


   
  End try
  Begin catch
     print 'Error occurred: ' + ERROR_MESSAGE();
  End catch
End;
GO