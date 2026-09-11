<?php

require_once __DIR__ . '/../lib/WISPrResponse.php';

use BreathTechnology\WISPrResponse;

// Load config
$config = include __DIR__ . '/../config/wispr.php';

$wispr = new WISPrResponse($config);

// Output redirect response
echo $wispr->generateRedirect();


echo $wispr->generateAuthReply(
    responseCode: 50,
    replyMessage: 'Login successful.',
    logoffURL: 'http://10.1.0.1:3990/logoff',
    statusURL: 'http://10.1.0.1:3990/status',
    maxSessionTime: 3600,
    gracePeriod: 300,
    redirectionURL: 'http://www.breathtechnology.co.uk/welcome'
);
