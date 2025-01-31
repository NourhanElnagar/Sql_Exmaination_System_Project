-----------------------------------------------------------------------------------------
----------------------------------2. Intake Table:yes-----------

--1-SELECT into Intake
CREATE PROCEDURE sp_SelectIntake
  @IntakeID INT = NULL 
AS
BEGIN
  IF @IntakeID IS NULL
  BEGIN
    SELECT ID, Name, StartDate, EndDate
    FROM Intake;
  END
  ELSE
    IF EXISTS (SELECT 1 FROM Intake WHERE ID = @IntakeID)
    BEGIN 
       SELECT ID, Name, StartDate, EndDate
       FROM Intake
       WHERE ID = @IntakeID;
    END
    ELSE
    BEGIN
      SELECT 'Intake ID does not exist.';
    END
END;
GO

--2-INSERT--------
CREATE PROCEDURE sp_InsertIntake
    @Name VARCHAR(30),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    BEGIN TRY
        --if duplicated
        IF EXISTS (SELECT 1 FROM Intake WHERE Name = @Name)
        BEGIN
            PRINT 'Error: Intake with the same name already exists.';
            RETURN;
        END

        -- 
        IF @StartDate > @EndDate
        BEGIN
            PRINT 'Error: StartDate cannot be greater than EndDate.';
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO Intake (Name, StartDate, EndDate)
        VALUES (@Name, @StartDate, @EndDate);

        COMMIT TRANSACTION;

        PRINT 'Intake inserted successfully.';
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: Intake could not be inserted.';
    END CATCH
END;
GO

-------------3 update
CREATE PROCEDURE sp_UpdateIntake
    @ID INT,
    @Name VARCHAR(30) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    BEGIN TRY
       
        IF NOT EXISTS (SELECT 1 FROM Intake WHERE ID = @ID)
        BEGIN
            PRINT 'Error: Intake ID does not exist in Intake table.';
            RETURN;
        END

        
        IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL AND @StartDate > @EndDate
        BEGIN
            PRINT 'Error: StartDate cannot be greater than EndDate.';
            RETURN;
        END

       
        BEGIN TRANSACTION;
        UPDATE Intake
        SET 
            Name = ISNULL(@Name, Name),
            StartDate = ISNULL(@StartDate, StartDate),
            EndDate = ISNULL(@EndDate, EndDate)
        WHERE ID = @ID;
        COMMIT TRANSACTION;

        PRINT 'Intake record updated successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error occurred: Could not update the Intake record.';
    END CATCH;
END;
GO
---------------

--4-- delete
CREATE PROCEDURE sp_DeleteIntake
    @ID INT
AS
BEGIN
  BEGIN TRY
    
    IF NOT EXISTS (SELECT 1 FROM Intake WHERE ID = @ID)
    BEGIN
      PRINT 'Error: The Intake does not exist in the Intake table.';
      RETURN;
    END

  
  
    DELETE FROM Intake
    WHERE ID = @ID;

    
    COMMIT TRANSACTION;

    PRINT 'Intake deleted successfully.';
  END TRY
  BEGIN CATCH
    
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred, cannot delete Intake.';
  END CATCH
END;
GO
----------------------------------------------------------------------------