USE ExaminationSystem

GO


--! QuestionType


--* update & delete
-- Prevents deletion and update operations on the QuestionTypes table by raising an error

CREATE TRIGGER trg_QuestionTypes
ON QuestionTypes
INSTEAD OF UPDATE,DELETE
AS
BEGIN
	RAISERROR('You cannot delete or update',16 ,1);
END
GO

-- ! questionOptions

--* insert

-- This trigger prevents inserting options for questions that are already in exams.

CREATE TRIGGER trg_questionOptionsPreventInsert
ON QuestionOptions
after INSERT
AS
BEGIN
    DECLARE @QuesID INT
    SELECT @QuesID = QuestionID
    FROM inserted
    IF EXISTS(SELECT 1
    FROM ExamQuestions
    WHERE QuestionID = @QuesID)
        BEGIN
        ROLLBACK
        RAISERROR('you can not insert option for question that is already in exams',16,1)
    END

END;

GO


--  * update

-- This trigger prevents updating options for questions that are already in exams.

CREATE TRIGGER trg_questionOptionsPreventUpdate
ON QuestionOptions
after UPDATE
AS
BEGIN
    DECLARE @QuesID INT , @NewQuesID INT
    SELECT @QuesID = QuestionID
    FROM deleted
    SELECT @NewQuesID = QuestionID
    FROM inserted
    IF EXISTS(SELECT 1
        FROM ExamQuestions
        WHERE QuestionID = @QuesID) OR EXISTS(SELECT 1
        FROM ExamQuestions
        WHERE QuestionID = @NewQuesID)
        BEGIN
        ROLLBACK
        RAISERROR('you can not update options for question that is already in exams',16,1)
    END

END;

GO


--* delete

-- This trigger prevents deletion of question options if the question is already used in exams.

CREATE TRIGGER trg_questionOptionsPreventDelete
ON QuestionOptions
after DELETE
AS
BEGIN
    DECLARE @QuesID INT
    SELECT @QuesID = QuestionID
    FROM deleted
    IF EXISTS(SELECT 1
    FROM ExamQuestions
    WHERE QuestionID = @QuesID)
        BEGIN
        ROLLBACK
        RAISERROR('you can not delete options for question that is already in exams',16,1)
    END

END;

GO


--! question

--* insert

-- Prevents insertion if CrsID and InsID combination does not exist in CoursesInstructors.
CREATE TRIGGER trg_InsteadOfInsert
ON question
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @CrsID INT, @InsID INT
    SELECT @CrsID = i.CrsID, @InsID = i.InsID
    FROM inserted AS i
    IF EXISTS (SELECT ci.CrsID
    FROM CoursesInstructors AS ci
    WHERE ci.CrsID = @CrsID AND ci.InsID = @InsID)
    BEGIN
        INSERT INTO question
            (Body, Mark, CorrectAnswer, TypeID, CrsID, InsID)
        SELECT Body, Mark, CorrectAnswer, TypeID, CrsID, InsID
        FROM inserted
    END
    ELSE
        RAISERROR('operation failed', 12, 1)
END;

GO


--* update

-- Prevents update if question is in any student's exam. Ensures new CrsID and InsID exist in CoursesInstructors.
CREATE TRIGGER trg_QuestionAfterUpdate
ON question
AFTER UPDATE
AS
BEGIN
    DECLARE @ID INT, @CrsID INT, @InsID INT
    SELECT @ID = ID, @InsID = InsID, @CrsID = CrsID
    FROM inserted
    IF EXISTS (SELECT 1
    FROM ExamQuestions AS ea
    WHERE ea.QuestionID = @ID)
    BEGIN
        ROLLBACK
        RAISERROR('not allowed to update question that already in students exams', 14, 1)
    END
    ELSE IF UPDATE(CrsID) OR UPDATE(InsID)
    BEGIN
        IF NOT EXISTS (SELECT ci.CrsID
        FROM CoursesInstructors AS ci
        WHERE ci.CrsID = @CrsID AND ci.InsID = @InsID)
        BEGIN
            SELECT @CrsID = CrsID, @InsID = InsID
            FROM deleted;
            UPDATE question
            SET CrsID = @CrsID, InsID = @InsID
            WHERE ID = @ID
        END
        ELSE
            RAISERROR('operation failed', 16, 1)
    END

