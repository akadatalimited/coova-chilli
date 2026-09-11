<?php
/**
 * REDIR_SUCCESS.php
 * WISPr successful login response
 */

require_once __DIR__ . '/../lib/WISPrResponse.php';

use BreathTechnology\WISPrResponse;

$config = include __DIR__ . '/../config/wispr.php';

$wispr = new WISPrResponse($config);

header("Content-Type: text/html; charset=UTF-8");

$responseXML = $wispr->generateAuthReply(
    responseCode: 50,
    replyMessage: 'Login successful.',
    logoffURL: $config['LogoffURL'] ?? '',
    statusURL: $config['StatusURL'] ?? '',
    maxSessionTime: 3600,
    gracePeriod: 300,
    redirectionURL: $config['RedirectionURL'] ?? ''
);
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login Successful</title>
</head>
<body>
<?= $responseXML ?>
</body>
</html>
