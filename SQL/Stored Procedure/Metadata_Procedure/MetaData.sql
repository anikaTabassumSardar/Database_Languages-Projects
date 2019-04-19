IF EXISTS (SELECT name FROM sysobjects
WHERE name = 'MetaData' AND type = 'P')
DROP PROCEDURE MetaData
GO
CREATE PROCEDURE MetaData
AS 
DECLARE @objectID int
DECLARE @tableName varchar(300)
DECLARE @columnName varchar(30)
DECLARE @rowCount int
DECLARE @totalCount int
SET @totalCount = 0; 

DECLARE @sql nvarchar(4000)
DECLARE @params nvarchar(4000)


DECLARE loopObjIDCursor CURSOR FOR 
	SELECT object_id FROM sys.tables
OPEN loopObjIDCursor
FETCH NEXT FROM loopObjIDCursor INTO @objectID
WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @tableName = Name FROM sys.tables WHERE object_id=@objectID
		PRINT 'Table Name: ' + @tableName
		PRINT 'Table Columns:'
		DECLARE columnsCursor CURSOR FOR
			SELECT Name FROM sys.columns WHERE object_id=@objectID
			OPEN columnsCursor
			FETCH NEXT FROM columnsCursor INTO @columnName
			WHILE @@FETCH_STATUS = 0
				BEGIN	
				IF EXISTS(
					SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS C
					JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS K
					ON C.TABLE_NAME = K.TABLE_NAME
					AND C.CONSTRAINT_CATALOG = K.CONSTRAINT_CATALOG
					AND C.CONSTRAINT_SCHEMA = K.CONSTRAINT_SCHEMA
					AND C.CONSTRAINT_NAME = K.CONSTRAINT_NAME
					AND K.COLUMN_NAME = @columnName
					WHERE C.CONSTRAINT_TYPE = 'PRIMARY KEY')
					BEGIN
						IF EXISTS(
					SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS C
					JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS K
					ON C.TABLE_NAME = K.TABLE_NAME
					AND C.CONSTRAINT_CATALOG = K.CONSTRAINT_CATALOG
					AND C.CONSTRAINT_SCHEMA = K.CONSTRAINT_SCHEMA
					AND C.CONSTRAINT_NAME = K.CONSTRAINT_NAME
					AND K.COLUMN_NAME = @columnName
					WHERE C.CONSTRAINT_TYPE = 'FOREIGN KEY')
						BEGIN
							PRINT '        '+@columnName + '=> PK, FK *******'; --if it is both PK, FK
						END
					ELSE
						PRINT '        '+@columnName + ' => PK *******'; --if it is just PK
					END
				ELSE 
					BEGIN
						PRINT '        '+@columnName; --if it is a normal column
					END
					FETCH NEXT FROM columnsCursor INTO @columnName
				END
								
				SELECT @sql = 'Select @cnt = COUNT(*) from ' + QUOTENAME(@tableName)
				SELECT @params = '@cnt int OUTPUT';
				EXEC sp_executesql @sql, @params, @cnt = @rowCount OUTPUT
				SET @totalCount += @rowCount  --accumulating the total								
				PRINT ('Row Count:' + CAST(@rowCount as varchar(4000)));
				PRINT ('_______________________________________________');
				CLOSE columnsCursor
				DEALLOCATE columnsCursor
				FETCH NEXT FROM loopObjIDCursor INTO @objectID
	END
	PRINT ('_______________________________________________'); --double line to mean the end of the report and summary is being presented
	PRINT 'Total Count of Rows (SUMMARY): ' + CAST(@totalCount as varchar(7000));
CLOSE loopObjIDCursor
DEALLOCATE loopObjIDCursor
