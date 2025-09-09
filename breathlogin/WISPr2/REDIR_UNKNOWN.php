<?php
/**
 * REDIR_UNKNOWN.php
 * WISPr fallback unknown reply
 */

require_once __DIR__ . '/../lib/WISPrResponse.php';

use BreathTechnology\WISPrResponse;

$config = include __DIR__ . '/../config/wispr.php';

$wispr = new WISPrResponse($config);

header("Content-Type: text/html; charset=UTF-8");

$responseXML = $wispr->generateAuthReply(
    responseCode: 255,
    replyMessage: 'Unknown request or internal error.',
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
  <title>Unknown Error</title>
</head>
<body>
<?= $responseXML ?>
</body>
</html>
