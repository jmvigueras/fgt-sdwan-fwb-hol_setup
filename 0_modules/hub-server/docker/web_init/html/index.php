<!DOCTYPE html>
<html lang="es">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >
    <title>Cloud worshop – Fortinet </title>
    <!-- CSS styles -->
    <link rel="stylesheet" href="styles.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script>
        function hide_studentdata(){
                $("#js_result_studentdata").text("");
        };
	    function get_studentdata(){
                url = "functions/get_studentdata.php";
                data = { email : $("#txt_email").val()}
                $.post( url, data, function(data) {
                        document.getElementById('js_result_studentdata').innerHTML = data;
                });
        };
  </script>
  </head>
  <body>
    <h1><span style="color:Red">Fortinet</span> - FortiWEB Cloud y FortiGSLB Hands-on-Lab</h1>
    <h2>Cloud workshop</h2>
    <h3>Guía y repositorio del laboratorio: <a href="https://github.com/fortidemoscloud/fwb-fgslb-hol">FortiWEB Cloud y FortiGSLB HoL GitRepo</a></h3>
    <hr/>
    <h3>Student data: </h3>
        <label for="email">Enter your email:</label>
        <input type="email" id="txt_email" name="email"> 
        <button id="btn1" type="button" onclick="get_studentdata()">Show</button>
        <button id="btn2" type="button" onclick="hide_studentdata()">Hide</button>
        <pre>
        <code id="js_result_studentdata"></code>
        </pre>
    <hr/>
  </body>
</html>
