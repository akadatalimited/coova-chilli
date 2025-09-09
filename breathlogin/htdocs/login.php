<?php
/**
 * Breath Technology Hotspot Portal – Login script
 *
 * Proprietary code – Akadata Limited
 */

// Config
$uamSecret = 'd2d0769c749qbrc';
$userPasswordMode = 'pap';
$templateName = 'breath';
$language = 'en';
$loginPath = $_SERVER['PHP_SELF'] ?? '';

$template = is_dir("template/{$templateName}") ? $templateName : 'default';

require_once 'util/password.php';
require_once 'lang/main.php';

if (empty($_SERVER['HTTPS']) || $_SERVER['HTTPS'] !== 'on') {
    include "hotspotlogin-nonssl.php";
    exit;
}

function safeParam(string $key): ?string {
    $value = $_POST[$key] ?? $_GET[$key] ?? null;
    if ($value === null) return null;
    $stripped = strip_tags($value);
    $escaped = htmlspecialchars($stripped, ENT_QUOTES, 'UTF-8');
    if ($value !== $stripped || $value !== $escaped) {
        include "template/{$GLOBALS['template']}/noxss.php";
        exit;
    }
    return $escaped;
}

$username  = safeParam('UserName') ?? '';
$password  = safeParam('Password') ?? '';
$challenge = safeParam('challenge') ?? '';
$button    = safeParam('button') ?? '';
$logout    = safeParam('logout') ?? '';
$prelogin  = safeParam('prelogin') ?? '';
$res       = safeParam('res') ?? '';
$uamip     = safeParam('uamip') ?? '';
$uamport   = safeParam('uamport') ?? '';
$userurl   = safeParam('userurl') ?? '';
$timeleft  = safeParam('timeleft') ?? '';
$redirurl  = safeParam('redirurl') ?? '';
$reply     = safeParam('reply') ?? '';

$userurldecode = $userurl;
$redirurldecode = $redirurl;

if ($button === 'Login') {
    $hexchal = pack('H32', $challenge);
    $newchal = $uamSecret ? pack('H*', md5($hexchal . $uamSecret)) : $hexchal;
    $newpwd = pack('a32', $password);
    $response = md5("\0" . $password . $newchal);
    $pappassword = implode('', unpack('H32', ($newpwd ^ $newchal)));

    $loginUrl = ($userPasswordMode === 'pap')
        ? "http://{$uamip}:{$uamport}/login?username={$username}&password={$pappassword}"
        : "http://{$uamip}:{$uamport}/login?username={$username}&response={$response}&userurl={$userurl}";

    header("Content-Type: text/html; charset=UTF-8");
    ?>
    <!doctype html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Breath Technology Hotspot Login</title>
        <meta http-equiv="Cache-control" content="no-cache">
        <link rel="stylesheet" href="css/bootstrap.min.css" crossorigin="anonymous">
        <?php if (file_exists("template/{$template}/css/style.css")) : ?>
            <link rel="stylesheet" href="template/<?= $template ?>/css/style.css">
        <?php endif; ?>
        <meta http-equiv="refresh" content="0;url=<?= htmlspecialchars($loginUrl, ENT_QUOTES, 'UTF-8') ?>">
    </head>
    <body>
        <?php include "template/{$template}/loggingin.php"; ?>
    </body>
    </html>
    <?php
    exit;
}

// Map official REDIR codes
$resultMap = [
    'success'       => 'REDIR_SUCCESS',
    'failed'        => 'REDIR_FAILED',
    'logoff'        => 'REDIR_LOGOFF',
    'already'       => 'REDIR_ALREADY',
    'notyet'        => 'REDIR_NOTYET',
    'smartclient'   => 'REDIR_SMARTCLIENT',
    'popup1'        => 'REDIR_POPUP',
    'popup2'        => 'REDIR_POPUP2',
    'popup3'        => 'REDIR_POPUP3'
];

$result = $resultMap[$res] ?? 'REDIR_UNKNOWN';

if ($result === 'REDIR_UNKNOWN') {
    include "template/{$template}/hotspotlogin-nonchilli.php";
    exit;
}

header("Content-Type: text/html; charset=UTF-8");
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Breath Technology Hotspot Login</title>
    <meta http-equiv="Cache-control" content="no-cache">
    <link rel="stylesheet" href="css/bootstrap.min.css" crossorigin="anonymous">
    <?php if (file_exists("template/{$template}/css/style.css")) : ?>
        <link rel="stylesheet" href="template/<?= $template ?>/css/style.css">
    <?php endif; ?>
    <?php if (file_exists("template/{$template}/js/style.js")) : ?>
        <script src="template/<?= $template ?>/js/style.js"></script>
    <?php endif; ?>
    <script><?php include 'js/hotspotlogin.js'; ?></script>
</head>
<body onblur="doOnBlur('<?= $result ?>')">
<?php
switch ($result) {
    case 'REDIR_FAILED':
        include "template/{$template}/login-failed-notification.php";
        break;
    case 'REDIR_FAILED':
    case 'REDIR_NOTYET':
        include "template/{$template}/loginform-header.php";
        include "template/{$template}/loginform-login.php";
        include "template/{$template}/loginform-footer.php";
        break;
    case 'REDIR_SUCCESS':
        include "template/{$template}/login-successful.php";
        break;
    case 'REDIR_ALREADY':
    case 'REDIR_POPUP2':
        include "template/{$template}/logoff.php";
        break;
    case 'REDIR_POPUP':
        include "template/{$template}/loggingin-popup.php";
        break;
    case 'REDIR_LOGOFF':
    case 'REDIR_POPUP3':
        include "template/{$template}/prelogin.php";
        break;
    case 'REDIR_SMARTCLIENT':
        // TODO: Implement WISPr XML reply for smart clients
        include "template/{$template}/smartclient.php";
        break;
}
?>
<script src="js/jquery-3.2.1.slim.min.js" crossorigin="anonymous"></script>
<script src="js/popper.min.js" crossorigin="anonymous"></script>
<script src="js/bootstrap.min.js" crossorigin="anonymous"></script>
</body>
</html>
<?php
exit;
