<?php
// define variables and set to empty values
$email = $exit = "";
$dbhost = $dbuser = $dbpass = $db = $table = $mysqli = $sql = $result = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (empty($_POST["email"])) {
        $exit = "Email is required";
    } else {
        $email = $_POST['email'];
        // check if e-mail address is well-formed
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
          $exit = "Invalid email format";
        } else {
            // Get environment variables
            $dbhost = $_ENV['DBHOST'];
            $dbuser = $_ENV['DBUSER'];
            $dbpass = $_ENV['DBPASS'];
            $db = $_ENV['DBNAME'];
            $table = $_ENV['DBTABLE'];

            #echo $dbhost. $dbuser. $dbpass. $db;
            $con = mysqli_connect($dbhost,$dbuser,$dbpass,$db);

            if (mysqli_connect_errno()) {
                $exit = "Error: connecting DB: ". mysqli_connect_error();
            } else {
                $exit = "User not found";
                $sql = "SELECT * FROM " . $table ." WHERE email='".$email."'";
                if ($result = mysqli_query($con,$sql)) {
                    while($row = mysqli_fetch_array($result))
                    {
                        $exit = '<p>';
                        $exit .= '<b>Acceso a FortiWEB Cloud y FortiGSLB (IAM login):</b>';
                        $exit .= '</p>';
                        $exit .= '  accountid  = "' . $row['accountid'] . '"<br>';
                        $exit .= '  user_id = "' . $row['forticloud_user'] . '"<br>';
                        $exit .= '  user_password = "' . $row['forticloud_password'] . '"<br>';
                        $exit .= '<p>';
                        $exit .= '<b>Acceso a tu fortigate:</b>';
                        $exit .= '</p>';
                        $exit .= '  fgt_url  = https://' . $row['fgt_ip'] . ':8443 <br>';
                        $exit .= '  fgt_user = "' . $row['fgt_user'] . '"<br>';
                        $exit .= '  fgt_pass = "' . $row['fgt_password'] . '"<br>';
                        $exit .= '  fgt_api_key = "' . $row['fgt_api_key'] . '"<br>';
                        $exit .= '<p>';
                        $exit .= '<b>Acceso a tus aplicaciones: </b>';
                        $exit .= '</p>';
                        $exit .= '  dvwa_url  = http://' . $row['fgt_ip'] . ':31000 <br>';
                        $exit .= '  swagger_url  = http://' . $row['fgt_ip'] . ':31001 <br>';
                        $exit .= '<p>';
                        $exit .= '<p>';
                    }
                }
            }
            mysqli_close($con);
        }
    }
}
echo $exit;
