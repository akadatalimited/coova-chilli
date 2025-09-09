<?php
/**
 * REDIR_FAILED.php
 * WISPr failed login response
 */

require_once __DIR__ . '/../lib/WISPrResponse.php';

use BreathTechnology\WISPrResponse;

$config = include __DIR__ . '/../config/wispr.php';

$wispr = new WISPrResponse($config);

header("Content-Type: text/html; charset=UTF-8");

$responseXML = $wispr->generateAuthReply(
    responseCode: 2,
    replyMessage: 'Login failed. Please check credentials.',
    logoffURL: '',
    statusURL: '',
    maxSessionTime: 0,
    gracePeriod: 0,
    redirectionURL: ''
);
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login Failed</title>
</head>
<body>
<?= $responseXML ?>
</body>
</html>
