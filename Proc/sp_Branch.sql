------------------1- Branch table --------------
--1. SELECT Stored Procedure
--This procedure retrieves data from the Branch table, either for all branches or for a specific branch by ID.
CREATE PROCEDURE sp_SelectBranch
  @BranchID INT = NULL 
AS
BEGIN
  IF @BranchID IS NULL
  BEGIN
     SELECT ID, Phone, City
     FROM Branch;
  END
  ELSE
	 IF exists (SELECT 1 from branch WHERE ID = @BranchID)
	 BEGIN
		 SELECT ID, Phone, City
		  FROM Branch
		  WHERE ID = @BranchID;
	 END

	 ELSE
	 BEGIN
		 SELECT 'BRANCH ID does not exist.';
     END
end;
GO
-----------------------------
--2. INSERT Stored Procedure
--This procedure inserts a new branch into the table.
CREATE PROCEDURE sp_InsertBranch
  @Phone VARCHAR(13),
  @City NVARCHAR(20)
AS
BEGIN
  BEGIN TRY
    -- Verify that the data is not duplicated".
    IF EXISTS (SELECT 1 FROM Branch WHERE Phone = @Phone AND City = @City)
    BEGIN
      PRINT 'Error: Branch with the same Phone and City already exists.';
      RETURN;
    END

    -- Execute the insertion".
    BEGIN TRANSACTION;

    INSERT INTO Branch (Phone, City)
    VALUES (@Phone, @City);

    COMMIT TRANSACTION;

    PRINT 'Branch inserted successfully.';
  END TRY

  BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error: Branch could not be inserted.';
  END CATCH
END;
GO

------------------------------------------------------------
--3. UPDATE Stored Procedure
--This procedure updates an existing branch based on ID.
Create PROCEDURE sp_UpdateBranch
  @BranchID INT,
  @Phone VARCHAR(13) = NULL,
  @City NVARCHAR(20) = NULL
AS
BEGIN
  BEGIN TRY
    -- Check if BranchID exists"
    IF NOT EXISTS (SELECT 1 FROM Branch WHERE ID = @BranchID)
    BEGIN
      PRINT 'Error: Branch ID does not exist in Branch table.';
      RETURN;
    END

    
    IF @Phone IS NOT NULL
    BEGIN
      IF EXISTS (SELECT 1 FROM Branch WHERE Phone = @Phone AND ID <> @BranchID)
      BEGIN
        PRINT 'Error: The provided Phone number is already assigned to another branch.';
        RETURN;
      END
    END

    IF @City IS NOT NULL
    BEGIN
      IF EXISTS (SELECT 1 FROM Branch WHERE City = @City AND ID <> @BranchID)
      BEGIN
        PRINT 'Error: The provided City is already assigned to another branch.';
        RETURN;
      END
    END

  
    BEGIN TRANSACTION;
    UPDATE Branch
    SET 
      Phone = ISNULL(@Phone, Phone),
      City = ISNULL(@City, City)
    WHERE ID = @BranchID;
    COMMIT TRANSACTION;

    PRINT 'Branch record updated successfully.';
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred: Could not update the Branch record.';
  END CATCH
END;
GO
-----------------------------------------
--4. DELETE Stored Procedure
--This procedure deletes a branch based on its ID.
CREATE PROCEDURE sp_DeleteBranch
  @BranchID INT
AS
BEGIN
  BEGIN TRY
    -- "Check if the record exists in the Branch tabl 
    IF NOT EXISTS (SELECT 1 FROM Branch WHERE ID = @BranchID)
    BEGIN
      PRINT 'Error: The Branch does not exist in Branch table.';
      RETURN;
    END

    -- start
    BEGIN TRANSACTION;

    -- 
    DELETE FROM Branch
    WHERE ID = @BranchID;

    COMMIT TRANSACTION;

    PRINT 'Branch deleted successfully.';
  END TRY
  BEGIN CATCH
   
    ROLLBACK TRANSACTION;
    PRINT 'Error occurred, cannot delete Branch.';
  END CATCH
END;
GO