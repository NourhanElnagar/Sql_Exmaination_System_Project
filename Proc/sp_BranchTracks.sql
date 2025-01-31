---------------------4- BranchTracks Table-----------------
--1-Select BranchTracks
Alter PROCEDURE sp_SelectBranchTracks
  @BranchID INT = NULL, 
  @TrackID INT = NULL   
AS
BEGIN
  SET NOCOUNT ON;

 
  IF @BranchID IS NULL AND @TrackID IS NULL
  BEGIN
    SELECT BT.BranchID, B.City AS BranchCity, BT.TrackID, T.Name AS TrackName
    FROM BranchTracks BT
    INNER JOIN Branch B ON BT.BranchID = B.ID
    INNER JOIN Track T ON BT.TrackID = T.ID;
    RETURN;
  END

 
  IF @BranchID IS NOT NULL AND @TrackID IS NULL
  BEGIN
    IF EXISTS (SELECT 1 FROM BranchTracks WHERE BranchID = @BranchID)
    BEGIN
      SELECT BT.BranchID, B.City AS BranchCity, BT.TrackID, T.Name AS TrackName
      FROM BranchTracks BT
      INNER JOIN Branch B ON BT.BranchID = B.ID
      INNER JOIN Track T ON BT.TrackID = T.ID
      WHERE BT.BranchID = @BranchID;
    END
    ELSE
    BEGIN
      SELECT CAST('BranchID does not exist in BranchTracks.' AS NVARCHAR(100)) AS ErrorMessage, 
             NULL AS BranchID, NULL AS BranchCity, NULL AS TrackID, NULL AS TrackName;
    END
    RETURN;
  END


  IF @BranchID IS NULL AND @TrackID IS NOT NULL
  BEGIN
    IF EXISTS (SELECT 1 FROM BranchTracks WHERE TrackID = @TrackID)
    BEGIN
      SELECT BT.BranchID, B.City AS BranchCity, BT.TrackID, T.Name AS TrackName
      FROM BranchTracks BT
      INNER JOIN Branch B ON BT.BranchID = B.ID
      INNER JOIN Track T ON BT.TrackID = T.ID
      WHERE BT.TrackID = @TrackID;
    END
    ELSE
    BEGIN
      SELECT CAST('TrackID does not exist in BranchTracks.' AS NVARCHAR(100)) AS ErrorMessage, 
             NULL AS BranchID, NULL AS BranchCity, NULL AS TrackID, NULL AS TrackName;
    END
    RETURN;
  END

  
  IF EXISTS (SELECT 1 FROM BranchTracks WHERE BranchID = @BranchID AND TrackID = @TrackID)
  BEGIN
    SELECT BT.BranchID, B.City AS BranchCity, BT.TrackID, T.Name AS TrackName
    FROM BranchTracks BT
    INNER JOIN Branch B ON BT.BranchID = B.ID
    INNER JOIN Track T ON BT.TrackID = T.ID
    WHERE BT.BranchID = @BranchID AND BT.TrackID = @TrackID;
  END
  ELSE
  BEGIN
    SELECT CAST('No matching record found for the specified BranchID and TrackID.' AS NVARCHAR(100)) AS ErrorMessage,
           NULL AS BranchID, NULL AS BranchCity, NULL AS TrackID, NULL AS TrackName;
  END
END;
GO

----------
--2-insert into branchtrack
CREATE PROCEDURE sp_InsertBranchTracks
    @BranchID INT,
    @TrackID INT
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Branch WHERE ID = @BranchID)
        BEGIN
            PRINT 'Error: Branch ID does not exist in Branch table.';
            RETURN;
        END

        
        IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @TrackID)
        BEGIN
            PRINT 'Error: Track ID does not exist in Track table.';
            RETURN;
        END

       
        BEGIN TRANSACTION;

        INSERT INTO BranchTracks (BranchID, TrackID)
        VALUES (@BranchID, @TrackID);

        COMMIT TRANSACTION;

        PRINT 'BranchTrack inserted successfully.';
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: BranchTrack could not be inserted.';
    END CATCH
END;
GO

--------------------
--3-UPDATE branchtrack
Create PROCEDURE sp_UpdateBranchTracks
    @OldBranchID INT,
    @OldTrackID INT,
    @NewBranchID INT = NULL,
    @NewTrackID INT = NULL
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM BranchTracks WHERE BranchID = @OldBranchID AND TrackID = @OldTrackID)
        BEGIN
            PRINT 'Error: The specified Branch-Track combination does not exist in BranchTracks table.';
            RETURN;
        END

        -- If the new values are provided, check if they exist in the related tables.
        IF @NewBranchID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Branch WHERE ID = @NewBranchID)
            BEGIN
                PRINT 'Error: The new Branch ID does not exist in the Branch table.';
                RETURN;
            END
        END

        IF @NewTrackID IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @NewTrackID)
            BEGIN
                PRINT 'Error: The new Track ID does not exist in the Track table.';
                RETURN;
            END
        END

        
        UPDATE BranchTracks
        SET 
            BranchID = ISNULL(@NewBranchID, @OldBranchID),
            TrackID = ISNULL(@NewTrackID, @OldTrackID)
        WHERE 
            BranchID = @OldBranchID AND TrackID = @OldTrackID;

        PRINT 'Record updated successfully in BranchTracks.';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred: Could not update the BranchTracks record due to an unexpected error.';
    END CATCH
END;
GO
---------------------------------
--4-DELETE
CREATE PROCEDURE sp_DeleteBranchTracks
    @BranchID INT,
    @TrackID INT
AS
BEGIN
  BEGIN TRY
    
    IF NOT EXISTS (SELECT 1 FROM BranchTracks WHERE BranchID = @BranchID AND TrackID = @TrackID)
    BEGIN
      PRINT 'Error: The Branch-Track pair does not exist in BranchTracks table.';
      RETURN;
    END

   
    BEGIN TRANSACTION;

    
    DELETE FROM BranchTracks
    WHERE BranchID = @BranchID AND TrackID = @TrackID;

    
    COMMIT TRANSACTION;

    PRINT 'Branch-Track pair deleted successfully.';
  END TRY
  BEGIN CATCH
    
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred, cannot delete Branch-Track pair.';
  END CATCH
END;
GO


-----------------------------------------------------------------------