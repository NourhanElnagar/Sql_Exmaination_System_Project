--------------- *Reports PROC* ---------------------------
-----Students information by Department No ---------
CREATE PROC sp_StdInfoByDeptNo
@TrackID INT
AS
BEGIN TRY
	IF NOT EXISTS (SELECT 1 FROM Track WHERE ID = @TrackID)
		BEGIN
		print 'This Track does not exist' 
        END
	ELSE
		BEGIN	
		SELECT DISTINCT S.ID AS Student_ID, S.fname + ' ' + S.lname AS Full_name , S.Age ,T.Name AS Track_Name ,I.Name AS Intake_Name
		         FROM Student S JOIN Track T
				 ON T.ID = @TrackID
				 JOIN Intake I
				 ON I.ID = S.IntakeID	
				WHERE S.TrackID = @TrackID
		END		
END TRY
BEGIN CATCH
	 PRINT 'An error occurred';
END CATCH
GO
------------

----Student Grades in all courses-------
CREATE PROC sp_StudentGrade
@Std_Id INT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Student WHERE ID = @Std_Id)
        BEGIN
            PRINT 'This Student does not exist';
            RETURN;
        END
		ELSE
		BEGIN
        SELECT  
            S.ID AS Student_ID, 
            S.fname + ' ' + S.lname AS Full_name, 
            C.Name AS Course_Name, 
            SUM(SE.Grade) AS Total_Grade
        FROM Student S
        JOIN StudentExams SE ON S.ID = SE.StdID
        JOIN Exam E ON SE.ExamID = E.ID
        JOIN Course C ON E.CrsID = C.ID
        WHERE S.ID = @Std_Id
        GROUP BY S.ID, S.fname, S.lname, C.Name; 
       END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred';
    END CATCH
END;
GO

