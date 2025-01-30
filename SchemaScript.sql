CREATE TABLE Branch
(
  ID    INT          NOT NULL IDENTITY(1,1),
  Phone VARCHAR(13) ,
  City  NVARCHAR(20) NOT NULL,
  CONSTRAINT PK_Branch PRIMARY KEY (ID)
)
GO

ALTER TABLE Branch
  ADD CONSTRAINT UQ_BranchPhone UNIQUE (Phone)
GO

ALTER TABLE Branch
  ADD CONSTRAINT UQ_BranchCity UNIQUE (City)
GO

CREATE TABLE BranchTracks
(
  BranchID INT NOT NULL,
  TrackID  INT NOT NULL,
  CONSTRAINT PK_BranchTracks PRIMARY KEY (BranchID, TrackID)
)
GO

CREATE TABLE Course
(
  ID       INT         NOT NULL IDENTITY(1,1),
  Name     VARCHAR(50) NOT NULL,
  Duration SMALLINT    NOT NULL,
  CONSTRAINT PK_Course PRIMARY KEY (ID)
)
GO

ALTER TABLE Course
  ADD CONSTRAINT UQ_CourseName UNIQUE (Name)
GO

CREATE TABLE CoursesInstructors
(
  CrsID INT NOT NULL,
  InsID INT NOT NULL,
  CONSTRAINT PK_CoursesInstructors PRIMARY KEY (CrsID, InsID)
)
GO

CREATE TABLE Exam
(
  ID            INT          NOT NULL IDENTITY(1,1),
  Name          VARCHAR(50)  NOT NULL,
  StartTime     DATETIME              ,
  Duration      TINYINT NOT NULL CHECK(Duration > 0 ),
  EndTime       AS            DATEADD(Minute , Duration , StartTime),
  QuestionCount TINYINT      NOT NULL CHECK(QuestionCount > 0 ),
  TotalMark     TINYINT      DEFAULT  0 ,
  CrsID         INT          NOT NULL,
  InsID         INT          NOT NULL,
  CONSTRAINT PK_Exam PRIMARY KEY (ID)
)
GO

CREATE TABLE ExamQuestions
(
  ExamID     INT NOT NULL,
  QuestionID INT NOT NULL,
  CONSTRAINT PK_ExamQuestions PRIMARY KEY (ExamID, QuestionID)
)
GO

CREATE TABLE Instructor
(
  ID       INT          NOT NULL IDENTITY(1,1),
  Fname    NVARCHAR(30) NOT NULL,
  Lname    NVARCHAR(30)         ,
  BD       DATE         NOT NULL,
  Age      AS           YEAR(GETDATE()) - YEAR(BD),
  Gender   VARCHAR(1)   NOT NULL CHECK (Gender IN ('m','f')),
  Email    VARCHAR(50)  NOT NULL,
  Password VARCHAR(10)  NOT NULL,
  St       NVARCHAR(50) NOT NULL,
  City     NVARCHAR(50) NOT NULL,
  Phone    VARCHAR(13)  NOT NULL,
  HireDate DATE         DEFAULT GETDATE(),
  Salary   DECIMAL(8,2) NOT NULL CHECK(Salary > 0),
  SuperID  INT                  ,
  CONSTRAINT PK_Instructor PRIMARY KEY (ID)
)
GO

ALTER TABLE Instructor
  ADD CONSTRAINT UQ_InstructorEmail UNIQUE (Email)
GO

ALTER TABLE Instructor
  ADD CONSTRAINT UQ_InstructorPhone UNIQUE (Phone)
GO

CREATE TABLE Intake
(
  ID        INT         NOT NULL IDENTITY(1,1),
  Name      VARCHAR(30) NOT NULL,
  StartDate DATE        NOT NULL,
  EndDate   DATE        NOT NULL,
  CONSTRAINT CHK_Date_Validity CHECK (EndDate > StartDate),
  -- Table-level constraint
  CONSTRAINT PK_Intake PRIMARY KEY (ID)
)
GO

ALTER TABLE Intake
  ADD CONSTRAINT UQ_IntakeName UNIQUE (Name)
GO

CREATE TABLE Question
(
  ID            INT          NOT NULL IDENTITY(1,1),
  Body          VARCHAR(150) NOT NULL,
  Mark          TINYINT      NOT NULL CHECK(Mark > 0),
  CorrectAnswer TINYINT              ,
  TypeID        INT          NOT NULL,
  CrsID         INT          NOT NULL,
  InsID         INT          NOT NULL,
  CONSTRAINT PK_Question PRIMARY KEY (ID)
)
GO