END;

GO


--! correct answer

--* insert

-- Sets CorrectAnswer to NULL if it does not exist in QuestionOptions.
CREATE TRIGGER trg_AfterInsertCorrectAnswer
ON question
AFTER INSERT
AS
BEGIN
    DECLARE @ID INT, @CorrectAnswer INT
    SELECT @ID = ID, @CorrectAnswer = CorrectAnswer
    FROM inserted
    IF NOT EXISTS (SELECT qa.OptionNum
    FROM QuestionOptions AS qa
    WHERE qa.OptionNum = @CorrectAnswer AND qa.QuestionID = @ID)
    BEGIN
        SET @CorrectAnswer = NULL;
        UPDATE question
        SET CorrectAnswer = @CorrectAnswer
        WHERE ID = @ID
    END
    ELSE
        PRINT 'correct answer set to NULL';
END;

GO


--* update

-- Reverts CorrectAnswer if it does not exist in QuestionOptions.
CREATE TRIGGER trg_AfterUpdateCorrectAnswer
ON question
AFTER UPDATE
AS
BEGIN
    DECLARE @ID INT, @CorrectAnswer INT
    SELECT @ID = ID, @CorrectAnswer = CorrectAnswer
    FROM inserted
    IF UPDATE(CorrectAnswer)
    BEGIN
        IF NOT EXISTS (SELECT qa.OptionNum
        FROM QuestionOptions AS qa
        WHERE qa.OptionNum = @CorrectAnswer AND qa.QuestionID = @ID)
        BEGIN
            SELECT @CorrectAnswer = CorrectAnswer
            FROM deleted;
            UPDATE question
            SET CorrectAnswer = @CorrectAnswer
            WHERE ID = @ID
        END
        ELSE
            PRINT 'your input does not exist in question options';
    END

END;

GO


--! question exam

--* insert

-- This trigger prevents any insert operations on the ExamQuestions table by raising an error.

CREATE TRIGGER trg_ExamQuestionsPreventInsert
ON ExamQuestions
INSTEAD OF INSERT
AS
BEGIN
    RAISERROR ('you can not do any operation in this table',16,1)


END;

GO


--* update

-- Prevents changing exam ID and ensures new question belongs to the same course.
CREATE TRIGGER trg_ExamQuestionAfterUpdate
ON ExamQuestions
AFTER UPDATE
AS
BEGIN
    DECLARE @QuesID INT, @ExamID INT, @QuesCrs INT, @QuesMark INT, @NewQuesID INT, @NewExamID INT, @NewQuesMark INT
    SELECT @ExamID = ExamID, @QuesID = QuestionID
    FROM deleted AS e
    SELECT @NewQuesID = i.QuestionID, @NewExamID = ExamID
    FROM inserted AS i
    SELECT @QuesCrs = CrsID, @NewQuesMark = Mark
    FROM question
    WHERE ID = @NewQuesID
    IF @ExamID != @NewExamID
    BEGIN
        UPDATE ExamQuestions
        SET ExamID = @ExamID, QuestionID = @QuesID
        WHERE ExamID = @NewExamID AND QuestionID = @NewQuesID;
        RAISERROR('You cannot change Exam', 16, 1)
    END
    ELSE IF NOT EXISTS (SELECT 1
    FROM exam AS e
    WHERE e.CrsID = @QuesCrs AND ID = @ExamID)
    BEGIN
        UPDATE ExamQuestions
        SET ExamID = @ExamID, QuestionID = @QuesID
        WHERE ExamID = @NewExamID AND QuestionID = @NewQuesID;
        IF EXISTS (SELECT 1
        FROM StudentExams
        WHERE ExamID = @ExamID)
        BEGIN
            RAISERROR('Exam already launched', 16, 1)
            RETURN;
        END
    END
    ELSE
    BEGIN
        SELECT @QuesMark = Mark
        FROM question
        WHERE ID = @QuesID
        UPDATE Exam
        SET TotalMark += (@NewQuesMark - @QuesMark)
        WHERE ID = @ExamID;
    END

