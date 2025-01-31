alter PROCEDURE sp_SelectStudentExam @StudentID INT = NULL AS BEGIN IF @StudentID IS NULL BEGIN
SELECT *
FROM StudentExams;
END
ELSE BEGIN IF EXISTS (
    SELECT 1
    FROM student
    WHERE ID = @StudentID
) BEGIN
SELECT *
FROM StudentExams
WHERE StdID = @StudentID;
END
ELSE BEGIN print 'student ID does not exist.';
END
END
END
GO --------------------------------------------
    alter PROCEDURE sp_studExams @studID int,
    @ExamId int,
    @grade tinyint AS BEGIN BEGIN TRY IF NOT EXISTS (
        SELECT 1
        FROM Student
        WHERE ID = @studID
    ) BEGIN PRINT 'Student id did not insert';
END IF NOT EXISTS (
    SELECT 1
    FROM Exam
    WHERE ID = @ExamId
) BEGIN PRINT 'exam id did not insert';
END BEGIN TRANSACTION;
INSERT INTO StudentExams (StdID, ExamID, Grade)
VALUES (@studID, @ExamID, @Grade);
COMMIT TRANSACTION;
END TRY BEGIN CATCH ROLLBACK TRANSACTION;
PRINT 'StudentExam did not insert';
END CATCH
END
GO ----------------------------------------------
    create PROCEDURE sp_updateStudentExams @StdID INT,
    @ExamID INT,
    @GRADE TINYINT = NULL AS BEGIN -- Update the StudentExams table
UPDATE StudentExams
SET Grade = ISNULL(@GRADE, Grade)
WHERE StdID = @StdID
    and ExamID = @ExamID;
-- Check if any row was updated
IF @@ROWCOUNT = 0 BEGIN PRINT 'No row found with the specified ID.';
END
ELSE BEGIN PRINT 'Row updated successfully.';
END
END ------------------------------------------------------
ALTER PROCEDURE sp_DeleteStudentExams @StudentID INT = NULL,
@ExamID INT = NULL AS BEGIN BEGIN TRY BEGIN TRANSACTION;
IF @StudentID IS NULL
AND @ExamID IS NULL BEGIN
DELETE FROM StudentExams;
PRINT 'All records deleted successfully.';
END
ELSE BEGIN IF NOT EXISTS (
    SELECT 1
    FROM StudentExams
    WHERE (
            @StudentID IS NULL
            OR StdID = @StudentID
        )
        AND (
            @ExamID IS NULL
            OR ExamID = @ExamID
        )
) BEGIN PRINT 'No matching records found in the StudentExams table.';
RETURN;
END
DELETE FROM StudentExams
WHERE (
        @StudentID IS NULL
        OR StdID = @StudentID
    )
    AND (
        @ExamID IS NULL
        OR ExamID = @ExamID
    );
PRINT 'Record(s) deleted successfully.';
END COMMIT TRANSACTION;
END TRY BEGIN CATCH IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
SELECT ERROR_MESSAGE() AS ErrorMessage,
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState;
END CATCH
END;
GO