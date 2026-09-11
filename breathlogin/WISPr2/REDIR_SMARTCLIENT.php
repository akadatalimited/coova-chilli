<?php
/**
 * REDIR_SMARTCLIENT.php
 * WISPr smart client EAP challenge response
 */

require_once __DIR__ . '/../lib/WISPrResponse.php';

use BreathTechnology\WISPrResponse;

$config = include __DIR__ . '/../config/wispr.php';

$wispr = new WISPrResponse($config);

header("Content-Type: text/html; charset=UTF-8");

$responseXML = $wispr->generateEAPAuthReply(
    responseCode: 10,
    eapMsg: 'AQIAFgQQLh0uQthjM0PZoQBHT6wE0Q==', // Example Base64 payload
    loginURL: $config['LoginURL'] ?? ''
);
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Smart Client Challenge</title>
</head>
<body>
<?= $responseXML ?>
</body>
</html>
