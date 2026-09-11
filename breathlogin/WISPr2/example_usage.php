<?php
/**
 * example_usage.php
 *
 * Breath Technology Hotspot – Example script to show how to use WISPrResponse class
 */

require_once __DIR__ . '/../lib/WISPrResponse.php';

use BreathTechnology\WISPrResponse;

$config = include __DIR__ . '/../config/wispr.php';

$wispr = new WISPrResponse($config);

// Generate Redirect
echo $wispr->generateRedirect();

// Generate successful auth reply
echo $wispr->generateAuthReply(
    responseCode: 50,
    replyMessage: 'Login success!',
    logoffURL: $config['LogoffURL'] ?? '',
    statusURL: $config['StatusURL'] ?? '',
    maxSessionTime: 3600,
    gracePeriod: 300,
    redirectionURL: 'https://breathtechnology.co.uk/welcome'
);

// Generate EAP challenge for smart clients
echo $wispr->generateEAPAuthReply(
    responseCode: 10,
    eapMsg: 'AQIAFgQQLh0uQthjM0PZoQBHT6wE0Q==',
    loginURL: $config['LoginURL'] ?? ''
);

// Generate logoff
echo $wispr->generateLogoffReply();

// Generate session status
echo $wispr->generateSessionReply(600);

// Generate abort reply
echo $wispr->generateAbortReply();
