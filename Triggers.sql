use ExaminationSystem



--! question

--* insert

-- Prevents insertion if CrsID and InsID combination does not exist in CoursesInstructors.
CREATE TRIGGER trg_InsteadOfInsert
ON question
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @CrsID INT, @InsID INT
    SELECT @CrsID = i.CrsID, @InsID = i.InsID FROM inserted AS i
    IF EXISTS (SELECT ci.CrsID FROM CoursesInstructors AS ci WHERE ci.CrsID = @CrsID AND ci.InsID = @InsID)
    BEGIN
        INSERT INTO question(Body, Mark, CorrectAnswer, TypeID, CrsID, InsID)
        SELECT Body, Mark, CorrectAnswer, TypeID, CrsID, InsID FROM inserted
    END
    ELSE
        RAISERROR('operation failed', 12, 1)
END;

--* update

-- Prevents update if question is in any student's exam. Ensures new CrsID and InsID exist in CoursesInstructors.
ALTER TRIGGER trg_QuestionAfterUpdate
ON question
AFTER UPDATE
AS
BEGIN
    DECLARE @ID INT, @CrsID INT, @InsID INT
    SELECT @ID = ID, @InsID = InsID, @CrsID = CrsID FROM inserted
    IF EXISTS (SELECT 1 FROM ExamQuestions AS ea WHERE ea.QuestionID = @ID)
    BEGIN
        SELECT @CrsID = CrsID, @InsID = InsID FROM deleted;
        UPDATE question
        SET CrsID = @CrsID, InsID = @InsID
        WHERE ID = @ID
        RAISERROR('not allowed to update question that already in students exams', 14, 1)
    END
    ELSE IF UPDATE(CrsID) OR UPDATE(InsID)
    BEGIN
        IF NOT EXISTS (SELECT ci.CrsID FROM CoursesInstructors AS ci WHERE ci.CrsID = @CrsID AND ci.InsID = @InsID)
        BEGIN
            SELECT @CrsID = CrsID, @InsID = InsID FROM deleted;
            UPDATE question
            SET CrsID = @CrsID, InsID = @InsID
            WHERE ID = @ID
        END
        ELSE
            RAISERROR('operation failed', 13, 1)
    END
END;

--! correct answer

--* insert

-- Sets CorrectAnswer to NULL if it does not exist in QuestionOptions.
CREATE TRIGGER trg_AfterInsertCorrectAnswer
ON question
AFTER INSERT
AS
BEGIN
    DECLARE @ID INT, @CorrectAnswer INT
    SELECT @ID = ID, @CorrectAnswer = CorrectAnswer FROM inserted
    IF NOT EXISTS (SELECT qa.OptionNum FROM QuestionOptions AS qa WHERE qa.OptionNum = @CorrectAnswer AND qa.QuestionID = @ID)
    BEGIN
        SET @CorrectAnswer = NULL;
        UPDATE question
        SET CorrectAnswer = @CorrectAnswer
        WHERE ID = @ID
    END
    ELSE
        PRINT 'correct answer set to NULL';
END;

--* update

-- Reverts CorrectAnswer if it does not exist in QuestionOptions.
CREATE TRIGGER trg_AfterUpdateCorrectAnswer
ON question
AFTER UPDATE
AS
BEGIN
    DECLARE @ID INT, @CorrectAnswer INT
    SELECT @ID = ID, @CorrectAnswer = CorrectAnswer FROM inserted
    IF UPDATE(CorrectAnswer)
    BEGIN
        IF NOT EXISTS (SELECT qa.OptionNum FROM QuestionOptions AS qa WHERE qa.OptionNum = @CorrectAnswer AND qa.QuestionID = @ID)
        BEGIN
            SELECT @CorrectAnswer = CorrectAnswer FROM deleted;
            UPDATE question
            SET CorrectAnswer = @CorrectAnswer
            WHERE ID = @ID
        END
        ELSE
            PRINT 'your input does not exist in question options';
    END
END;

--! question exam

--* insert

-- Ensures question has options and exam has not exceeded question count before insertion.
ALTER TRIGGER trg_ExamQuestionInsteadOfInsert
ON ExamQuestions
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @QuesID INT, @ExamID INT, @QuesCount INT = NULL, @quesCrs INT, @QesMark INT, @HasOption BINARY
    SELECT @QuesID = i.QuestionID, @ExamID = i.ExamID FROM inserted AS i
    SELECT @quesCrs = CrsID, @QesMark = Mark FROM question WHERE ID = @QuesID
    SELECT @QuesCount = e.QuestionCount FROM exam AS e WHERE e.CrsID = @quesCrs AND ID = @ExamID
    SET @HasOption = IIF(EXISTS(SELECT 1 FROM QuestionOptions WHERE QuestionID = @QuesID), 1, 0)
    IF (@QuesCount IS NOT NULL)
    BEGIN
        IF (SELECT COUNT(*) FROM ExamQuestions WHERE ExamID = @ExamID) < @QuesCount AND @HasOption = 1
        BEGIN
            BEGIN TRY
                BEGIN TRANSACTION
                INSERT INTO ExamQuestions(ExamID, QuestionID)
                VALUES (@ExamID, @QuesID)
                UPDATE Exam
                SET TotalMark += @QesMark
                WHERE ID = @ExamID
                COMMIT TRANSACTION
            END TRY
            BEGIN CATCH
                ROLLBACK TRANSACTION
                PRINT 'operation failed'
            END CATCH
        END
        ELSE IF @HasOption = 0
            RAISERROR('Question does not have options', 12, 1)
        ELSE
            RAISERROR('exam questions is full', 12, 1)
    END
    ELSE
        RAISERROR('operation failed', 12, 1)
