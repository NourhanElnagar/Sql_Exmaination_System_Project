-------------------------Get Course Topics------------------
CREATE PROCEDURE sp_GetCourseTopics
    @CrsID INT
AS
BEGIN
BEGIN TRY
    -- Check if the given course ID exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE ID = @CrsID)
    BEGIN
        PRINT 'This course id does not exist';
        RETURN;
    END

    -- Fetch topics related to the course ID
    SELECT 
        T.ID AS TopicID,
        T.Name AS TopicName,
        T.CrsID AS CourseId,
		C.Name  AS CourseName
    FROM 
        Topic T inner join Course C
         on T.CrsID = C.ID;
		where C.ID=@CrsID;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH
END

