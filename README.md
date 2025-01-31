
# ITI Student Examination System Database Documentation

## Introduction
The ITI Student Examination System is designed to efficiently manage student examinations, track course enrollments, and streamline instructor operations. This documentation provides a technical overview of the system's database architecture, schema details, and security measures.

## Database Architecture

### Entity-Relationship Diagram (ERD)
The ERD provides a high-level view of database structure with key entities:
- **Student**: Stores personal and academic information
- **Intake**: Represents student batches with dates
- **Track**: Categorizes courses by discipline
- **Exam**: Manages examination details

### Mapping Diagram
Illustrates detailed database relationships and schema elements (relationship cardinality intentionally omitted).

## Schema Details

### Student Table
- **Attributes**: `ID`, `Name`, `Address`, `Birthdate`, `Phone`, `Email`, `Password`
- **Purpose**: Stores student information

### Intake Table
- **Attributes**: `ID`, `Name`, `StartDate`, `EndDate`
- **Purpose**: Manages student batches

### Track Table
- **Attributes**: `TrackID`, `Name`
- **Purpose**: Defines course specializations

### Exam Table
- **Attributes**: `ExamID`, `Type`, `TotalMark`, `Duration`, `StartTime`, `EndTime`
- **Purpose**: Stores exam information

## Data Relationships and Constraints
- Student → Intake: One-to-one relationship
- Track → Course: Categorization relationship
- Student ↔ Exam: Many-to-many participation
- Course ↔ Exam: Exam-course association

## Sample Queries

### Fetch Students in Specific Intake
```sql
SELECT * FROM Student
WHERE IntakeID = ?;
