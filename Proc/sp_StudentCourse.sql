
--stored insert into StudentCourse take (course id , student id)
Create Procedure sp_InsertStudentCourse
	@CrsID int,
	@StdID int
AS
Begin
  Begin try
    if not exists (select 1 from Student where ID = @StdID)
    Begin
      print 'Error: Student ID does not exist in Student table.';
      RETURN;
    End

    if not exists (select 1 from Course where ID = @CrsID)
    Begin
      print 'Error: Course ID does not exist in Course table.';
      RETURN;
    End

    insert into StudentCourses (StdID, CrsID)
    values (@StdID, @CrsID);

    print 'Record inserted successfully to StudentCourses.';
  End try
  Begin catch
    print 'Error cannot insert Student , Student already exists in this Course.';
  End catch
End;
GO



--stored insert update StudentCourse take (Oldcrs id ,OldStd id, newCrs id ,newStd id)
Create Procedure  sp_UpdateStudentCourse
  @OldCrsID int,
  @OldStdID int,
  @NewCrsID int = null,
  @NewStdID int = null
AS
Begin
  Begin try
    if not exists (select 1 from StudentCourses where StdID = @OldStdID and CrsID = @OldCrsID)
    Begin
      print 'Error: The Student-Course does not exist in StudentCourses table.';
      RETURN;
    End

	if @NewCrsID is not null and  @NewStdID is not null
	Begin
		if not exists (select 1 from Student where ID = @NewStdID)
		Begin
		  print 'Error: New Student ID does not exist in Student table.';
		  return;
		End

		if not exists (select 1 from Course where ID = @NewCrsID)
		Begin
		  print 'Error: New Course ID does not exist in Course table.';
		  return;
		End
	End
   

    update StudentCourses
		set StdID = isnull(@NewStdID, @OldStdID), CrsID =isnull( @NewCrsID, @OldCrsID)
		where StdID = @OldStdID and CrsID = @OldCrsID;

    print 'Record updated successfully in StudentCourses.';
  End try
  Begin catch
    print 'Error occurred Cannot update, this Student already exist in this Course';
  End catch
End;
GO

--stored insert delete StudentCourse take (crs id ,std id, )
Create Procedure  sp_DeleteStudentCourse
    @CrsID int,
    @StdID int
AS
Begin
  Begin try
    if not exists (select 1 from StudentCourses where StdID = @StdID and CrsID = @CrsID)
    Begin
      print 'Error: The Student-Course  does not exist in StudentCourses table.';
      RETURN;
    End

     delete from StudentCourses
		where StdID = @StdID AND CrsID = @CrsID;

     print 'Record deleted successfully from StudentCourses.';
  End try
  Begin catch
    print 'Error occurred , cannot detele record from StudentCourses';
  End catch
End;
GO


--stored select StudentCourse take (crsid if exit return name-id std-crs, or not take return all table)
Create Procedure sp_SelectStudentCourse
  @CrsID int = null
AS
Begin
  Begin try
       if @CrsID is null 
	Begin
		select 
		  sc.CrsID,
		  c.Name AS CourseName,
		  sc.StdID,
		  CONCAT(s.Fname, ' ', s.Lname) AS StudentName
		from StudentCourses sc
		inner join
		  Course c ON sc.CrsID = c.ID
		inner join
		  Student s ON sc.StdID = s.ID;

	End
	else
	Begin
		 if not exists (select 1 from StudentCourses where CrsID = @CrsID)
		  Begin
			print 'Error: The Student-Course does not exist in StudentCourses table.';
		  End
		  else
			Begin
				select 
				  sc.CrsID,
				  c.Name AS CourseName,
				  sc.StdID,
				  CONCAT(s.Fname, ' ', s.Lname) AS StudentName
				from  StudentCourses sc
				inner join
				  Course c ON sc.CrsID = c.ID
				inner join
				  Student s ON sc.StdID = s.ID
					where sc.CrsID = @CrsID 
			End
	End
  End try
  Begin catch
    PRINT 'Error occurred, Cannot Select data from StudentCourses';
  End catch
End;
GO



Execute sp_SelectStudentCourse;
