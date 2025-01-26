use ExaminationSystem


--! question

--* insert

-- This trigger prevents insertion into the 'question' table if the combination of CrsID and InsID
-- does not exist in the 'CoursesInstructors' table. If the combination exists, the insertion proceeds.
-- Otherwise, an error is raised.

CREATE TRIGGER trg_InsteadOfInsert
ON question
INSTEAD OF INSERT
AS
 BEGIN
DECLARE  @CrsID INT , @InsID  INT

SELECT  @CrsID = i.CrsID , @InsID = i.InsID  FROM inserted AS i

IF Exists (SELECT ci.CrsID FROM CoursesInstructors AS ci WHERE ci.CrsID = @CrsID AND ci.InsID = @InsID )
    BEGIN
        INSERT INTO question(Body, Mark,CorrectAnswer,TypeID , CrsID , InsID)
        SELECT Body, Mark,CorrectAnswer,TypeID , CrsID , InsID FROM inserted
    END
ELSE
RAISERROR('operation failed',12,1)

END;

--* update

-- This trigger trg_QuestionAfterUpdate is executed after an update on the 'question' table.
-- It checks if the updated question is already in any student's exam and prevents the update if true.
-- If the 'CrsID' or 'InsID' fields are updated, it ensures the new values exist in the 'CoursesInstructors' table.
-- If the new values do not exist, it reverts the update and raises an error.

ALTER TRIGGER trg_QuestionAfterUpdate
ON question
After UPDATE
AS
 BEGIN
    DECLARE  @ID INT , @CrsID INT , @InsID  INT

        SELECT  @ID = ID , @InsID = InsID ,  @CrsID = CrsID   FROM inserted
        IF Exists (SELECT 1 FROM ExamQuestions AS ea WHERE ea.QuestionID = @ID )
            BEGIN
                SELECT @CrsID = CrsID , @InsID = InsID  FROM deleted ;
                    UPDATE question
                    SET CrsID = @CrsID , InsID = @InsID
                    WHERE ID =@ID
                RAISERROR('not allowed to update question that already in students exams',14,1)
            END
        ELSE IF UPDATE(CrsID) OR  UPDATE(InsID)
            BEGIN
                IF NOT  Exists (SELECT ci.CrsID FROM CoursesInstructors AS ci WHERE ci.CrsID = @CrsID AND ci.InsID = @InsID )
                    BEGIN
                        SELECT @CrsID = CrsID , @InsID = InsID  FROM deleted ;
                            UPDATE question
                            SET CrsID = @CrsID , InsID = @InsID
                            WHERE ID =@ID
                    END
                    ELSE
                        RAISERROR('operation failed',13,1)
            END
END;

--! correct answer

--* insert

-- This trigger trg_AfterInsertCorrectAnswer is executed after an insert operation on the 'question' table.
-- It checks if the inserted 'CorrectAnswer' exists in the 'QuestionOptions' table for the given question.
-- If the 'CorrectAnswer' does not exist, it sets the 'CorrectAnswer' to NULL in the 'question' table.
-- Otherwise, it prints a message indicating the correct answer is set to NULL.

CREATE TRIGGER trg_AfterInsertCorrectAnswer
ON question
After INSERT
AS
 BEGIN
    DECLARE  @ID INT , @CorrectAnswer INT
     SELECT @ID = ID , @CorrectAnswer = CorrectAnswer FROM inserted
        IF NOT  Exists (SELECT qa.OptionNum FROM QuestionOptions AS qa WHERE qa.OptionNum = @CorrectAnswer AND qa.QuestionID = @ID )
            BEGIN
                SET @CorrectAnswer = NULL ;
                UPDATE question
                SET CorrectAnswer = @CorrectAnswer
                WHERE ID =@ID
            END
            ELSE
            print 'correct answer st to NULL';
END;

--* update

