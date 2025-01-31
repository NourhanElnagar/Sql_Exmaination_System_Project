create PROCEDURE sp_insertstudExamAnswer @studID int,
@ExamId int,
@questionId int,
@studAnswer tinyint,
@Answergrade tinyint AS BEGIN BEGIN TRY IF NOT EXISTS (
    SELECT 1
    FROM Student
    WHERE ID = @studID
) BEGIN PRINT 'Student id did not insert';
END IF NOT EXISTS (
    SELECT 1
    FROM Exam
    WHERE ID = @ExamId
) BEGIN PRINT 'exam id did not insert';
END IF NOT EXISTS (
    SELECT 1
    FROM Question
    WHERE ID = @questionId
) BEGIN PRINT 'Question id did not insert';
END BEGIN TRANSACTION;
INSERT INTO StudentsExamAnswers (
        StdID,
        QuestionID,
        ExamID,
        StdAnswer,
        AnswerGrade
    )
VALUES (
        @studID,
        @questionId,
        @ExamId,
        @studAnswer,
        @Answergrade
    );
COMMIT TRANSACTION;
END TRY BEGIN CATCH ROLLBACK TRANSACTION;
PRINT 'StudentExamAnswers did not insert';
END CATCH
END
GO ----------------------------------------
    CREATE PROCEDURE sp_updateStudentsAnswers @S_ID INT,
    @QuestionID INT,
    @StdAnswer TINYINT = NULL,
    @AnswerGrade TINYINT = NULL AS BEGIN -- Update StudentsAnswers
UPDATE StudentsAnswers
SET StdAnswer = ISNULL(@StdAnswer, StdAnswer),
    AnswerGrade = ISNULL(@AnswerGrade, AnswerGrade)
WHERE StdID = @S_ID
    AND QuestionID = @QuestionID;
-- Check if any row was updated
IF @@ROWCOUNT = 0 BEGIN PRINT 'No row found with the specified ID.';
END
ELSE BEGIN PRINT 'Row updated successfully.';
END
END;
-------------------------------------------------------------
alter PROCEDURE sp_DeleteStudentExamAnswer @StudentID INT = NULL,
@ExamID INT = NULL,
@QuestionID INT = NULL AS BEGIN BEGIN TRY BEGIN TRANSACTION;
IF @StudentID IS NULL
AND @ExamID IS NULL
AND @QuestionID IS NULL BEGIN
DELETE FROM StudentExamAnswer;
PRINT 'All records deleted successfully.';
END
ELSE BEGIN IF NOT EXISTS (
    SELECT 1
    FROM StudentExamAnswer
    WHERE (
            @StudentID IS NULL
            OR StdID = @StudentID
        )
        AND (
            @ExamID IS NULL
            OR ExamID = @ExamID
        )
        AND (
            @QuestionID IS NULL
            OR QuestionID = @QuestionID
        )
) BEGIN PRINT 'No matching records found in the StudentExamAnswer table.';
RETURN;
END
DELETE FROM StudentExamAnswer
WHERE (
        @StudentID IS NULL
        OR StdID = @StudentID
    )
    AND (
        @ExamID IS NULL
        OR ExamID = @ExamID
    )
    AND (
        @QuestionID IS NULL
        OR QuestionID = @QuestionID
    );
PRINT 'Record(s) deleted successfully.';
END COMMIT TRANSACTION;
END TRY BEGIN CATCH IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
SELECT ERROR_MESSAGE() AS ErrorMessage,
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState;
END CATCH
END;
GO ------------------------------------------------
    CREATE PROCEDURE sp_SelectStudentExamAnswer @StudentID INT = NULL,
    @QuestionID INT = NULL,
    @ExamID INT = NULL AS BEGIN --
    IF @StudentID IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM StudentExamAnswer
        WHERE StdID = @StudentID
    ) BEGIN PRINT 'invalid data';
END
ELSE BEGIN
SELECT StdID,
    QuestionID,
    ExamID,
    StdAnswer,
    AnswerGrade
FROM StudentExamAnswer
WHERE (
        @StudentID IS NULL
        OR StdID = @StudentID
    )
    AND (
        @QuestionID IS NULL
        OR QuestionID = @QuestionID
    )
    AND (
        @ExamID IS NULL
        OR ExamID = @ExamID
    );
END
END;
GO