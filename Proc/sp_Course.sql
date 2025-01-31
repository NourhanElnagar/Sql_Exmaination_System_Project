use ExaminationSystem;

-- stored to insert into course take ( name of course ,  durtaion)
alter Procedure sp_InsertCourse
  @Name varchar(50),
  @Duration smallint
as
Begin
  Begin try
		insert into Course (Name, Duration)
		values (@Name, @Duration);
		print 'Course inserted successfully.';
  end try
  -- if course name exist
  Begin catch
		--print 'Error occurred: ' + error_message();
		print 'This Course already exist';
  End catch
End;
GO


-- stored  to update course take (id , name of course ,  durtaion)
Create Procedure sp_UpdateCourse
  @CourseID int,
  @Name varchar(50),
  @Duration smallint
as
Begin
  Begin try

    if not exists (select 1 from Course where ID = @CourseID)
	Begin
		print 'Course ID does not exist.';
		return;
	End
    update Course
    set 
      Name = @Name,
      Duration = @Duration
    where  ID = @CourseID;
	print 'Course updated successfully.' ;

  End try
  -- duplicated course name
  Begin catch
		print 'Error Can not update this Record , This Course already exists';
  End catch
end;
GO




-- stored  to delete course take (id  of course )
Create Procedure sp_DeleteCourse
  @CourseID int
as
Begin
  Begin try
    if exists (select 1 from Course where ID = @CourseID)
    Begin
		 delete from Course
		 where ID = @CourseID;
		 print 'Course deleted successfully.' ;
    End
    else
    Begin
		 print 'Course ID does not exist.';
    End
  End try

  Begin catch
    print 'Course did not delete.';
  End catch

End;
GO



-- stored  select course take (id  of course select specific course, if null select all )
Create Procedure sp_SelectCourse
  @CourseID int = NULL
as
Begin
  if @CourseID IS NULL
  Begin
    select * from  Course;
  End
  else
     if exists (select 1 from Course where ID = @CourseID)
     Begin
		 select ID, Name,  Duration
		 from  Course
		 where ID = @CourseID;
     End
     else
     Begin
		 print 'Course ID does not exist.';
     End
End;
GO

Execute sp_SelectCourse;





-------------------------------------------
Execute sp_InsertCourse @Name = 'Introduction to Programming', @Duration = 120;
Execute sp_InsertCourse @Name = 'Python for Beginners', @Duration = 150;
Execute sp_InsertCourse @Name = 'Advanced Python Programming', @Duration = 180;
Execute sp_InsertCourse @Name = 'Java Programming', @Duration = 200;
Execute sp_InsertCourse @Name = 'C++', @Duration = 160;
Execute sp_InsertCourse @Name = 'C#', @Duration = 140;
Execute sp_InsertCourse @Name = 'Data Structures and Algorithms', @Duration = 180;
Execute sp_InsertCourse @Name = 'HTML', @Duration = 80;
Execute sp_InsertCourse @Name = 'CSS', @Duration = 100;
Execute sp_InsertCourse @Name = 'JavaScript', @Duration = 140;
Execute sp_InsertCourse @Name = 'Cybersecurity Fundamentals', @Duration = 170;
Execute sp_InsertCourse @Name = 'Artificial Intelligence & Machine Learning', @Duration = 250;
Execute sp_InsertCourse @Name = 'Software Engineering Principles', @Duration = 180;
Execute sp_InsertCourse @Name = 'SQL', @Duration = 150;
Execute sp_InsertCourse @Name = 'Orcale', @Duration = 100;
Execute sp_InsertCourse @Name = 'Cloud Computing', @Duration = 210;
Execute sp_InsertCourse @Name = 'Operation System', @Duration = 100;
Execute sp_InsertCourse @Name = 'NetWork', @Duration = 150;
Execute sp_InsertCourse @Name = 'SQL', @Duration = 150;
Execute sp_InsertCourse @Name = 'Git & GitHub', @Duration = 60;
Execute sp_InsertCourse @Name = 'React', @Duration = 80;

Execute sp_InsertCourse @Name = 'Data warehouse', @Duration = 100;
