
-- stored to insert into topic take (course id,  topic name)
Create Procedure sp_InsertTopic
  @CrsID int,
  @Name varchar(50)
AS
Begin
  Begin try
    if not exists (select 1 from Course where ID = @CrsID)
    Begin
      print 'Can not Insert, Course ID does not exist in Course table.';
    End

   else
   Begin
		 if  exists (select 1 from Topic where CrsID = @CrsID and Name = @Name)
		 Begin
			  print 'This Course already exist in This Topic';
		  End
		  else
		  Begin
			 insert into Topic (CrsID, Name)
			 values (@CrsID, @Name);
			 print 'Topic inserted successfully.';
		  End
   End
  End try
  Begin catch
    print 'Error occurred, Topic not inserted';
  End catch
End;
GO


--stored update topic take (topic id, course id, topic name)
Create Procedure  sp_UpdateTopic
  @TopicID int,
  @NewCrsID int,
  @NewName  varchar(50) = null
AS
Begin
  Begin try
    if not exists (select 1 from Topic where ID = @TopicID)
    Begin
        print 'Error: Topic ID does not exist in Topic Table.';
        return;
    End

    if not exists  (select 1 from Course where ID = @NewCrsID)
    Begin
        print 'Error: Course ID does not exist in Course Table.';
    End

    else
    Begin  
		if  exists (select 1 from Topic where CrsID = @NewCrsID and Name = @NewName)
		 Begin
			  print 'this course already exist in this topic';
		  End
		else
		 Begin
			  update Topic
				set CrsID = @NewCrsID, Name = ISNULL(@NewName, Name)
				where ID = @TopicID;
				print 'Topic updated successfully.';	 
		  End
   End
    End try
    Begin catch
		print 'Error occurred,Cannot update Topic';
    End catch
End;
GO



--stored Delete topic take (topic id)
Create Procedure  sp_DeleteTopic
  @TopicID int
AS
Begin
  Begin try
    IF not exists (select 1 from Topic where ID = @TopicID)
    Begin
        print 'Error: Topic ID does not exist.';
    End

    ELSE
	Begin
		delete from Topic
		where ID = @TopicID;
		print 'Topic deleted successfully.';
	End

    End try
    Begin catch
		print 'Error occurred: ' + ERROR_MESSAGE();
  End CATCH
End;
GO



--stored select topic take (Topic Name  select specific topic  or not tacke any  select all topics)
alter Procedure  sp_SelectTopic
  @TopicName varchar(50) = null
AS
Begin
  Begin try
		if @TopicName is null
		Begin
			select t.ID , t.Name as TopicName,
				   t.CrsID as CourseId, c.Name as CourseName
				from Topic t
				inner join Course c
				on c.ID = t.CrsID
		End
		else
		Begin
			if  exists(select 1 from Topic where Name = @TopicName)
			Begin
				select t.ID,  t.Name as TopicName,
						t.CrsID as CourseId, c.Name as CourseName
				from  Topic t 
				 join Course c 
				 on c.ID = t.CrsID
				 where  t.Name = @TopicName
			End
			else
			Begin
				 print 'Error: Topic ID does not exist.';
			End
		End
    End try
    Begin catch
		print 'Error occurred: ' + ERROR_MESSAGE();
    End catch
End;
GO


execute sp_SelectTopic ;

--------------------------------------------------------------------
Execute sp_InsertTopic 2 , 'OOP';
Execute sp_InsertTopic 3 , 'oop';
Execute sp_InsertTopic 3 , 'programming language';
Execute sp_InsertTopic 4 , 'programming language';
Execute sp_InsertTopic 5 , 'programming language';
Execute sp_InsertTopic 6 , 'programming language';

Execute sp_InsertTopic 8 , 'Web';
Execute sp_InsertTopic 9 , 'web';
Execute sp_InsertTopic 10 , 'web';
Execute sp_InsertTopic 21 , 'web';

Execute sp_InsertTopic 14 , 'DB';
Execute sp_InsertTopic 15 , 'DB';
Execute sp_InsertTopic 22, 'DB';