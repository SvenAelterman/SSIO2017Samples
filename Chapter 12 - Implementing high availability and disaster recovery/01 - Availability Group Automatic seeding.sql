--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2017 ADMINISTRATION INSIDE OUT"
--
-- © 2018 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 12: IMPLEMENTING HIGH AVAILABILITY AND DISASTER RECOVERY
-- T-SQL SAMPLE 1
--

-- Grant AG rights to seed database
USE master;
GO
ALTER AVAILABILITY GROUP [AG_WWI] GRANT CREATE ANY DATABASE;

-- Change database owner after seeding
USE master;
GO
ALTER AUTHORIZATION ON DATABASE::WideWorldImporters TO [<server principal>];

-- Halt automatic seeding
USE master;
GO
ALTER AVAILABILITY GROUP [AG_WWI] --Availability Group name 

    MODIFY REPLICA ON 'SQLSERVER-1\SQL2K17' --Replica name
    WITH (SEEDING_MODE = MANUAL);

-- Restart automatic seeding after error resolution
USE master;
GO
ALTER AVAILABILITY GROUP [AG_WWI]
    MODIFY REPLICA ON 'SQLSERVER-1\SQL2K17' 
    WITH (SEEDING_MODE = AUTOMATIC);
GO

-- Monitor automatic seeding
USE master;
GO
SELECT s.local_database_name, s.role_desc, s.internal_state_desc, s.transfer_rate_bytes_per_second, s.transferred_size_bytes, s.database_size_bytes, s.start_time_utc, s.end_time_utc, s.estimate_time_complete_utc, s.total_disk_io_wait_time_ms, s.total_network_wait_time_ms, s.failure_message, s.failure_time_utc, s.is_compression_enabled
FROM sys.dm_hadr_physical_seeding_stats s
ORDER BY start_time_utc desc

-- Automatic seeding History
USE master;
GO

SELECT TOP 10 ag.name, dc.database_name, s.start_time, s.completion_time, s.current_state, s.performed_seeding, s.failure_state_desc, s.error_code, s.number_of_attempts
FROM sys.dm_hadr_automatic_seeding s
	INNER JOIN sys.availability_databases_cluster dc ON s.ag_db_id = dc.group_database_id
	INNER JOIN sys.availability_groups ag ON s.ag_id = ag.group_id
ORDER BY start_time desc;
