<?php
/**
 * Breath Technology Hotspot – WLANProfile XML generator
 *
 * Proprietary code – Akadata Limited
 *
 * Generates a WLANProfile XML dynamically for Windows devices.
 */

header('Content-Type: application/xml; charset=UTF-8');
header('Content-Disposition: attachment; filename="BreathHotspot.xml"');

// Define your hotspot settings
$ssid = 'BreathFreeWiFi';
$profileName = 'BreathHotspot';
$trustedDomain = 'www.breathtechnology.co.uk';

echo <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/CarrierControl/WLAN/v1"
             xmlns:v2="http://www.microsoft.com/networking/CarrierControl/WLAN/v2">
  <name>{$profileName}</name>
  <SSIDConfig>
    <SSID>
      <name>{$ssid}</name>
    </SSID>
  </SSIDConfig>
  <MSM>
    <security>
      <authEncryption>
        <authentication>open</authentication>
        <encryption>none</encryption>
        <useOneX>false</useOneX>
      </authEncryption>
      <HotspotProfile xmlns="http://www.microsoft.com/networking/WLAN/HotspotProfile/v1">
        <ExtAuth>
          <ExtensionId>BreathTechHotspot</ExtensionId>
        </ExtAuth>
        <TrustedDomains>
          <TrustedDomain>{$trustedDomain}</TrustedDomain>
        </TrustedDomains>
        <UserAgent>BreathTechnology</UserAgent>
      </HotspotProfile>
    </security>
  </MSM>
</WLANProfile>
XML;
