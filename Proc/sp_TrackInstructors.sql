

--------- Work in Relation ---------------

-----------Insert Instructor in Track--------------
CREATE PROC sp_InsertTrackInstructors
    @TrackID INT,
    @InsID INT 
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @TrackID)
    BEGIN
        PRINT 'This track does not exist.';
        RETURN;
    END
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE ID = @InsID)
    BEGIN
        PRINT 'This instructor does not exist.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM TrackInstructors WHERE TrackID = @TrackID AND InsID = @InsID)
    BEGIN
        PRINT 'This instructor is already assigned to this track.';
    END
    ELSE
    BEGIN
        INSERT INTO TrackInstructors (TrackID, InsID)
        VALUES (@TrackID, @InsID);

        PRINT 'Instructor assigned to track successfully.';
    END
END;
GO

-----------Update TrackInstructors--------------
CREATE PROC sp_UpdateTrackInstructors
    @TrackID INT,
    @InsID INT,
	@NewTrackID INT=Null,
	@NewInsID INT=Null
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @TrackID)
    BEGIN
        PRINT 'This track does not exist.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE ID = @InsID)
    BEGIN
        PRINT 'This instructor does not exist.';
        RETURN;
    END

	IF NOT EXISTS (SELECT 1 FROM TrackInstructors WHERE TrackID = @TrackID AND InsID = @InsID)
    BEGIN
        PRINT 'The relationship between this track and instructor does not exist.';
        RETURN;
    END

	IF EXISTS (SELECT 1 FROM TrackInstructors WHERE TrackID = ISNULL(@NewTrackID, @TrackID) AND InsID = ISNULL(@NewInsID, @InsID))
    BEGIN
        PRINT 'The new TrackID and InstructorID combination already exists.';
        RETURN;
    END

    IF @NewTrackID IS NOT NULL AND @NewInsID IS NOT NULL
    BEGIN
        
        UPDATE TrackInstructors
        SET TrackID = @NewTrackID,
            InsID = @NewInsID
        WHERE TrackID = @TrackID AND InsID = @InsID;
        PRINT 'Both TrackID and InstructorID updated successfully.';
    END

    ELSE IF @NewTrackID IS NOT NULL
    BEGIN
        UPDATE TrackInstructors
        SET TrackID = @NewTrackID
        WHERE TrackID = @TrackID AND InsID = @InsID;
        PRINT 'TrackID updated successfully.';
    END

    ELSE IF @NewInsID IS NOT NULL
    BEGIN
        UPDATE TrackInstructors
        SET InsID = @NewInsID
        WHERE TrackID = @TrackID AND InsID = @InsID;
        PRINT 'InstructorID updated successfully.';
    END

    ELSE
    BEGIN
        PRINT 'No updates.';
    END
END;
GO

    
-------------Delete--------------

CREATE PROC sp_DeleteTrackInstructors
    @TrackID INT,
    @InsID INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @TrackID)
    BEGIN
        PRINT 'This track does not exist.';
        RETURN;
    END

    
    IF NOT EXISTS (SELECT 1 FROM Instructor WHERE ID = @InsID)
    BEGIN
        PRINT 'This instructor does not exist.';
        RETURN;
    END

   
    IF NOT EXISTS (SELECT 1 FROM TrackInstructors WHERE TrackID = @TrackID AND InsID = @InsID)
    BEGIN
        PRINT 'This instructor is not assigned to this track.';
        RETURN;
    END

    
    DELETE FROM TrackInstructors
    WHERE TrackID = @TrackID AND InsID = @InsID;

    PRINT 'Instructor removed from the track successfully.';
END;
GO
---------Select---------------
CREATE PROC sp_SelectTrackInstructors
    @TrackID INT = NULL,
    @InsID INT = NULL    