END;

--* update

-- Prevents changing exam ID and ensures new question belongs to the same course.
ALTER TRIGGER trg_ExamQuestionAfterUpdate
ON ExamQuestions
AFTER UPDATE
AS
BEGIN
    DECLARE @QuesID INT, @ExamID INT, @QuesCrs INT, @QuesMark INT, @NewQuesID INT, @NewExamID INT, @NewQuesMark INT
    SELECT @ExamID = ExamID, @QuesID = QuestionID FROM deleted AS e
    SELECT @NewQuesID = i.QuestionID, @NewExamID = ExamID FROM inserted AS i
    SELECT @QuesCrs = CrsID, @NewQuesMark = Mark FROM question WHERE ID = @NewQuesID
    IF @ExamID != @NewExamID
    BEGIN
        UPDATE ExamQuestions
        SET ExamID = @ExamID, QuestionID = @QuesID
        WHERE ExamID = @NewExamID AND QuestionID = @NewQuesID;
        RAISERROR('You cannot change Exam', 16, 1)
    END
    ELSE IF NOT EXISTS (SELECT 1 FROM exam AS e WHERE e.CrsID = @QuesCrs AND ID = @ExamID)
    BEGIN
        UPDATE ExamQuestions
        SET ExamID = @ExamID, QuestionID = @QuesID
        WHERE ExamID = @NewExamID AND QuestionID = @NewQuesID;
        IF EXISTS (SELECT 1 FROM StudentExams WHERE ExamID = @ExamID)
        BEGIN
            RAISERROR('Exam already launched', 16, 1)
            RETURN;
        END
    END
    ELSE
    BEGIN
        SELECT @QuesMark = Mark FROM question WHERE ID = @QuesID
        UPDATE Exam
        SET TotalMark += (@NewQuesMark - @QuesMark)
        WHERE ID = @ExamID;
    END
END;

--! StudentsExamsAnswers

--* insert

-- Validates student's answer and updates answer grade and student's total grade.
CREATE TRIGGER trg_StudentsExamsAnswersAfterInsert
ON StudentsExamsAnswers
AFTER INSERT
AS
BEGIN
    DECLARE @stdID INT, @QuesID INT, @ExamID INT, @StdAnswer INT, @AnswerGrade TINYINT
    SELECT @stdID = StdID, @QuesID = QuestionID, @ExamID = ExamID, @StdAnswer = StdAnswer FROM inserted
    IF NOT EXISTS (SELECT 1 FROM StudentExams AS se JOIN ExamQuestions AS eq ON eq.ExamID = se.ExamID AND eq.ExamID = @ExamID AND se.StdID = @stdID AND eq.QuestionID = @QuesID)
        OR NOT EXISTS (SELECT 1 FROM QuestionOptions WHERE QuestionID = @QuesID AND OptionNum = @StdAnswer)
    BEGIN
        ROLLBACK
        RAISERROR('Wrong inputs', 13, 1)
        RETURN;
    END
    ELSE
    BEGIN
        SELECT @AnswerGrade = IIF(@StdAnswer = CorrectAnswer, Mark, 0) FROM question AS q WHERE q.ID = @QuesID
        BEGIN TRY
            BEGIN TRANSACTION
            UPDATE StudentsExamsAnswers
            SET AnswerGrade = @AnswerGrade
            WHERE StdID = @stdID AND QuestionID = @QuesID AND ExamID = @ExamID;
            UPDATE StudentExams
            SET Grade += @AnswerGrade
            WHERE StdID = @stdID AND ExamID = @ExamID
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            PRINT 'Operation Failed'
            ROLLBACK TRANSACTION
        END CATCH
    END
END;

--! student exam

--* insert

-- Prevents any insert operations on the StudentExams table.
CREATE TRIGGER trg_StudentExamInsertPrevent
ON StudentExams
AFTER INSERT
AS
BEGIN
    ROLLBACK
    RAISERROR('No operations allowed on this Table', 13, 1)
END;

--* update

-- Prevents updates to StdID and ExamID columns in StudentExams table.
ALTER TRIGGER trg_StudentExamPreventUpdateStdExam
ON StudentExams
AFTER UPDATE
AS
BEGIN
    IF UPDATE(StdID) OR UPDATE(ExamID)
    BEGIN
        ROLLBACK
        RAISERROR('you cannot update these data', 13, 1)
    END
