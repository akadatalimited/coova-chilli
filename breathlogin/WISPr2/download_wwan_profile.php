<?php
/**
 * Breath Technology Hotspot – WWANProfile XML generator
 *
 * Proprietary code – Akadata Limited
 *
 * Generates a WWANProfile XML dynamically for Windows mobile broadband provisioning.
 */

header('Content-Type: application/xml; charset=UTF-8');
header('Content-Disposition: attachment; filename="BreathWWANProfile.xml"');

// Example carrier data
$profileName = 'BreathWWANProfile';
$description = 'Breath Technology Mobile Broadband Profile';
$isDefault = 'false';
$providerName = 'BreathMobile';
$providerId = '310260'; // Example MCCMNC (USA T-Mobile); replace for real carrier
$subscriberId = '123456789012345'; // Optional
$accessString = 'internet.breath';
$compression = 'DISABLE';
$authProtocol = 'None'; // Or 'PAP', 'CHAP'

echo <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WWANProfile xmlns="http://www.microsoft.com/networking/WWAN/profile/v1">
  <Name>{$profileName}</Name>
  <Description>{$description}</Description>
  <IsDefault>{$isDefault}</IsDefault>
  <HomeProvider>
    <ProviderName>{$providerName}</ProviderName>
    <ProviderId>{$providerId}</ProviderId>
  </HomeProvider>
  <SubscriberId>{$subscriberId}</SubscriberId>
  <Context>
    <AccessString>{$accessString}</AccessString>
    <Compression>{$compression}</Compression>
    <AuthProtocol>{$authProtocol}</AuthProtocol>
  </Context>
</WWANProfile>
XML;
