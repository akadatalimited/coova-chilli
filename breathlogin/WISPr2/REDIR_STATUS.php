<?php
/**
 * REDIR_STATUS.php
 * WISPr session status reply
 */

require_once __DIR__ . '/../lib/WISPrResponse.php';

use BreathTechnology\WISPrResponse;

$config = include __DIR__ . '/../config/wispr.php';

$wispr = new WISPrResponse($config);

header("Content-Type: text/html; charset=UTF-8");

$sessionTime = 600; // Example value

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Session Status</title>
</head>
<body>
<?= $wispr->generateSessionReply($sessionTime) ?>
</body>
</html>
