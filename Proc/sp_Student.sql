use ExaminationSystem

--Student

GO
CREATE PROCEDURE sp_InsertStudent
    @Fname NVARCHAR(30) ,
    @Lname NVARCHAR(30),
    @BD DATE,
    @Gender VARCHAR(1),
    @Email VARCHAR(50),
    @Password VARCHAR(10),
    @st NVARCHAR(50),
    @city VARCHAR(50),
    @Phone VARCHAR(13),
    @IntakeID INT,
    @TrackID INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Student (Fname, Lname, BD, Gender, Email, Password, st, city, Phone, IntakeID, TrackID)
        VALUES (@Fname, @Lname, @BD, @Gender, @Email, @Password, @st, @city, @Phone, @IntakeID, @TrackID);
    END TRY
    BEGIN CATCH
        PRINT 'Student does not insert' ;
    END CATCH
END;

GO
-------------Update----------
CREATE PROC sp_UpdateStudent
    @ID INT ,
    @Fname NVARCHAR(30) = NULL,
    @Lname NVARCHAR(30) =NULL,
    @BD DATE =NULL,
    @Gender VARCHAR(1) =NULL,
    @Email VARCHAR(50) =NULL,
    @Password VARCHAR(10) =NULL,
    @st NVARCHAR(50) =NULL,
    @city VARCHAR(50) =NULL,
    @Phone VARCHAR(13) =NULL,
    @IntakeID INT =NULL,
    @TrackID INT =NULL
    AS
    BEGIN

   BEGIN TRY
        UPDATE Student
        SET
         Fname = ISNULL(@Fname,Fname),
         Lname = ISNULL(@Lname,Lname),
         BD = ISNULL(@BD,BD),
         Gender = ISNULL(@Gender,Gender),
         Email = ISNULL(@Email,Email),
         Password = ISNULL(@Password,Password),
         St = ISNULL(@St,St),
         City = ISNULL(@City,City),
         Phone = ISNULL(@Phone,Phone),
         IntakeID = ISNULL(@IntakeID,IntakeID),
         TrackID = ISNULL(@TrackID,TrackID)
         WHERE ID = @ID

    END TRY
    BEGIN CATCH
        PRINT 'Student cannot be Updated' ;
    END CATCH

    END;

GO
----------Delete-------------
CREATE PROC sp_DeleteStudent @ID int
AS
BEGIN
 BEGIN TRY
        DELETE Student
         WHERE ID = @ID
    END TRY
    BEGIN CATCH
        PRINT 'This Student does not exist';
    END CATCH
END;

GO
-------------Select-------------
CREATE PROC sp_SelectStudent  
@ID int = NULL
AS
BEGIN
  IF @ID IS NULL
	  BEGIN

		SELECT * FROM Student;

	  END
  ELSE IF EXISTS (SELECT 1 FROM Student WHERE ID = @ID)
	  BEGIN
		SELECT *
		FROM Student
		WHERE ID = @ID;
	   END
  ELSE
      BEGIN
		 PRINT 'This Student does not exist.';
      END
END;
GO