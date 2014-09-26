SELECT
  COUNCIL_LEAD_ID,
  jfr.COUNCIL_LEAD_JOB_PROFILE_RELATION_ID,
  jfr.COMPANY,
  jfr.COMPANY_ID,
  COALESCE(TITLE, ' '),
  COALESCE(START_YEAR, '-'),
  COALESCE(START_MONTH, '-'),
  COALESCE(END_YEAR, '-'),
  COALESCE(END_MONTH, '-'),
  COALESCE(CURRENT_IND, 0)
FROM
  GLGLIVE.dbo.COUNCIL_LEAD_JOB_PROFILE_RELATION jfr
WHERE
  jfr.CURRENT_IND > 0
