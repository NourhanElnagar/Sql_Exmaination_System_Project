---------------------  3. Track Table---------------------------------------
--1-SELECT Stored Procedure
CREATE PROCEDURE sp_SelectTrack
  @TrackID INT = NULL -- Optional parameter to filter by ID
AS
BEGIN
  IF @TrackID IS NULL
  BEGIN
    SELECT ID, Name, IntakeID, MngrID, HireDate
    FROM Track;
  END
  ELSE
    IF EXISTS (SELECT 1 FROM Track WHERE ID = @TrackID)
    BEGIN
      SELECT ID, Name, IntakeID, MngrID, HireDate
      FROM Track
      WHERE ID = @TrackID;
    END
    ELSE
    BEGIN
      SELECT 'Track ID does not exist.' AS ErrorMessage;
    END
END;
GO
--------------
-----------------------
 --2-Insert Track

alter PROCEDURE sp_InsertTrack
    @Name NVARCHAR(30),
    @IntakeID INT,
    @MngrID INT,
    @HireDate DATE
AS
BEGIN
    BEGIN TRY
        --  IntakeID 
		  IF EXISTS (SELECT 1 FROM Track WHERE Name = @Name)
        BEGIN
            PRINT 'Error: Track with the same name already exists.';
             RETURN;
        END
		 RETURN;
        IF NOT EXISTS (SELECT 1 FROM Intake WHERE ID = @IntakeID)
        BEGIN
            PRINT 'Error: Intake ID does not exist in Intake table.';
            RETURN;
        END

       -- Check if MngrID exists in the Managers table (or any related table).
        IF NOT EXISTS (SELECT 1 FROM Instructor WHERE ID = @MngrID)
        BEGIN
            PRINT 'Error: Manager ID does not exist in Manager table.';
            RETURN;
        END

        
        BEGIN TRANSACTION;

        INSERT INTO Track (Name, IntakeID, MngrID, HireDate)
        VALUES (@Name, @IntakeID, @MngrID, @HireDate);

		PRINT 'Track inserted successfully.';
        COMMIT TRANSACTION;

        
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: Track could not be inserted.';
    END CATCH
END;
GO
---------------
--3- Update Track
CREATE PROCEDURE sp_UpdateTrack
    @ID INT,
    @Name NVARCHAR(30) = NULL,
    @IntakeID INT = NULL,
    @MngrID INT = NULL,
    @HireDate DATE = NULL
AS
BEGIN
    BEGIN TRY
       
        IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @ID)
        BEGIN
            PRINT 'Error: Track ID does not exist in Track table.';
            RETURN;
        END

        
        IF @IntakeID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Intake WHERE ID = @IntakeID)
            BEGIN
                PRINT 'Error: Intake ID does not exist in Intake table.';
                RETURN;
            END
        END

        IF @MngrID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Instructor WHERE ID = @MngrID)
            BEGIN
                PRINT 'Error: Manager ID does not exist in Manager table.';
                RETURN;
            END
        END

       
        BEGIN TRANSACTION;
        UPDATE Track
        SET 
            Name = ISNULL(@Name, Name), 
            IntakeID = ISNULL(@IntakeID, IntakeID), 
            MngrID = ISNULL(@MngrID, MngrID),
            HireDate = ISNULL(@HireDate, HireDate)
        WHERE ID = @ID;
        COMMIT TRANSACTION;

        PRINT 'Track record updated successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error occurred: Could not update the Track record.';
    END CATCH;
END;
GO
-----

-----------------------------------------
---4.DELETE Track
CREATE PROCEDURE sp_DeleteTrack
  @TrackID INT
AS
BEGIN
  BEGIN TRY
    
    IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @TrackID)
    BEGIN
      PRINT 'Error: The Track does not exist in Track table.';
      RETURN;
    END

 
    BEGIN TRANSACTION;

    
    DELETE FROM Track
    WHERE ID = @TrackID;

    
    COMMIT TRANSACTION;

    PRINT 'Track deleted successfully.';
  END TRY
  BEGIN CATCH
    
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred, cannot delete Track.';
  END CATCH
END;
GO
-----


--------------------------------------------------------------