CREATE TABLE QuestionOptions
(
  QuestionID INT         NOT NULL,
  OptionNum  TINYINT     NOT NULL CHECK(OptionNum BETWEEN 1 AND 4),
  OptionBody VARCHAR(50) NOT NULL,
  CONSTRAINT PK_QuestionOptions PRIMARY KEY (QuestionID, OptionNum)
)
GO

CREATE TABLE QuestionTypes
(
  ID   INT          NOT NULL IDENTITY(1,1),
  Type NVARCHAR(30) NOT NULL,
  CONSTRAINT PK_QuestionTypes PRIMARY KEY (ID)
)
GO

ALTER TABLE QuestionTypes
  ADD CONSTRAINT UQ_Type UNIQUE (Type)
GO

CREATE TABLE Student
(
  ID       INT          NOT NULL IDENTITY(1,1),
  Fname    NVARCHAR(30) NOT NULL,
  Lname    NVARCHAR(30),
  BD       DATE         NOT NULL,
  Age      AS           YEAR(GETDATE()) - YEAR(BD),
  Gender   VARCHAR(1)   NOT NULL CHECK (Gender IN ('m','f')),
  Email    VARCHAR(50)  NOT NULL,
  Password VARCHAR(10)  NOT NULL,
  St       NVARCHAR(50) NOT NULL,
  City     NVARCHAR(50) NOT NULL,
  Phone    VARCHAR(13)  NOT NULL,
  IntakeID INT          NOT NULL,
  TrackID  INT          NOT NULL,
  CONSTRAINT PK_Student PRIMARY KEY (ID)
)
GO

ALTER TABLE Student
  ADD CONSTRAINT UQ_StudentEmail UNIQUE (Email)
GO

ALTER TABLE Student
  ADD CONSTRAINT UQ_StudentPhone UNIQUE (Phone)
GO

CREATE TABLE StudentCourses
(
  StdID INT NOT NULL,
  CrsID INT NOT NULL,
  CONSTRAINT PK_StudentCourses PRIMARY KEY (StdID, CrsID)
)
GO

CREATE TABLE StudentExams
(
  StdID  INT     NOT NULL,
  ExamID INT     NOT NULL,
  Grade  TINYINT DEFAULT 0 NOT NULL,
  CONSTRAINT PK_StudentExams PRIMARY KEY (StdID, ExamID)
)
GO

CREATE TABLE StudentsExamsAnswers
(
  StdID       INT     NOT NULL,
  QuestionID  INT     NOT NULL,
  ExamID      INT     NOT NULL,
  StdAnswer   TINYINT         ,
  AnswerGrade TINYINT         ,
  CONSTRAINT PK_StudentsExamsAnswers PRIMARY KEY (StdID, QuestionID, ExamID)
)
GO

CREATE TABLE Topic
(
  ID    INT         NOT NULL IDENTITY(1,1),
  CrsID INT         NOT NULL,
  Name  VARCHAR(50) NOT NULL,
  CONSTRAINT PK_Topic PRIMARY KEY (ID)
)
GO

CREATE TABLE Track
(
  ID       INT          NOT NULL IDENTITY(1,1),
  Name     NVARCHAR(30) NOT NULL,
  IntakeID INT                  ,
  MngrID   INT          NOT NULL,
  HireDate DATE         NOT NULL DEFAULT GETDATE(),
  CONSTRAINT PK_Track PRIMARY KEY (ID)
)
GO

-- ALTER TABLE Track
--   ADD CONSTRAINT UQ_TrackName UNIQUE (Name)
-- GO

CREATE TABLE TrackCourses
(
  TrackID INT NOT NULL,
  CrsID   INT NOT NULL,
  CONSTRAINT PK_TrackCourses PRIMARY KEY (TrackID, CrsID)
)
GO

CREATE TABLE TrackInstructors
(
  TrackID INT NOT NULL,
  InsID   INT NOT NULL,
  CONSTRAINT PK_TrackInstructors PRIMARY KEY (TrackID, InsID)
)
GO

ALTER TABLE BranchTracks
  ADD CONSTRAINT FK_Branch_TO_BranchTracks
    FOREIGN KEY (BranchID)
    REFERENCES Branch (ID)
GO

ALTER TABLE BranchTracks
  ADD CONSTRAINT FK_Track_TO_BranchTracks
    FOREIGN KEY (TrackID)
    REFERENCES Track (ID)
GO

ALTER TABLE Track
  ADD CONSTRAINT FK_Intake_TO_Track
    FOREIGN KEY (IntakeID)
    REFERENCES Intake (ID)
GO

ALTER TABLE Student
  ADD CONSTRAINT FK_Intake_TO_Student
    FOREIGN KEY (IntakeID)
    REFERENCES Intake (ID)
GO

ALTER TABLE Student
  ADD CONSTRAINT FK_Track_TO_Student
    FOREIGN KEY (TrackID)
    REFERENCES Track (ID)