END;

GO


--! StudentsExamsAnswers

--* insert


-- This trigger updates the student's exam grade after inserting an answer, ensuring valid inputs and exam time constraints.

CREATE TRIGGER trg_StudentsExamsAnswersAfterInsert
ON StudentsExamsAnswers
AFTER INSERT
AS
BEGIN
    DECLARE @stdID INT, @QuesID INT, @ExamID INT, @StdAnswer INT, @AnswerGrade TINYINT , @ExamEndTime DATETIME
    SELECT @stdID = StdID, @QuesID = QuestionID, @ExamID = ExamID, @StdAnswer = StdAnswer
    FROM inserted
    SELECT @ExamEndTime = EndTime
    FROM Exam
    WHERE ID = @ExamID
    IF NOT EXISTS (SELECT 1
        FROM StudentExams AS se JOIN ExamQuestions AS eq ON eq.ExamID = se.ExamID AND eq.ExamID = @ExamID AND se.StdID = @stdID AND eq.QuestionID = @QuesID)
        OR NOT EXISTS (SELECT 1
        FROM QuestionOptions
        WHERE QuestionID = @QuesID AND OptionNum = @StdAnswer)
    BEGIN
        ROLLBACK
        RAISERROR('Wrong inputs', 16, 1)
        RETURN;
    END
    ELSE IF (GETDATE() > @ExamEndTime)
        BEGIN
        ROLLBACK
        RAISERROR('Exam TimeOut', 16, 1)
    END
    ELSE
    BEGIN
        SELECT @AnswerGrade = IIF(@StdAnswer = CorrectAnswer, Mark, 0)
        FROM question AS q
        WHERE q.ID = @QuesID
        BEGIN TRY
            BEGIN TRANSACTION;
            DISABLE TRIGGER trg_StudentsExamsAnswersPreventUpdate ON StudentsExamsAnswers ;
            UPDATE StudentsExamsAnswers
            SET AnswerGrade = @AnswerGrade
            WHERE StdID = @stdID AND QuestionID = @QuesID AND ExamID = @ExamID;
            ENABLE TRIGGER trg_StudentsExamsAnswersPreventUpdate ON StudentsExamsAnswers ;

           DISABLE TRIGGER trg_StudentExamPreventUpdateGrade ON StudentExams ;

            UPDATE StudentExams
            SET Grade += @AnswerGrade
            WHERE StdID = @stdID AND ExamID = @ExamID ;

            ENABLE TRIGGER trg_StudentExamPreventUpdateGrade ON StudentExams ;

            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            PRINT 'Operation Failed'
            ROLLBACK TRANSACTION
        END CATCH
    END

END;

GO


--* update















