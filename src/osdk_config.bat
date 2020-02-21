@ECHO OFF

::
:: Set the build paremeters
::
SET OSDKADDR=$500
SET OSDKNAME=GLORIC
SET OSDKCOMP=-O2
REM SET OSDKLINK=-B

SET OSDKFILE=main
SET OSDKFILE=%OSDKFILE% gl8 
SET OSDKFILE=%OSDKFILE% glProject8 
REM SET OSDKFILE=%OSDKFILE% glArrays 

:: List of files to put in the DSK file.
:: Implicitely includes BUILD/%OSDKNAME%.TAP
SET OSDKTAPNAME="glOric"

::run99.tap ..\intro\build\intro.tap
SET OSDKDNAME=" -- glOric --"
SET OSDKINIST="?\"V0.01\":WAIT20:!RUNME.COM"
