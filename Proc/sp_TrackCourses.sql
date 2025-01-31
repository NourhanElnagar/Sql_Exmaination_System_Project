------------------------5- TrackCourse Tabl-------------------------------------
--1-select 
ALTER PROCEDURE sp_SelectTrackCourses
  @TrackID INT = NULL, 
  @CrsID INT = NULL    
AS
BEGIN
  SET NOCOUNT ON;

 
  IF @TrackID IS NULL AND @CrsID IS NULL
  BEGIN
      --SELECT TC.TrackID, TC.CrsID, T.Name AS TrackName, C.Name AS CourseName
	  SELECT TC.TrackID,T.Name AS TrackName, TC.CrsID, C.Name AS CourseName
      FROM TrackCourses TC
      INNER JOIN Track T ON TC.TrackID = T.ID
      INNER JOIN Course C ON TC.CrsID = C.ID;
      RETURN;
  END

  
  IF @TrackID IS NOT NULL AND @CrsID IS NULL
  BEGIN
    IF EXISTS (SELECT 1 FROM TrackCourses WHERE TrackID = @TrackID)
    BEGIN
      SELECT TC.TrackID,T.Name AS TrackName, TC.CrsID, C.Name AS CourseName
      FROM TrackCourses TC
      INNER JOIN Track T ON TC.TrackID = T.ID
      INNER JOIN Course C ON TC.CrsID = C.ID
      WHERE TC.TrackID = @TrackID;
    END
    ELSE
    BEGIN
      SELECT CAST('TrackID does not exist in TrackCourses.' AS NVARCHAR(100)) AS ErrorMessage, 
             NULL AS TrackID, NULL AS CrsID, NULL AS TrackName, NULL AS CourseName;
    END
    RETURN;
  END


  IF @TrackID IS NULL AND @CrsID IS NOT NULL
  BEGIN
    IF EXISTS (SELECT 1 FROM TrackCourses WHERE CrsID = @CrsID)
    BEGIN
      SELECT TC.TrackID,T.Name AS TrackName, TC.CrsID, C.Name AS CourseName
      FROM TrackCourses TC
      INNER JOIN Track T ON TC.TrackID = T.ID
      INNER JOIN Course C ON TC.CrsID = C.ID
      WHERE TC.CrsID = @CrsID;
    END
    ELSE
    BEGIN
      SELECT CAST('CrsID does not exist in TrackCourses.' AS NVARCHAR(100)) AS ErrorMessage, 
             NULL AS TrackID, NULL AS CrsID, NULL AS TrackName, NULL AS CourseName;
    END
    RETURN;
  END

 
  IF EXISTS (SELECT 1 FROM TrackCourses WHERE TrackID = @TrackID AND CrsID = @CrsID)
  BEGIN
    SELECT TC.TrackID,T.Name AS TrackName, TC.CrsID, C.Name AS CourseName
    FROM TrackCourses TC
    INNER JOIN Track T ON TC.TrackID = T.ID
    INNER JOIN Course C ON TC.CrsID = C.ID
    WHERE TC.TrackID = @TrackID AND TC.CrsID = @CrsID;
  END
  ELSE
  BEGIN
    SELECT CAST('No matching record found for the specified TrackID and CrsID.' AS NVARCHAR(100)) AS ErrorMessage,
           NULL AS TrackID, NULL AS CrsID, NULL AS TrackName, NULL AS CourseName;
  END
END;
GO
-----------------

----------
--2-insert
CREATE PROCEDURE sp_InsertTrackCourses
    @TrackID INT,
    @CrsID INT
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @TrackID)
        BEGIN
            PRINT 'Error: Track ID does not exist in Track Table.';
            RETURN;
        END

        
        IF NOT EXISTS (SELECT 1 FROM Course WHERE ID = @CrsID)
        BEGIN
            PRINT 'Error: Course ID does not exist in Course Table.';
            RETURN;
        END

        BEGIN TRANSACTION;
        
       
        INSERT INTO TrackCourses (TrackID, CrsID)
        VALUES (@TrackID, @CrsID);

        COMMIT TRANSACTION;
        PRINT 'TrackCourse inserted successfully.';
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: TrackCourse did not insert.';
    END CATCH
END;
GO
--


--3- update
CREATE PROCEDURE sp_UpdateTrackCourses
    @OldTrackID INT,
    @OldCrsID INT,
    @NewCrsID INT = NULL,
    @NewTrackID INT = NULL
AS
BEGIN
    BEGIN TRY
     
        IF NOT EXISTS (SELECT 1 FROM TrackCourses WHERE TrackID = @OldTrackID AND CrsID = @OldCrsID)
        BEGIN
            PRINT 'Error: The specified Track-Course combination does not exist in TrackCourses table.';
            RETURN;
        END

        
        IF @NewTrackID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Track WHERE ID = @NewTrackID)
        BEGIN
            PRINT 'Error: New Track ID does not exist in Track table.';
            RETURN;
        END

       
        IF @NewCrsID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Course WHERE ID = @NewCrsID)
        BEGIN
            PRINT 'Error: New Course ID does not exist in Course table.';
            RETURN;
        END

        
        BEGIN TRANSACTION;
        UPDATE TrackCourses
        SET 
            TrackID = ISNULL(@NewTrackID, @OldTrackID),
            CrsID = ISNULL(@NewCrsID, @OldCrsID)
        WHERE TrackID = @OldTrackID AND CrsID = @OldCrsID;
        COMMIT TRANSACTION;

        PRINT 'TrackCourses record updated successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error occurred: Could not update the TrackCourses record.';
    END CATCH
END;
GO

--4-delete
CREATE PROCEDURE sp_DeleteTrackCourses
    @TrackID INT,
    @CrsID INT
AS
BEGIN
    BEGIN TRY
       
        IF NOT EXISTS (SELECT 1 FROM TrackCourses WHERE TrackID = @TrackID AND CrsID = @CrsID)
        BEGIN
            PRINT 'Error: The Track-Course combination does not exist in the TrackCourses table.';
            RETURN;
        END

        
        BEGIN TRANSACTION;

       
        DELETE FROM TrackCourses WHERE TrackID = @TrackID AND CrsID = @CrsID;

       
        COMMIT TRANSACTION;

        PRINT 'Track-Course deleted successfully.';
    END TRY
    BEGIN CATCH
      
        ROLLBACK TRANSACTION;
        PRINT 'Error occurred, cannot delete Track-Course.';
    END CATCH
END;
GO