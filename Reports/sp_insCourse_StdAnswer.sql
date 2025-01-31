Create procedure sp_selectDataACordingInsID 
   @insId int
as
begin
	if not exists (select 1 from Instructor where ID = @insId)
	begin
		print 'Instructor not exists';

	end
	else
	begin
		 select i.ID as InstructorId, i.Fname + ' '+ i.Lname as InstructorName,
		   ci.CrsID ,c.Name as CourseName,
		   count( sc.StdID) as 'Number of students in this course'
		   from Instructor i
		   join CoursesInstructors ci 
		   on ci.InsID = i.ID
		   join Course c on c.ID = ci.CrsID
		   join StudentCourses sc on sc.CrsID = ci.CrsID 
		   where i.ID = @insId
		   group by 
		    i.ID, 
            i.Fname, 
            i.Lname, 
            ci.CrsID, 
            c.Name;
	end
end;
GO

exec sp_selectDataACordingInsID 8;

Create procedure sp_selectDataACordingExam_Student_id
	@ExamId int,
	@StdId int
as
begin
	if not exists (select 1 from StudentExams where ExamID=@ExamId and StdID=@StdId)
	begin
		print 'this student have not this exam';
	end

	else
	begin
		select DISTINCT  
		e.ExamID , e.StdID , q.Body as 'Question Body', qo.OptionBody as 'student answer'
		from StudentsExamsAnswers e
		 join ExamQuestions eq on e.ExamID = eq.ExamID
		 join QuestionOptions qo on qo.QuestionID = e.QuestionID and qo.OptionNum = e.StdAnswer
		 join Question q on q.ID = e.QuestionID
		where e.ExamID = @ExamId and e.StdID = @StdId
	end
end           
Go

execute sp_selectDataACordingExam_Student_id 1, 9;