<?php
/**
 * REDIR_LOGOFF.php
 * WISPr logoff reply
 */

require_once __DIR__ . '/../lib/WISPrResponse.php';

use BreathTechnology\WISPrResponse;

$config = include __DIR__ . '/../config/wispr.php';

$wispr = new WISPrResponse($config);

header("Content-Type: text/html; charset=UTF-8");
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Logoff</title>
</head>
<body>
<?= $wispr->generateLogoffReply() ?>
</body>
</html>