END;

-- Prevents updates to the grade column in StudentExams table.
CREATE TRIGGER trg_StudentExamPreventUpdateGrade
ON StudentExams
AFTER UPDATE
AS
BEGIN
    IF UPDATE(grade)
    BEGIN
        ROLLBACK
        RAISERROR('you cannot update these data', 13, 1)
    END
END;

--* delete

-- Prevents any delete operations on the StudentExams table.
CREATE TRIGGER trg_StudentExamPreventDelete
ON StudentExams
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('No operations allowed on this Table', 13, 1)
END;

--! Exam

--* insert

-- Ensures CrsID and InsID combination exists in CoursesInstructors before insertion.
CREATE TRIGGER trg_ExamInsteadOfInsert
ON Exam
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ID INT, @Name VARCHAR(50), @CrsID INT, @InsID INT, @Duration DECIMAL(3,2), @QuestionCount INT
    SELECT @ID = ID, @Name = Name, @CrsID = CrsID, @InsID = InsID, @Duration = Duration, @QuestionCount = QuestionCount FROM inserted
    IF EXISTS (SELECT 1 FROM CoursesInstructors WHERE CrsID = @CrsID AND InsID = @InsID)
    BEGIN
        INSERT INTO Exam(Name, StartTime, Duration, QuestionCount, TotalMark, CrsID, InsID)
        VALUES (@Name, NULL, @Duration, @QuestionCount, 0, @CrsID, @InsID);
    END
    ELSE
        RAISERROR('insert valid values', 13, 1)
END;

-- Prevents updates to Exam table after exam has started. Restricts updates to Name, QuestionCount, and Duration columns.
CREATE TRIGGER trg_ExamPreventUpdate
ON Exam
AFTER UPDATE
AS
BEGIN
    DECLARE @StartTime DATETIME
    SELECT @StartTime = StartTime FROM deleted
    IF (@StartTime IS NOT NULL)
    BEGIN
        ROLLBACK
        RAISERROR('you cannot update exam data after launching exam', 13, 1)
    END
    ELSE IF (UPDATE(TotalMark) OR UPDATE(CrsID) OR UPDATE(InsID))
    BEGIN
        ROLLBACK
        RAISERROR('you can only update Name, QuestionCount, and Duration', 13, 1)
    END
END;

-- Prevents updating StartTime column in Exam table.
CREATE TRIGGER trg_ExamPreventUpdateStartTime
ON Exam
AFTER UPDATE
AS
BEGIN
    DECLARE @StartTime DATETIME
    SELECT @StartTime = StartTime FROM deleted
    IF UPDATE(StartTime)
    BEGIN
        ROLLBACK
        IF @StartTime IS NULL
            RAISERROR('you can only update Name, QuestionCount, and Duration', 13, 1)
    END
END;



--! StudentCourses


--* insert

-- Prevents any insert operations
-- on the StudentCourses table.

CREATE TRIGGER trg_StudentCoursesPreventInsert
ON StudentCourses
INSTEAD OF INSERT
AS
BEGIN
    RAISERROR('No operations allowed on this Table', 13, 1)
END;


--* update

-- Prevents any update operations on the StudentCourses table.
CREATE TRIGGER trg_StudentCoursesPreventUpdate
ON StudentCourses
INSTEAD OF UPDATE
AS
BEGIN
    RAISERROR('No operations allowed on this Table', 13, 1)
END;



--! Student

-- Ensure TrackID and IntakeID exist, insert courses for student, else rollback.

--* insert
Create TRIGGER trg_StudentAfterInsert
ON Student
AFTER INSERT
AS
BEGIN
    DECLARE @StdID INT , @IntakeID INT , @TrackID INT
    SELECT @StdID = ID , @IntakeID = IntakeID , @TrackID = TrackID FROM inserted ;
        IF NOT EXISTS(SELECT 1 FROM Track WHERE ID = @TrackID AND IntakeID = @IntakeID)
            BEGIN
                ROLLBACK
                RAISERROR('Insert correct intake and track',13,1)
            END
        ELSE
            BEGIN
                DISABLE TRIGGER trg_StudentCoursesPreventInsert ON StudentCourses ;
                INSERT into StudentCourses(StdID , CrsID)
                    SELECT  @StdID , CrsID FROM Intake as i JOIN Track as t on t.IntakeID = i.ID AND t.ID = @TrackID AND i.ID = @IntakeID JOIN TrackCourses as tc on tc.TrackID = t.ID ;
                ENABLE TRIGGER trg_StudentCoursesPreventInsert ON StudentCourses ;
            END
END;



--* update

-- Prevents updates to IntakeID and TrackID columns in Student table.
CREATE TRIGGER trg_StudentAfterUpdate
ON Student
AFTER UPDATE
AS
BEGIN
    IF UPDATE(IntakeID) OR UPDATE(TrackID)
    BEGIN
        ROLLBACK
        RAISERROR('you cannot update track or intake', 13, 1)
    END
END;
