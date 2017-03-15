CREATE OR REPLACE procedure svc_update_svc_consumer(
        svc_name IN  varchar2,
        svc_version IN  NUMBER,
        cons_name IN SVC_CAT_CONSUMER.CONSUMER_NAME%TYPE,
        cla IN  varchar2,
        consumer_description IN  varchar2,
        decomm_comments IN  varchar2
)
AS
        log varchar2(1000);
        err_code varchar2(100);
        err_msg varchar2(256);
        temp_number SVC_CAT_CONSUMER.CONSUMER_ID%TYPE;
BEGIN
     --Log Parameters
     log := svc_name || ' ' || svc_version || ' ' || cons_name;
     INSERT INTO svc_logs( APPLICATION,LOG_LINE, log_text, create_user, create_date) VALUES ('ServiceCatalog','1.1', log, 'SRAVURI', current_date );

      -- FIND CUSTOMER
     SELECT CONSUMER_ID INTO temp_number FROM SVC_CAT_CONSUMER WHERE UPPER(CONSUMER_NAME) = UPPER(cons_name); 
         
     IF SQL%FOUND then
      log :=  temp_number;
      INSERT INTO svc_logs( APPLICATION, LOG_LINE, log_text, create_user, create_date) VALUES ('ServiceCatalog', '1.2', log, 'SRAVURI', current_date );   
     ELSE
       log :=  'No Consumer Found '||cons_name;
      INSERT INTO svc_logs( APPLICATION, LOG_LINE, log_text, create_user, create_date) VALUES ('ServiceCatalog', '1.2', log, 'SRAVURI', current_date );
     END IF;
EXCEPTION  
    WHEN OTHERS THEN
    err_code  := SQLCODE;
    err_msg  := SUBSTR(SQLERRM, 1, 255);
    INSERT INTO svc_logs( APPLICATION, LOG_LINE, log_text, create_user, create_date) VALUES ('ServiceCatalog', err_code , err_msg , 'SRAVURI', current_date );
END svc_update_svc_consumer;
