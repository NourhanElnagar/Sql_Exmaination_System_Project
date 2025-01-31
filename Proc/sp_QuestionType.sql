use ExaminationSystem

------------ *QuestionType* ------------------
--- Stored procedure to Insert QuestionType ---
GO
CREATE PROC sp_InsertQuestionType
@Type NVARCHAR(30) 
AS
BEGIN
    IF @Type NOT IN ('True or False', 'Choose one')
    BEGIN
        PRINT 'Invalid type. Only "True or False" and "Choose one" are allowed.';
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT 1 FROM QuestionTypes WHERE Type = @Type)
        BEGIN
            PRINT 'This type already exists in the database.';
        END
        ELSE
        BEGIN
            INSERT INTO QuestionTypes (Type)
            VALUES (@Type);

            PRINT 'Question type inserted successfully.';
        END
    END
END;
GO

---------Select---------
CREATE PROC sp_SelectQuestionType
@QuestionTypeID INT = NULL     
AS
BEGIN
    IF @QuestionTypeID IS NOT NULL 
    BEGIN
        IF EXISTS (SELECT 1 FROM QuestionTypes WHERE ID = @QuestionTypeID)
        BEGIN
            SELECT * FROM QuestionTypes 
            WHERE ID = @QuestionTypeID
        END
        ELSE
        BEGIN
            PRINT 'No data found for the given QuestionTypesID.';
        END
    END

---QuestionTypeID = NULL  ---
    ELSE IF @QuestionTypeID IS NULL
    BEGIN
        SELECT * FROM QuestionTypes 
    END 
END
GO

----Trigger to deny update,delete--------

CREATE TRIGGER trg_QuestionTypes
ON QuestionTypes
INSTEAD OF UPDATE,DELETE 
AS
BEGIN  
	RaisError('You cannot delete or update',16 ,1);
END
GO


--------------Insert Data-----------
EXEC sp_InsertQuestionType 
@Type = 'Choose one'
EXEC sp_InsertQuestionType 
@Type = 'True or False'


--------------SELECT Data-----------
EXEC sp_SelectQuestionType
@QuestionTypeID=1

GO
--------UPDATE , DELETE-------
UPDATE QuestionTypes
SET Type = 'Choose all '  
WHERE Type = 'True or False'; 

DELETE FROM QuestionTypes
WHERE Type = 'Choice one';

























