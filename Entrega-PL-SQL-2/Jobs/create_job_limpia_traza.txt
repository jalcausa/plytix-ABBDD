BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'J_LIMPIA_TRAZA',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN DELETE FROM TRAZA WHERE MONTHS_BETWEEN(SYSDATE, Fecha) > 12; COMMIT; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=MINUTELY; INTERVAL=10', -- cada 10 minutos
    enabled         => TRUE
  );
END;

/*
 * Para probar este job, sustituir
 * la acción actual por la siguiente:
 * BEGIN DELETE FROM TRAZA WHERE fecha < SYSDATE - INTERVAL ''1'' MINUTE; COMMIT; END;
 */