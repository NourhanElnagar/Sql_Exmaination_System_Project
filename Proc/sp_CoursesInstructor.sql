
--stored insert into CoursesInstructor take (course id , instructor id)
Create Procedure sp_InsertCoursesInstructor
  @CrsID int,
  @InsID int
AS
Begin
  Begin try
		if not exists (select 1 from Course where ID = @CrsID)
		Begin
		  print 'Error: Course ID does not exist in Course Table.';
		  RETURN;
		End

		if not exists (select 1 from Instructor where ID = @InsID)
		Begin
		  print 'Error: Instructor ID does not exist in Instructor Table.';
		End
		else
		Begin
			insert into CoursesInstructors (CrsID, InsID)
			values (@CrsID, @InsID);
			print 'successfully insert into CoursesInstructors.';
		End
    End try
    Begin catch
		print 'Error cannot insert Instructor , Instructor already exists in this Course.';
    End catch
End;
GO


--stored insert update CoursesInstructor take (Oldcrs id ,Oldinst id, newCrs id ,newInst id)
Create Procedure  sp_UpdateCoursesInstructor
  @OldCrsID int,
  @OldInsID int,
  @NewCrsID int = null,
  @NewInsID int = null
AS
Begin
  Begin try
    if not exists (select 1 from CoursesInstructors where CrsID = @OldCrsID and InsID = @OldInsID)
    Begin
      print 'Error:Course-Instructor does not exist in CourseInstructor table.';
      RETURN;
    End

	if @NewCrsID is not null and  @NewInsID is not null
	Begin
		if not exists (select 1 from Course where ID = @NewCrsID)
		Begin
		  print 'Error: New Course ID does not exist in Course table.';
		  return;
		End

		if not exists (select 1 from Instructor where ID = @NewInsID)
		Begin
		  print 'Error: New Instructor ID does not exist in Instructor table.';
		  return;
		End
	End

    

    update CoursesInstructors
		set CrsID = isnull(@NewCrsID, @OldCrsID), InsID = isnull(@NewInsID,@OldInsID)
		where CrsID = @OldCrsID AND InsID = @OldInsID;
    print 'Record updated successfully in CoursesInstructors.';
    End try
    Begin catch
		print 'Error occurred Cannot update, this Instructor already exist in this Course';
  End catch
End;
GO



--stored insert delete CoursesInstructor take (crs id ,inst id)
Create Procedure  sp_DeleteCoursesInstructor
  @CrsID int,
  @InsID int
AS
Begin
  Begin try
    if not exists (select 1 from CoursesInstructors where CrsID = @CrsID and InsID = @InsID)
    Begin
      print 'Error: The Course-Instructor does not exist in CoursesInstructor table.';
      RETURN;
    End

    delete from CoursesInstructors
    where CrsID = @CrsID and InsID = @InsID;

    print 'Record deleted successfully from CoursesInstructors.';
  End try
  Begin catch
       print 'Error occurred , cannot detele record from CoursesInstructor';
  End catch
End;
GO

--stored select CoursesInstructor take (crsid if exit return name-id inst-crs, or not take return all table)
Create Procedure sp_SelectCoursesInstructor
	@CrsID int = null
AS
Begin
  Begin try
    if @CrsID is null 
	Begin
		select 
		  ci.CrsID,
		  c.Name AS CourseName,
		  ci.InsID,
		  CONCAT(i.Fname, ' ', i.Lname) AS InstructorName
		from 
		  CoursesInstructors ci
		inner join 
		  Course c ON ci.CrsID = c.ID
		inner join 
		  Instructor i ON ci.InsID = i.ID;
	End
	else
	Begin
		 if not exists (select 1 from CoursesInstructors where CrsID = @CrsID)
		  Begin
			print 'Error: The Course-Instructor  does not exist in CoursesInstructor table.';
		  End
		  else
			Begin
				select 
					ci.CrsID,
					c.Name AS CourseName,
					ci.InsID,
					CONCAT(i.Fname, ' ', i.Lname) AS InstructorName
				FROM 
					CoursesInstructors ci
				inner join
					Course c ON ci.CrsID = c.ID
				inner join
					Instructor i ON ci.InsID = i.ID	
					where ci.CrsID = @CrsID 
			End
	End
  End try
  Begin catch
    print 'Error occurred, Cannot Select data from CoursesInstructor';
  End catch
End;
GO

Execute sp_SelectCoursesInstructor ;


Execute sp_InsertCoursesInstructor 2, 3 ;
Execute sp_InsertCoursesInstructor 3, 5 ;
Execute sp_InsertCoursesInstructor 8, 8;

Execute sp_SelectTrackInstructors;