-- This trigger trg_AfterUpdateCorrectAnswer is executed after an update on the 'question' table.
-- It ensures that the updated 'CorrectAnswer' exists in the 'QuestionOptions' table.
-- If the 'CorrectAnswer' does not exist, it reverts the 'CorrectAnswer' to its previous value.
-- If the 'CorrectAnswer' exists, it prints a message indicating the input is not valid.

create TRIGGER trg_AfterUpdateCorrectAnswer
ON question
After UPDATE
AS
 BEGIN
    DECLARE  @ID INT , @CorrectAnswer INT
     SELECT @ID = ID , @CorrectAnswer = CorrectAnswer FROM inserted

 IF UPDATE(CorrectAnswer)
    BEGIN
        IF NOT  Exists (SELECT qa.OptionNum FROM QuestionOptions AS qa WHERE qa.OptionNum = @CorrectAnswer AND qa.QuestionID = @ID )
            BEGIN
                     SELECT @CorrectAnswer = CorrectAnswer FROM deleted ;
                UPDATE question
                SET CorrectAnswer = @CorrectAnswer
                WHERE ID =@ID
            END
        ELSE
            print 'your input is not exist in question options';
    END

END;


--! question exam


--* insert


-- This trigger trg_ExamQuestionInsteadOfInsert is executed instead of an insert on the 'ExamQuestions' table.
-- It ensures that the question has options and the exam has not exceeded its question count.
-- If conditions are met, it inserts the question into the exam and updates the total mark.
-- Otherwise, it raises an appropriate error.

ALTER TRIGGER trg_ExamQuestionInsteadOfInsert
ON ExamQuestions
INSTEAD OF INSERT
AS
 BEGIN
DECLARE  @QuesID INT , @ExamID INT ,@QuesCount int = NULL, @quesCrs INT , @QesMark INT , @HasOption BINARY

SELECT  @QuesID = i.QuestionID , @ExamID = i.ExamID  FROM inserted AS i
SELECT @quesCrs = CrsID , @QesMark = Mark FROM question WHERE ID = @QuesID
SELECT @QuesCount = e.QuestionCount FROM exam as e WHERE e.CrsID = @QuesCrs AND ID = @ExamID
 set @HasOption = IIF( exists(select 1 FROM QuestionOptions WHERE QuestionID = @QuesID) , 1 , 0)
IF  ( @QuesCount IS NOT NULL)
    BEGIN
        IF (SELECT COUNT(*) FROM ExamQuestions WHERE ExamID = @ExamID) < @QuesCount AND  @HasOption = 1
        BEGIN
            BEGIN TRY
                BEGIN TRANSACTION
                    INSERT INTO ExamQuestions(ExamID , QuestionID)
                        VALUES (@ExamID, @QuesID)

                            UPDATE Exam
                            SET TotalMark += @QesMark
                            WHERE ID = @ExamID
                        COMMIT TRANSACTION
            END TRY
            BEGIN CATCH
                ROLLBACK TRANSACTION
                print 'operation failed'
            END CATCH
        END
        ELSE IF @HasOption = 0
            RAISERROR('Question does not have options',12,1)
        ELSE
            RAISERROR('exam questions is full',12,1)
    END
ELSE
RAISERROR('operation failed',12,1)

END;

--* update

-- This trigger trg_ExamQuestionAfterUpdate is executed after an update on the 'ExamQuestions' table.
-- It prevents changing the exam ID and ensures the new question belongs to the same course.
-- If the exam has already been launched, it raises an error.
-- It also updates the total mark of the exam if the question mark changes.

ALTER TRIGGER trg_ExamQuestionAfterUpdate
ON ExamQuestions
    After UPDATE
