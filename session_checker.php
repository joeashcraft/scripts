<?php
// DONT FORGET TO CHECK FOR VARNISH RUINING EVERYTHING
ini_set( 'display_errors', 1);
session_start();
 
echo 'HOSTNAME: ' . gethostname() . '<br />';
echo 'ADDR: ' . $_SERVER['SERVER_ADDR']. '<br />';
echo 'SESSION: ' . session_id() . '<br />';
 
if (isset($_SESSION['counter'])) {
$_SESSION['counter']++;
} else {
$_SESSION['counter'] = 1;
}
 
echo '<br />DUMP SESSION:<br />';
echo '<pre>';
print_r($_SESSION);
echo '</pre>';
 
echo '<br />DUMP HEADERS:<br />';
echo '<pre>';
print_r(headers_list());
echo '</pre>';
 
phpinfo();
?>