GO

ALTER TABLE StudentCourses
  ADD CONSTRAINT FK_Course_TO_StudentCourses
    FOREIGN KEY (CrsID)
    REFERENCES Course (ID)
GO

ALTER TABLE StudentCourses
  ADD CONSTRAINT FK_Student_TO_StudentCourses
    FOREIGN KEY (StdID)
    REFERENCES Student (ID)
GO

ALTER TABLE TrackCourses
  ADD CONSTRAINT FK_Course_TO_TrackCourses
    FOREIGN KEY (CrsID)
    REFERENCES Course (ID)
GO

ALTER TABLE TrackCourses
  ADD CONSTRAINT FK_Track_TO_TrackCourses
    FOREIGN KEY (TrackID)
    REFERENCES Track (ID)
GO

ALTER TABLE Question
  ADD CONSTRAINT FK_QuestionTypes_TO_Question
    FOREIGN KEY (TypeID)
    REFERENCES QuestionTypes (ID)
GO

ALTER TABLE QuestionOptions
  ADD CONSTRAINT FK_Question_TO_QuestionOptions
    FOREIGN KEY (QuestionID)
    REFERENCES Question (ID)
GO

ALTER TABLE StudentsExamsAnswers
  ADD CONSTRAINT FK_Student_TO_StudentsExamsAnswers
    FOREIGN KEY (StdID)
    REFERENCES Student (ID)
GO

ALTER TABLE StudentsExamsAnswers
  ADD CONSTRAINT FK_Question_TO_StudentsExamsAnswers
    FOREIGN KEY (QuestionID)
    REFERENCES Question (ID)
GO

ALTER TABLE ExamQuestions
  ADD CONSTRAINT FK_Exam_TO_ExamQuestions
    FOREIGN KEY (ExamID)
    REFERENCES Exam (ID)
GO

ALTER TABLE ExamQuestions
  ADD CONSTRAINT FK_Question_TO_ExamQuestions
    FOREIGN KEY (QuestionID)
    REFERENCES Question (ID)
GO

ALTER TABLE StudentExams
  ADD CONSTRAINT FK_Student_TO_StudentExams
    FOREIGN KEY (StdID)
    REFERENCES Student (ID)
GO

ALTER TABLE StudentExams
  ADD CONSTRAINT FK_Exam_TO_StudentExams
    FOREIGN KEY (ExamID)
    REFERENCES Exam (ID)
GO

ALTER TABLE Exam
  ADD CONSTRAINT FK_Course_TO_Exam
    FOREIGN KEY (CrsID)
    REFERENCES Course (ID)
GO

ALTER TABLE Track
  ADD CONSTRAINT FK_Instructor_TO_Track
    FOREIGN KEY (MngrID)
    REFERENCES Instructor (ID)
GO

ALTER TABLE Instructor
  ADD CONSTRAINT FK_Instructor_TO_Instructor
    FOREIGN KEY (SuperID)
    REFERENCES Instructor (ID)
GO

ALTER TABLE TrackInstructors
  ADD CONSTRAINT FK_Instructor_TO_TrackInstructors
    FOREIGN KEY (InsID)
    REFERENCES Instructor (ID)
GO

ALTER TABLE TrackInstructors
  ADD CONSTRAINT FK_Track_TO_TrackInstructors
    FOREIGN KEY (TrackID)
    REFERENCES Track (ID)
GO

ALTER TABLE CoursesInstructors
  ADD CONSTRAINT FK_Course_TO_CoursesInstructors
    FOREIGN KEY (CrsID)
    REFERENCES Course (ID)
GO

ALTER TABLE CoursesInstructors
  ADD CONSTRAINT FK_Instructor_TO_CoursesInstructors
    FOREIGN KEY (InsID)
    REFERENCES Instructor (ID)
GO

ALTER TABLE Question
  ADD CONSTRAINT FK_Instructor_TO_Question
    FOREIGN KEY (InsID)
    REFERENCES Instructor (ID)
GO

ALTER TABLE Exam
  ADD CONSTRAINT FK_Instructor_TO_Exam
    FOREIGN KEY (InsID)
    REFERENCES Instructor (ID)
GO

ALTER TABLE Question
  ADD CONSTRAINT FK_Course_TO_Question
    FOREIGN KEY (CrsID)
    REFERENCES Course (ID)
GO

ALTER TABLE Topic
  ADD CONSTRAINT FK_Course_TO_Topic
    FOREIGN KEY (CrsID)
    REFERENCES Course (ID)
GO

ALTER TABLE StudentsExamsAnswers
  ADD CONSTRAINT FK_Exam_TO_StudentsExamsAnswers
    FOREIGN KEY (ExamID)
    REFERENCES Exam (ID)
GO
