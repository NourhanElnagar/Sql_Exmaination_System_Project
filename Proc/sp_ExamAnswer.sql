Create procedure sp_ExamAnswer
  @ExamID int,
  @QuestionID int,
  @StudentID int,
  @StudentAnswer tinyint
AS
begin
  begin try
    if not exists(select 1 from ExamQuestions where ExamID = @ExamID and QuestionID = @QuestionID)
    begin
      print 'Error: The Question does not belong to Exam.';
      RETURN;
    end

	if not exists(select 1 from StudentExams where ExamID = @ExamID and StdID = @StudentID)
    begin
      print 'Error: The Student does not have Exam.';
      RETURN;
    end

	if not exists(select 1 from QuestionOptions where QuestionID=@QuestionID and OptionNum =@StudentAnswer)
    begin
      print 'Error: Invalid Answer .';
      RETURN;
    end


	-- insert StdAnswer into StudentsExamsAnswers
	 insert into  StudentsExamsAnswers (ExamID,QuestionID,StdID, StdAnswer)
		values (@ExamID,@QuestionID,@StudentID ,@StudentAnswer)
	 print 'Student answer this question.';

  end try
  begin catch
    print 'Error occurred: ' + ERROR_MESSAGE();
  end catch
end;
GO



exec sp_updateintake 10, @startDate = '2025-3-28';

select * from intake
exec sp_selectTrackCourses

select * from Student
order by IntakeID

exec  sp_GenerateExam	1, 2,2	;
exec  sp_GenerateExam	4, 2,3	;
exec  sp_GenerateExam	3, 3,3	;

exec sp_SelectExamQuestions 1
exec sp_SelectQuestion 


exec sp_ExamAnswer 1, 2, 9, 2;
exec sp_ExamAnswer 1, 4, 9, 2;
exec sp_ExamAnswer 1, 7, 9, 2;
exec sp_ExamAnswer 1, 8, 9, 4;

exec sp_ExamAnswer 4, 3, 5, 2;
exec sp_ExamAnswer 4, 4, 5, 2;
exec sp_ExamAnswer 4, 5, 5, 2;
exec sp_ExamAnswer 4, 7, 5, 2;
exec sp_ExamAnswer 4, 9, 5, 2;

exec sp_ExamAnswer 3,  11, 27,1;
exec sp_ExamAnswer 3,  12, 27,2;
exec sp_ExamAnswer 3,  13, 27,2;
exec sp_ExamAnswer 3,  14, 27,2;
exec sp_ExamAnswer 3,  15, 27,2;
exec sp_ExamAnswer 3,  16, 27,3;




select * from StudentExams
order by ExamID

alter TABLE Exam drop column EndTime

alter TABLE Exam  add  EndTime  AS  DATEADD(Minute , Duration , StartTime);



ENABLE TRIGGER trg_StudentsExamsAnswersAfterInsert
ON StudentsExamsAnswers

ENABLE TRIGGER trg_StudentExamPreventUpdateGrade ON StudentExams ;


ENABLE TRIGGER trg_ExamPreventUpdate ON Exam;
 go
ENABLE TRIGGER trg_ExamPreventUpdateStartTime ON Exam;

disable TRIGGER trg_ExamPreventUpdate ON Exam;
 go
disable TRIGGER trg_ExamPreventUpdateStartTime ON Exam;

ENABLE TRIGGER trg_QuestionAfterUpdate on  question




