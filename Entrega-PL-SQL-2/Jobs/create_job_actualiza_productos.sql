BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'J_ACTUALIZA_PRODUCTOS',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'PKG_ADMIN_PRODUCTOS.P_ACTUALIZAR_TODAS_CUENTAS',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=2',  -- todos los días a las 2 AM
    enabled         => TRUE
  );
END;