AS
BEGIN
    DECLARE  @QuesID INT , @ExamID INT , @QuesCrs INT , @QuesMark INT , @NewQuesID INT , @NewExamID INT , @NewQuesMark INT
    SELECT   @ExamID = ExamID , @QuesID = QuestionID  FROM deleted AS e
    SELECT  @NewQuesID = i.QuestionID , @NewExamID = ExamID FROM inserted AS i
    SELECT @QuesCrs = CrsID , @NewQuesMark = Mark FROM question WHERE ID = @NewQuesID
     IF @ExamID != @NewExamID
            BEGIN
                    UPDATE ExamQuestions
                    Set ExamID = @ExamID, QuestionID = @QuesID
                        WHERE ExamID = @NewExamID AND QuestionID = @NewQuesID;
                 RAISERROR('You can not change Exam' ,16, 1)
            END
    ELSE IF NOT EXISTS(SELECT 1 FROM exam as e WHERE e.CrsID = @QuesCrs AND ID = @ExamID)
        BEGIN
                UPDATE ExamQuestions
                    Set ExamID = @ExamID, QuestionID = @QuesID
                        WHERE ExamID = @NewExamID AND QuestionID = @NewQuesID;
                 IF Exists(SELECT 1 FROM StudentExams WHERE ExamID = @ExamID)
                    BEGIN
                        RAISERROR('Exam already launched' ,16, 1)
                        RETURN ;
                    END
        END

    ELSE
     BEGIN
      SELECT  @QuesMark = Mark  FROM question WHERE ID = @QuesID
                UPDATE Exam
                    SET TotalMark +=  (@NewQuesMark - @QuesMark )
                    where ID = @ExamID;
     END

END;


--! StudentsExamsAnswers

--* insert

-- This trigger trg_StudentsExamsAnswersAfterInsert is executed after an insert on the 'StudentsExamsAnswers' table.
-- It validates the student's answer and updates the answer grade and student's total grade.
-- If the inputs are invalid, it rolls back the transaction and raises an error.

CREATE TRIGGER trg_StudentsExamsAnswersAfterInsert
ON StudentsExamsAnswers
After INSERT
AS
BEGIN
    DECLARE @stdID INT , @QuesID INT , @ExamID INT , @StdAnswer INT , @AnswerGrade TINYINT
    select @stdID = StdID , @QuesID = QuestionID , @ExamID = ExamID , @StdAnswer = StdAnswer  FROM inserted
    IF NOT Exists(select 1 FROM StudentExams as se JOIN ExamQuestions as eq on eq.ExamID = se.ExamID AND  eq.ExamID = @ExamID  AND se.StdID = @stdID AND eq.QuestionID = @QuesID)
            OR NOT EXISTS(select 1 FROM QuestionOptions WHERE QuestionID = @QuesID AND OptionNum = @StdAnswer)
        BEGIN
            ROLLBACK
            RAISERROR('Wrong inputs',13,1)
            RETURN;
        END
    ELSE
        BEGIN
            SELECT @AnswerGrade = IIF(@StdAnswer = CorrectAnswer , Mark , 0) FROM question as q WHERE q.ID = @QuesID
            begin TRY
                BEGIN TRANSACTION
                    UPDATE StudentsExamsAnswers
                        SET AnswerGrade = @AnswerGrade
                        WHERE StdID = @stdID AND QuestionID = @QuesID AND ExamID = @ExamID ;

                    UPDATE StudentExams
                        SET Grade += @AnswerGrade
                        WHERE StdID = @stdID AND ExamID = @ExamID

                    COMMIT TRANSACTION
            end TRY
            BEGIN CATCH
                PRINT 'Operation Failed'
                ROLLBACK TRANSACTION
            END CATCH
        END

END;


-- Select rows from a Table or st' in schema 'SchemaName'
SELECT * FROM Exam
WHERE 	/* add search conditions here */
GO


--!   student exam

--* insert

-- This trigger trg_StudentExamInsertPrevent is executed after an insert on the 'StudentExams' table.
-- It prevents any insert operations on the table by rolling back the transaction and raising an error.

create TRIGGER trg_StudentExamInsertPrevent
ON StudentExams
After INSERT
AS
BEGIN
    ROLLBACK
    RAISERROR('No operations allowed on this Table',13,1)
END;




--* update

