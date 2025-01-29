USE ExaminationSystem

--!Student

-- GO
-- CREATE PROCEDURE sp_InsertStudent
--     @Fname NVARCHAR(30) ,
--     @Lname NVARCHAR(30),
--     @BD DATE,
--     @Gender VARCHAR(1),
--     @Email VARCHAR(50),
--     @Password VARCHAR(10),
--     @st NVARCHAR(50),
--     @city VARCHAR(50),
--     @Phone VARCHAR(13),
--     @IntakeID INT,
--     @TrackID INT
-- AS
-- BEGIN
--     BEGIN TRY
--         BEGIN TRANSACTION;

--         INSERT INTO Student (Fname, Lname, BD, Gender, Email, Password, st, city, Phone, IntakeID, TrackID)
--         VALUES (@Fname, @Lname, @BD, @Gender, @Email, @Password, @st, @city, @Phone, @IntakeID, @TrackID);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         ROLLBACK TRANSACTION;
--         PRINT 'Student did not insert' ;
--     END CATCH
-- END;

-- GO

-- CREATE PROC sp_UpdateStudent
--     @ID INT ,
--     @Fname NVARCHAR(30) = NULL,
--     @Lname NVARCHAR(30) =NULL,
--     @BD DATE =NULL,
--     @Gender VARCHAR(1) =NULL,
--     @Email VARCHAR(50) =NULL,
--     @Password VARCHAR(10) =NULL,
--     @st NVARCHAR(50) =NULL,
--     @city VARCHAR(50) =NULL,
--     @Phone VARCHAR(13) =NULL,
--     @IntakeID INT =NULL,
--     @TrackID INT =NULL
--     AS
--     BEGIN

--    BEGIN TRY
--         BEGIN TRANSACTION;

--         UPDATE Student
--         SET
--          Fname = ISNULL(@Fname,Fname),
--          Lname = ISNULL(@Lname,Lname),
--          BD = ISNULL(@BD,BD),
--          Gender = ISNULL(@Gender,Gender),
--          Email = ISNULL(@Email,Email),
--          Password = ISNULL(@Password,Password),
--          St = ISNULL(@St,St),
--          City = ISNULL(@City,City),
--          Phone = ISNULL(@Phone,Phone),
--          IntakeID = ISNULL(@IntakeID,IntakeID),
--          TrackID = ISNULL(@TrackID,TrackID)
--          WHERE ID = @ID

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         ROLLBACK TRANSACTION;
--         PRINT 'Student did not Update' ;
--     END CATCH

--     END;

-- GO

-- CREATE PROC sp_DeleteStudent @ID int
-- AS
-- BEGIN
--  BEGIN TRY
--         BEGIN TRANSACTION;

--         DELETE Student
--          WHERE ID = @ID

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         ROLLBACK TRANSACTION;
--         PRINT 'Student did not delete';
--     END CATCH
-- END;

-- GO


-- -- question

-- CREATE PROC sp_InsertQuestion
-- @Body VARCHAR(150),
-- @Mark TINYINT ,
-- @CrsID int ,
-- @TypeID int ,
-- @InsID  int
-- AS
-- BEGIN

--  BEGIN TRY
--         BEGIN TRANSACTION;

--         INSERT INTO Question (Body, Mark, CrsID, TypeID, InsID)
--         VALUES ( @Body, @Mark, @CrsID, @TypeID, @InsID);

--         COMMIT TRANSACTION;
--     END TRY
--     BEGIN CATCH
--         ROLLBACK TRANSACTION;
--         PRINT 'question did not insert';
--     END CATCH

-- END;


GO



--* Procedure: sp_GenerateExam
--* Description: Generates an exam by inserting questions and assigning it to students.
--* Parameters:
--*     @ExamID (int) - The ID of the exam to be generated.


CREATE PROC sp_GenerateExam
    @ExamID INT ,
    @ChooseOneCount TINYINT ,
    @TrueFalseCount TINYINT

AS
BEGIN
    -- Declare variables for exam start time, course ID, and question count
    DECLARE @ExamStartTime DATETIME, @CrsID INT, @QuesCount TINYINT

    -- Retrieve exam details
    SELECT @ExamStartTime = StartTime, @CrsID = CrsID, @QuesCount = QuestionCount
    FROM Exam
    WHERE ID = @ExamID;
    -- Check if the exam exists
    IF (@CrsID IS NULL)
        BEGIN
        PRINT 'Exam is not found'
        RETURN;
    END
    -- Check if the exam has already been generated
    ELSE IF (@ExamStartTime IS NOT NULL)
         BEGIN
        PRINT 'You can not generate already Generated Exam'
        RETURN;
    END
    ELSE
        BEGIN
        BEGIN TRY
                BEGIN TRANSACTION ;

                    -- Disable trigger to allow insertion of exam questions
                    DISABLE TRIGGER trg_ExamQuestionsPreventInsert ON ExamQuestions;

                    -- Insert multiple choice questions into the exam
                    INSERT INTO ExamQuestions
            (ExamID, QuestionID)
        SELECT TOP(@ChooseOneCount)
            @ExamID, q.ID
        FROM question AS q JOIN QuestionTypes AS qt ON q.TypeID = qt.ID AND qt.ID = 1 AND q.CrsID = @CrsID
        ORDER BY NEWID()
                        -- Insert true/false questions into the exam
                    INSERT INTO ExamQuestions
            (ExamID, QuestionID)
        SELECT TOP(@TrueFalseCount)
            @ExamID, q.ID
        FROM question AS q JOIN QuestionTypes AS qt ON q.TypeID = qt.ID AND qt.ID = 2 AND q.CrsID = @CrsID
        ORDER BY NEWID();
                    -- Enable trigger after insertion
                    ENABLE TRIGGER trg_ExamQuestionsPreventInsert ON ExamQuestions;

                    -- Disable trigger to allow update of exam total mark
                    DISABLE TRIGGER trg_ExamPreventUpdate ON Exam;
                    DISABLE TRIGGER trg_ExamPreventUpdateStartTime ON Exam;
                    -- Update the total mark and start time of the exam
                    UPDATE Exam
                        SET TotalMark = (SELECT SUM(q.Mark)
        FROM question AS q JOIN ExamQuestions AS eq ON eq.QuestionID = q.ID
        WHERE eq.ExamID = @ExamID) , StartTime = GETDATE()
                        WHERE ID = @ExamID;

                    -- Enable trigger after update
                    ENABLE TRIGGER trg_ExamPreventUpdate ON Exam;
                    ENABLE TRIGGER trg_ExamPreventUpdateStartTime ON Exam;
                    -- Disable trigger to allow insertion of student exams
                    DISABLE TRIGGER trg_StudentExamInsertPrevent ON StudentExams;

                    -- Assign the exam to students
                    INSERT INTO StudentExams
            (StdID, ExamID)
        SELECT s.ID, @ExamID
        FROM Student AS s
            JOIN StudentCourses AS sc ON sc.StdID = s.ID
            JOIN Exam AS e ON e.CrsID = sc.CrsID
            JOIN Intake AS i ON s.IntakeID = i.ID
        WHERE e.ID = @ExamID
            AND e.StartTime BETWEEN i.StartDate AND i.EndDate;

                    -- Enable trigger after insertion
                    ENABLE TRIGGER trg_StudentExamInsertPrevent ON StudentExams;

                COMMIT TRANSACTION
            END TRY
            BEGIN CATCH
                -- Rollback transaction in case of error
                ROLLBACK TRANSACTION
                PRINT 'operation failed'
            END CATCH

    END

END;

GO