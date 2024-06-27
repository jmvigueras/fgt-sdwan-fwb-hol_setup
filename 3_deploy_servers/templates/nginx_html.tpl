<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >
    <title>Portal de acceso Cloud workshop – Fortinet </title>
    <!-- Add custom CSS styles -->
    <style>
        body {
            font-family: 'Arial', sans-serif;
            text-align: start;
            margin: 50px;
        }
        h1 {
            color: #333;
        }
        form {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        label {
            margin-bottom: 10px;
        }
        input {
            padding: 5px;
            margin-bottom: 15px;
            width: 200px;
            box-sizing: border-box;
        }
        button {
            background-color: #4CAF50;
            color: white;
            padding: 5px 15px;
            font-size: 10px;
            cursor: pointer;
            border-radius: 2px;
            border: none;
        }
        button:hover {
            background-color: #45a049;
        }
        p {
            color: #333;
            text-align: start; 
            margin: 10px;
        }
    </style>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script>  
	    function redirect(){
        tokenid=document.getElementById('tokenid').value
        window.location = "http://${lab_fqdn}/"+tokenid
      };	
  </script> 
  </head>
  <body>
    <h1><span style="color:Red">Fortinet</span> - Cloud workshop</h1>
    <p></p>
    <hr/>
    <h3>Introduce codigo del laboratorio:</h3>
        <input type="text" id="tokenid" name="tokenid"> 
        <button id="btn1" type="button" onclick=redirect()>Go</button>
  </body>
</html>

