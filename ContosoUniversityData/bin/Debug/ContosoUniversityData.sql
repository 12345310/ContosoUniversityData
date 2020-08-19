/*
ContosoUniversityData の配置スクリプト

このコードはツールによって生成されました。
このファイルへの変更は、正しくない動作の原因になる可能性があると共に、
コードが再生成された場合に失われます。
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "ContosoUniversityData"
:setvar DefaultFilePrefix "ContosoUniversityData"
:setvar DefaultDataPath "C:\Users\一臣\AppData\Local\Microsoft\VisualStudio\SSDT\ContosoUniversityData"
:setvar DefaultLogPath "C:\Users\一臣\AppData\Local\Microsoft\VisualStudio\SSDT\ContosoUniversityData"

GO
:on error exit
GO
/*
SQLCMD モードを検出して、SQLCMD モードがサポートされていない場合にスクリプトの実行を無効にします。
SQLCMD モードを有効化した後でスクリプトを再度有効にするには、次を実行します:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'このスクリプトを正常に実行するには SQLCMD モードを有効にする必要があります。';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'[dbo].[FK_dbo.Enrollment_dbo.Student_StudentID] を削除しています...';


GO
ALTER TABLE [dbo].[Enrollment] DROP CONSTRAINT [FK_dbo.Enrollment_dbo.Student_StudentID];


GO
PRINT N'テーブル [dbo].[Student] の再構築を開始しています...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Student] (
    [StudentID]      INT           IDENTITY (1, 1) NOT NULL,
    [LastName]       NVARCHAR (50) NULL,
    [FirstName]      NVARCHAR (50) NULL,
    [MiddleName]     NVARCHAR (50) NULL,
    [EnrollmentDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([StudentID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Student])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Student] ON;
        INSERT INTO [dbo].[tmp_ms_xx_Student] ([StudentID], [LastName], [FirstName], [EnrollmentDate])
        SELECT   [StudentID],
                 [LastName],
                 [FirstName],
                 [EnrollmentDate]
        FROM     [dbo].[Student]
        ORDER BY [StudentID] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_Student] OFF;
    END

DROP TABLE [dbo].[Student];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Student]', N'Student';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'[dbo].[FK_dbo.Enrollment_dbo.Student_StudentID] を作成しています...';


GO
ALTER TABLE [dbo].[Enrollment] WITH NOCHECK
    ADD CONSTRAINT [FK_dbo.Enrollment_dbo.Student_StudentID] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Student] ([StudentID]) ON DELETE CASCADE;


GO
MERGE INTO Course AS Target 
USING (VALUES 
        (1, 'Economics', 3), 
        (2, 'Literature', 3), 
        (3, 'Chemistry', 4)
) 
AS Source (CourseID, Title, Credits) 
ON Target.CourseID = Source.CourseID 
WHEN NOT MATCHED BY TARGET THEN 
INSERT (Title, Credits) 
VALUES (Title, Credits);

MERGE INTO Student AS Target
USING (VALUES 
        (1, 'Tibbetts', 'Donnie', '2013-09-01'), 
        (2, 'Guzman', 'Liza', '2012-01-13'), 
(3, 'Catlett', 'Phil', '2011-09-03')
)
AS Source (StudentID, LastName, FirstName, EnrollmentDate)
ON Target.StudentID = Source.StudentID
WHEN NOT MATCHED BY TARGET THEN
INSERT (LastName, FirstName, EnrollmentDate)
VALUES (LastName, FirstName, EnrollmentDate);

MERGE INTO Enrollment AS Target
USING (VALUES 
(1, 2.00, 1, 1),
(2, 3.50, 1, 2),
(3, 4.00, 2, 3),
(4, 1.80, 2, 1),
(5, 3.20, 3, 1),
(6, 4.00, 3, 2)
)
AS Source (EnrollmentID, Grade, CourseID, StudentID)
ON Target.EnrollmentID = Source.EnrollmentID
WHEN NOT MATCHED BY TARGET THEN
INSERT (Grade, CourseID, StudentID)
VALUES (Grade, CourseID, StudentID);
GO

GO
PRINT N'新しく作成された制約に対して既存のデータをチェックしています';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[Enrollment] WITH CHECK CHECK CONSTRAINT [FK_dbo.Enrollment_dbo.Student_StudentID];


GO
PRINT N'更新が完了しました。';


GO