-- This trigger prevents updates to the StudentsExamsAnswers table after the exam end time and ensures only valid updates to student answers.
ALTER TRIGGER trg_StudentsExamsAnswersPreventUpdate
ON StudentsExamsAnswers
AFTER UPDATE
AS
BEGIN
    DECLARE @StdID INT, @QuesID INT, @ExamID INT, @StdAnswer TINYINT, @NStdAnswer TINYINT, @OAnswerGrade TINYINT, @NAnswerGrade TINYINT, @ExamEndTime DATETIME
    SELECT @StdID = StdID, @QuesID = QuestionID, @ExamID = ExamID, @OAnswerGrade = AnswerGrade
    FROM deleted;
    SELECT @NStdAnswer = StdAnswer
    FROM inserted;
    SELECT @ExamEndTime = EndTime
    FROM Exam
    WHERE ID = @ExamID;

    IF (GETDATE() > @ExamEndTime)
    BEGIN
        ROLLBACK;
        RAISERROR('Exam TimeOut', 16, 1);
    END
    ELSE IF NOT UPDATE(StdAnswer)
    BEGIN
        ROLLBACK;
        RAISERROR('you can update your answer only', 16, 1);
    END
    ELSE IF NOT EXISTS (SELECT 1
        FROM StudentExams AS se JOIN ExamQuestions AS eq ON eq.ExamID = se.ExamID AND eq.ExamID = @ExamID AND se.StdID = @StdID AND eq.QuestionID = @QuesID)
        OR NOT EXISTS (SELECT 1
        FROM QuestionOptions
        WHERE QuestionID = @QuesID AND OptionNum = @NStdAnswer)
    BEGIN
        ROLLBACK;
        RAISERROR('Wrong inputs', 16, 1);
        RETURN;
    END
    ELSE
    BEGIN
        SELECT @NAnswerGrade = IIF(@NStdAnswer = CorrectAnswer, Mark, 0)
        FROM question AS q
        WHERE q.ID = @QuesID;
        BEGIN TRY
            BEGIN TRANSACTION;
            UPDATE StudentsExamsAnswers
            SET AnswerGrade = @NAnswerGrade
            WHERE StdID = @StdID AND QuestionID = @QuesID AND ExamID = @ExamID;

            DISABLE TRIGGER trg_StudentExamPreventUpdateGrade ON StudentExams;

            UPDATE StudentExams
            SET Grade = (select SUM(sea.AnswerGrade) FROM question as q JOIN StudentsExamsAnswers sea on sea.QuestionID = q.ID AND  StdID = @StdID AND ExamID = @ExamID)
            WHERE StdID = @StdID AND ExamID = @ExamID;

            ENABLE TRIGGER trg_StudentExamPreventUpdateGrade ON StudentExams;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            PRINT 'Operation Failed';
            ROLLBACK TRANSACTION;
        END CATCH
    END

END;

GO



--* delete

-- This trigger prevents deletion of records from the StudentsExamsAnswers table.

CREATE TRIGGER trg_StudentsExamsAnswersPreventDelete
ON StudentsExamsAnswers
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('You can not delete from this table',16,1)

END ;

GO


--! student exam

--* insert

-- Prevents any insert operations on the StudentExams table.
CREATE TRIGGER trg_StudentExamInsertPrevent
ON StudentExams
AFTER INSERT
AS
BEGIN
    ROLLBACK
    RAISERROR('No operations allowed on this Table', 16, 1)

END;

GO


--* update

-- Prevents updates to StdID and ExamID columns in StudentExams table.
CREATE TRIGGER trg_StudentExamPreventUpdateStdExam
ON StudentExams
AFTER UPDATE
AS
BEGIN
    IF UPDATE(StdID) OR UPDATE(ExamID)
    BEGIN
        ROLLBACK
        RAISERROR('you cannot update these data', 16, 1)
    END
END;

GO


-- Prevents updates to the grade column in StudentExams table.
CREATE TRIGGER trg_StudentExamPreventUpdateGrade
ON StudentExams
AFTER UPDATE
AS
BEGIN
    IF UPDATE(grade)
    BEGIN
        ROLLBACK
        RAISERROR('you cannot update these data', 16, 1)
    END

END;

GO


--* delete

-- Prevents any delete operations on the StudentExams table.
CREATE TRIGGER trg_StudentExamPreventDelete
ON StudentExams
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('No operations allowed on this Table', 16, 1)
END;

GO


--! Exam

--* insert

