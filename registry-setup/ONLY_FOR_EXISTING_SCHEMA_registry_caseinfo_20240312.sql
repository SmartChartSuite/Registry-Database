ALTER TABLE syphilis.case_info ADD last_successful_datetime timestamp NULL;
COMMENT ON COLUMN syphilis.case_info.last_successful_datetime IS 'last datatime that had a successful query';
ALTER TABLE syphilis.case_info ADD case_started_running_datetime timestamp NULL;
COMMENT ON COLUMN syphilis.case_info.case_started_running_datetime IS 'datetime that query has started';
ALTER TABLE scd.case_info ADD last_successful_datetime timestamp NULL;
COMMENT ON COLUMN syphilis.case_info.last_successful_datetime IS 'last datatime that had a successful query';
ALTER TABLE scd.case_info ADD case_started_running_datetime timestamp NULL;
COMMENT ON COLUMN syphilis.case_info.case_started_running_datetime IS 'datetime that query has started';