-- This trigger prevents updates to the StdID and ExamID columns in the StudentExams table.
-- If an update is attempted on these columns, the transaction is rolled back and an error is raised.

alter TRIGGER trg_StudentExamPreventUpdateStdExam
ON StudentExams
After UPDATE
AS
BEGIN
    IF  UPDATE(StdID) OR UPDATE(ExamID)
    BEGIN
        ROLLBACK
        RAISERROR('you can not update these data',13,1)
    END
END;


-- This trigger trg_StudentExamPreventUpdateGrade is executed after an update on the 'StudentExams' table.
-- It prevents updates to the 'grade' column by rolling back the transaction and raising an error.

create TRIGGER trg_StudentExamPreventUpdateGrade
ON StudentExams
After UPDATE
AS
BEGIN
    IF  UPDATE(grade)
    BEGIN
        ROLLBACK
        RAISERROR('you can not update these data',13,1)
    END
END;

--* delete

-- This trigger trg_StudentExamPreventDelete is executed instead of a delete on the 'StudentExams' table.
-- It prevents any delete operations on the table by rolling back the transaction and raising an error.

create TRIGGER trg_StudentExamPreventDelete
ON StudentExams
INSTEAD OF DELETE
AS
BEGIN
    BEGIN
        ROLLBACK
        RAISERROR('No operations allowed on this Table',13,1)
    END
END;

--! Exam

--* insert

-- This trigger is executed instead of an INSERT operation on the Exam table.
-- It checks if the combination of CrsID and InsID exists in the CoursesInstructors table.
-- If it exists, it inserts a new record into the Exam table with the provided values.
-- If it does not exist, it raises an error indicating invalid values.

CREATE TRIGGER tgr_ExamInsteadOfInsert
ON Exam
INSTEAD OF INSERT
AS
BEGIN
DECLARE @ID INT , @Name VARCHAR(50) , @CrsID INT , @InsID INT , @Duration DECIMAL(3,2) , @QuestionCount INT
    SELECT @ID = ID ,@Name = Name , @CrsID = CrsID , @InsID = InsID , @Duration = Duration , @QuestionCount = QuestionCount  FROM inserted
    IF EXISTS(SELECT 1 FROM CoursesInstructors WHERE CrsID = @CrsID AND InsID = @InsID)
        BEGIN
            insert into Exam(Name , StartTime , Duration , QuestionCount , TotalMark , CrsID , InsID)
                values(@Name , NULL , @Duration , @QuestionCount , 0 , @CrsID , @InsID) ;
        END
    ELSE
        RAISERROR('insert valid values',13,1)

END;


-- This trigger prevents updates to the Exam table after the exam has started.
-- It also restricts updates to only the Name, QuestionCount, and Duration columns.

alter TRIGGER tgr_ExamPreventUpdate
ON Exam
After UPDATE
AS
BEGIN
    DECLARE  @StartTime datetime
    SELECT @StartTime = StartTime  FROM deleted
    IF(@StartTime IS NOT NULL)
    BEGIN
        ROLLBACK
        RAISERROR('you can not update exam data After launching exam',13,1)
    END
    ELSE IF (UPDATE(TotalMark) OR UPDATE(CrsID) OR UPDATE(InsID) )
    BEGIN
        ROLLBACK
        RAISERROR('you can only update Name , QuestionCount and Duration',13,1)
    END

END;


-- This trigger prevents updating the StartTime column in the Exam table.
-- If an attempt is made to update StartTime, the transaction is rolled back.
-- An error is raised if the original StartTime value is NULL.

ALTER TRIGGER tgr_ExamPreventUpdateStartTime
ON Exam
After UPDATE
AS
BEGIN
    DECLARE  @StartTime datetime
    SELECT @StartTime = StartTime  FROM deleted
    if UPDATE(StartTime)
    BEGIN
        ROLLBACK
        IF @StartTime IS NULL
            RAISERROR('you can only update Name , QuestionCount and Duration',13,1)
    END

END;