-- Ensures CrsID and InsID combination exists in CoursesInstructors before insertion.
CREATE TRIGGER trg_ExamInsteadOfInsert
ON Exam
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ID INT, @Name VARCHAR(50), @CrsID INT, @InsID INT, @Duration DECIMAL(3,2), @QuestionCount INT
    SELECT @ID = ID, @Name = Name, @CrsID = CrsID, @InsID = InsID, @Duration = Duration, @QuestionCount = QuestionCount
    FROM inserted
    IF EXISTS (SELECT 1
    FROM CoursesInstructors
    WHERE CrsID = @CrsID AND InsID = @InsID)
    BEGIN
        INSERT INTO Exam
            (Name, StartTime, Duration, QuestionCount, TotalMark, CrsID, InsID)
        VALUES
            (@Name, NULL, @Duration, @QuestionCount, 0, @CrsID, @InsID);
    END
    ELSE
        RAISERROR('insert valid values', 16, 1)
END;

GO


-- Prevents updates to Exam table after exam has started. Restricts updates to Name, QuestionCount, and Duration columns.
CREATE TRIGGER trg_ExamPreventUpdate
ON Exam
AFTER UPDATE
AS
BEGIN
    DECLARE @StartTime DATETIME
    SELECT @StartTime = StartTime
    FROM deleted
    IF (@StartTime IS NOT NULL)
    BEGIN
        ROLLBACK
        RAISERROR('you cannot update exam data after launching exam', 16, 1)
    END
    ELSE IF (UPDATE(TotalMark) OR UPDATE(CrsID) OR UPDATE(InsID))
    BEGIN
        ROLLBACK
        RAISERROR('you can only update Name, QuestionCount, and Duration', 16, 1)
    END
END;

GO

-- Prevents updating StartTime column in Exam table.
CREATE TRIGGER trg_ExamPreventUpdateStartTime
ON Exam
AFTER UPDATE
AS
BEGIN
    DECLARE @StartTime DATETIME
    SELECT @StartTime = StartTime
    FROM deleted
    IF UPDATE(StartTime)
    BEGIN
        ROLLBACK
        IF @StartTime IS NULL
            RAISERROR('you can only update Name, QuestionCount, and Duration', 16, 1)
    END
END;

GO


--! StudentCourses


--* insert

-- Prevents any insert operations
-- on the StudentCourses table.

CREATE TRIGGER trg_StudentCoursesPreventInsert
ON StudentCourses
INSTEAD OF INSERT
AS
BEGIN
    RAISERROR('No operations allowed on this Table', 16, 1)
END;

GO


--* update

-- Prevents any update operations on the StudentCourses table.
CREATE TRIGGER trg_StudentCoursesPreventUpdate
ON StudentCourses
INSTEAD OF UPDATE
AS
BEGIN
    RAISERROR('No operations allowed on this Table', 16, 1)
END;

GO


--* delete

-- This trigger prevents any delete operations on the StudentCourses table by raising an error.

CREATE TRIGGER trg_StudentCoursesPreventDelete
ON StudentCourses
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('No operations allowed on this Table', 16, 1)
END;

GO


--! Student



--* insert


-- Ensures valid TrackID and IntakeID before insertion.
-- Inserts student courses if valid, else raises error.

CREATE TRIGGER trg_StudentAfterInsert
ON Student
AFTER INSERT
AS
BEGIN
    DECLARE  @IntackStartDate DATE ,  @StdID INT , @IntakeID INT , @TrackID INT
    SELECT @StdID = ID , @IntakeID = IntakeID , @TrackID = TrackID
    FROM inserted
    ;
    SELECT @IntackStartDate = StartDate
    FROM Track AS t JOIN Intake AS i ON t.IntakeID = i.ID AND i.ID = @IntakeID AND t.ID = @TrackID

    IF NOT EXISTS(SELECT 1
        FROM Track
        WHERE ID = @TrackID AND IntakeID = @IntakeID) OR (GETDATE() > @IntackStartDate)
            BEGIN
        ROLLBACK
        RAISERROR('Insert correct intake and track',16,1)
    END
        ELSE
            BEGIN
    DISABLE TRIGGER trg_StudentCoursesPreventInsert ON StudentCourses ;
    INSERT INTO StudentCourses
        (StdID , CrsID)
    SELECT s.ID , CrsID
    FROM Student AS s JOIN Intake AS i
        ON s.IntakeID = i.ID AND s.ID = @StdID JOIN Track AS t
        ON t.IntakeID = i.ID AND t.ID = @TrackID AND i.ID = @IntakeID JOIN TrackCourses AS tc
        ON tc.TrackID = t.ID
    ;

    ENABLE TRIGGER trg_StudentCoursesPreventInsert ON StudentCourses ;