AS
BEGIN
--- TrackID = Value , InsID = Value ---
    IF @TrackID IS NOT NULL AND @InsID IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM TrackInstructors WHERE TrackID = @TrackID AND InsID = @InsID)
        BEGIN
            SELECT 
                TI.TrackID,
                T.Name AS TrackName,
                TI.InsID,
                I.FName + ' ' + I.LName AS InstructorName
            FROM TrackInstructors TI
            INNER JOIN Track T ON TI.TrackID = T.ID
            INNER JOIN Instructor I ON TI.InsID = I.ID
            WHERE TI.TrackID = @TrackID AND TI.InsID = @InsID;
        END
        ELSE
        BEGIN
            PRINT 'No data found for the given TrackID and InstructorID.';
        END
    END

	--- TrackID = NULL , InsID = NULL ---
    ELSE IF @TrackID IS NULL AND @InsID IS NULL
    BEGIN
        SELECT 
            TI.TrackID,
            T.Name AS TrackName,
            TI.InsID,
            I.FName + ' ' + I.LName AS InstructorName
        FROM TrackInstructors TI
        INNER JOIN Track T ON TI.TrackID = T.ID
        INNER JOIN Instructor I ON TI.InsID = I.ID;
    END

    --- TrackID = NULL---
    ELSE IF @TrackID IS NOT NULL 
    BEGIN
        IF EXISTS (SELECT 1 FROM TrackInstructors WHERE TrackID = @TrackID)
        BEGIN
            SELECT 
                TI.TrackID,
                T.Name AS TrackName,
                TI.InsID,
                I.FName + ' ' + I.LName AS InstructorName
            FROM TrackInstructors TI
            INNER JOIN Track T ON TI.TrackID = T.ID
            INNER JOIN Instructor I ON TI.InsID = I.ID
            WHERE TI.TrackID = @TrackID;
        END
        ELSE
        BEGIN
            PRINT 'No data found for the given TrackID.';
        END
    END

    --  InsID = NULL --
    ELSE IF @InsID IS NOT NULL 
    BEGIN
        IF EXISTS (SELECT 1 FROM TrackInstructors WHERE InsID = @InsID)
        BEGIN
            SELECT 
                TI.TrackID,
                T.Name AS TrackName,
                TI.InsID,
                I.FName + ' ' + I.LName AS InstructorName
            FROM TrackInstructors TI
            INNER JOIN Track T ON TI.TrackID = T.ID
            INNER JOIN Instructor I ON TI.InsID = I.ID
            WHERE TI.InsID = @InsID;
        END
        ELSE
        BEGIN
            PRINT 'No data found for the given InstructorID.';
        END
    END
END
GO


---------------Testing---------------------
select * from Instructor
select * from Track
EXEC sp_InsertTrackInstructors
     @TrackID =1,
     @InsID=8
GO
EXEC sp_InsertTrackInstructors
     @TrackID =1,
     @InsID=1
GO
	 EXEC sp_InsertTrackInstructors
     @TrackID =2,
     @InsID=3

GO
EXEC sp_InsertTrackInstructors
     @TrackID =3,
     @InsID=7
GO
EXEC sp_InsertTrackInstructors
     @TrackID =5,
     @InsID=9
GO
EXEC sp_InsertTrackInstructors
     @TrackID =11,
     @InsID=12
GO
EXEC sp_InsertTrackInstructors
     @TrackID =8,
     @InsID=4
GO
EXEC sp_InsertTrackInstructors
     @TrackID =4,
     @InsID=6

EXEC sp_UpdateTrackInstructors
	   @TrackID =5,
	   @InsID=7,
	   @NewTrackID=10

EXEC sp_DeleteTrackInstructors
	 @TrackID = 10,
	 @InsID = 6
GO
 EXEC sp_SelectTrackInstructors
	 @TrackID =11,
     @InsID=12
GO

EXEC sp_InsertTrackInstructors
     @TrackID =2,
     @InsID=5
GO
EXEC sp_InsertTrackInstructors
     @TrackID =5,
     @InsID=10
GO
EXEC sp_InsertTrackInstructors
     @TrackID =9,
     @InsID=12
GO
EXEC sp_InsertTrackInstructors
     @TrackID =10,
     @InsID=11
GO

SELECT* FROM TrackInstructors 
SELECT* FROM Track
SELECT* FROM instructor

drop proc sp_SelectTrackInstructors

EXEC sp_DeleteCourse 10;
 