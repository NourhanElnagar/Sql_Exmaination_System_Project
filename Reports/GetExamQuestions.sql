GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO ALTER PROCEDURE [dbo].[GetExamQuestions] @ExamID INT AS BEGIN -- Select questions and their options for the given ExamID
SELECT DISTINCT Q.ID AS QuestionID,
    Q.Body AS Question,
    t.Type
FROM Question Q
    INNER JOIN ExamQuestions EQ ON Q.ID = EQ.QuestionID
    LEFT JOIN [QuestionOptions] O ON Q.ID = O.QuestionID
    join QuestionTypes t ON t.ID = q.TypeID
WHERE EQ.ExamID = @ExamID
END;