END
END;

GO



--* update




-- This trigger prevents updates to TrackID or IntakeID in the Student table.
-- It raises an error and rolls back the transaction if such updates are attempted.

CREATE TRIGGER trg_StudentAfterUpdate
ON Student
AFTER UPDATE
AS
BEGIN
    DECLARE @IntackStartDate DATE ,  @StdID INT , @IntakeID INT , @TrackID INT
    SELECT @StdID = ID , @IntakeID = IntakeID , @TrackID = TrackID
    FROM inserted
    ;
    SELECT @IntackStartDate = StartDate
    FROM Track AS t JOIN Intake AS i ON t.IntakeID = i.ID AND i.ID = @IntakeID AND t.ID = @TrackID

    IF UPDATE(TrackID) OR UPDATE(IntakeID)
    BEGIN
        ROLLBACK
        RAISERROR('you cannot update track or intake ', 16, 1)
    END

END;

GO


--! TrackCourses

--* insert


-- Prevents insertion of courses into tracks with registered students
-- Rolls back transaction and raises an error if condition is met

CREATE TRIGGER trg_TrackCoursesPreventInsert
ON TrackCourses
AFTER INSERT
AS
BEGIN
    DECLARE @TrackID INT
    SELECT @TrackID = TrackID
    FROM inserted
    IF EXISTS(SELECT 1
    FROM Student
    WHERE TrackID = @TrackID)
        BEGIN
        ROLLBACK
        RAISERROR('can not add course to track that have students registered',16,1)
    END

END;

GO


--* update


-- Prevents updating TrackCourses if students are registered in the old or new track
-- Rolls back the transaction and raises an error if the condition is met


CREATE TRIGGER trg_TrackCoursesPreventUpdate
ON TrackCourses
AFTER UPDATE
AS
BEGIN
    DECLARE @OTrackID INT , @NTrackID  INT
    SELECT @OTrackID = TrackID
    FROM deleted
    SELECT @NTrackID = TrackID
    FROM inserted
    IF EXISTS(SELECT 1
        FROM Student
        WHERE TrackID = @OTrackID) OR EXISTS(SELECT 1
        FROM Student
        WHERE TrackID = @NTrackID)
        BEGIN
        ROLLBACK
        RAISERROR('can not update course to track that have students registered',16,1)
    END

END;

GO


--* delete




-- Prevents deletion of a track course if students are registered
-- Rolls back the transaction and raises an error if students exist



CREATE TRIGGER trg_TrackCoursesPreventDelete
ON TrackCourses
AFTER DELETE
AS
BEGIN
    DECLARE @TrackID INT
    SELECT @TrackID = TrackID
    FROM deleted
    IF EXISTS(SELECT 1
    FROM Student
    WHERE TrackID = @TrackID)
        BEGIN
        ROLLBACK
        RAISERROR('can not delete course FROM track that have students registered',16,1)
    END

END;

GO


-- !   Track

-- * update

-- This trigger prevents updating the IntakeID in the Track table if the intake is already launched and exists in the Student table.

CREATE TRIGGER trg_TrackPreventUpdateIntack
ON Track
AFTER UPDATE
AS
BEGIN
    DECLARE @IntakeID INT
    SELECT @IntakeID = IntakeID
    FROM deleted
    IF UPDATE(IntakeID) AND EXISTS(SELECT 1
        FROM Student
        WHERE IntakeID = @IntakeID)
        BEGIN
        ROLLBACK
        RAISERROR('you can not update track for launched intake',16,1)
    END

END ;

GO
