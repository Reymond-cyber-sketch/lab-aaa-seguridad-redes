# Consultas para una cuenta local administrativa. No importa configuración.
/system identity print
/system clock print
/system license print
/ip address print
/ip service print
/ip ssh print
/user print proplist=name,group,disabled
/user group print detail without-paging
/user aaa print
/user active print
/radius print proplist=address,src-address,service,authentication-port,accounting-port,require-message-auth
/radius monitor 0 once
/system logging print
/system console print
/port print
