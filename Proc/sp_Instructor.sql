use ExaminationSystem

------------ *Instructor* ------------------
--- Stored procedure to Insert Instructor ---
GO
CREATE PROCEDURE sp_InsertInstructor
    @Fname NVARCHAR(30) ,
    @Lname NVARCHAR(30)=null,
    @BD DATE,
    @Gender VARCHAR(1),
    @Email VARCHAR(50),
    @Password VARCHAR(10),
    @st NVARCHAR(50),
    @city VARCHAR(50),
    @Phone VARCHAR(13),
	@Hiredate DATE ,
	@Salary decimal(8,2),
	@SuperID int =null  
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO Instructor(Fname, Lname, BD, Gender, Email, Password, st, city, Phone, HireDate, Salary,SuperID)
        VALUES    (@Fname, @Lname, @BD, @Gender, @Email, @Password, @st, @city, @Phone, @Hiredate, @Salary, @SuperID);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Instructor does not insert' ;
    END CATCH
END;

GO

--- Stored procedure to Update Instructor ---

CREATE PROC sp_UpdateInstructor
    @ID INT ,
    @Fname NVARCHAR(30)=NULL ,
    @Lname NVARCHAR(30)=null,
    @BD DATE =NULL,
    @Gender VARCHAR(1)=NULL,
    @Email VARCHAR(50) =NULL,
    @Password VARCHAR(10) =NULL,
    @st NVARCHAR(50) =NULL,
    @city VARCHAR(50) =NULL,
    @Phone VARCHAR(13) =NULL,
	@Hiredate DATE =NULL ,
	@Salary decimal(8,2) =NULL,
	@SuperID int =NULL 
    AS
    BEGIN

   BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE Instructor
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
		 @Hiredate=ISNULL(@Hiredate,Hiredate),
         Salary= ISNULL(@Salary ,Salary),
         SuperID = ISNULL(@SuperID,SuperID)
         WHERE ID = @ID

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'This Instructor cannot be Updated' ;
    END CATCH

    END;
GO

----------------Stored procedure to Delete Instructor -------------------------
CREATE PROC sp_DeleteInstructor  
@ID int
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Instructor WHERE ID = @ID)
    BEGIN
        DELETE FROM Instructor
        WHERE ID = @ID;
        PRINT 'Instructor deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'This Instructor does not exist.';
    END
END;
GO

----------------Stored procedure to Select Instructor-------------------------
CREATE PROC sp_SelectInstructor  
@ID int = NULL
AS
BEGIN
  IF @ID IS NULL
	  BEGIN

		SELECT * FROM Instructor;

	  END
  ELSE IF EXISTS (SELECT 1 FROM Instructor WHERE ID = @ID)
	  BEGIN
		SELECT *
		FROM Instructor
		WHERE ID = @ID;
	   END
  ELSE
      BEGIN
		 PRINT 'This Instructor does not exist.';
      END
END;
GO


SELECT * FROM STUDENT