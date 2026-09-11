<?php
/**
 * Breath Technology Hotspot – Passpoint WLANProfile XML generator
 *
 * Proprietary code – Akadata Limited
 *
 * Generates a Passpoint-compatible WLANProfile XML dynamically
 * for Windows clients, supporting seamless Hotspot 2.0.
 */

header('Content-Type: application/xml; charset=UTF-8');
header('Content-Disposition: attachment; filename="BreathPasspointProfile.xml"');

// Define your Passpoint settings
$profileName = 'BreathPasspointHotspot';
$ssid = 'BreathPasspoint';
$friendlyName = 'Breath Technology Hotspot';
$fqdn = 'breathtechnology.co.uk';
$roamingConsortiumOI = '112233'; // Example OI — change to your real OI
$eapType = 23; // 23 = EAP-AKA, 50 = EAP-SIM

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
        <authentication>WPA2</authentication>
        <encryption>AES</encryption>
        <useOneX>true</useOneX>
      </authEncryption>
      <OneX xmlns="http://www.microsoft.com/networking/OneX/v1">
        <EAPConfig>
          <EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
            <EapMethod>
              <Type xmlns="http://www.microsoft.com/provisioning/EapCommon">{$eapType}</Type>
              <AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0</AuthorId>
            </EapMethod>
            <Config xmlns="http://www.microsoft.com/provisioning/EapHostConfig">
              <EapSim-Config xmlns="http://www.microsoft.com/provisioning/EapSim">
                <UseNativeSIM>true</UseNativeSIM>
              </EapSim-Config>
            </Config>
          </EapHostConfig>
        </EAPConfig>
      </OneX>
      <HotspotProfile xmlns="http://www.microsoft.com/networking/WLAN/HotspotProfile/v1">
        <HomeSP>
          <FriendlyName>{$friendlyName}</FriendlyName>
          <FQDN>{$fqdn}</FQDN>
          <RoamingConsortiumOI>{$roamingConsortiumOI}</RoamingConsortiumOI>
        </HomeSP>
      </HotspotProfile>
    </security>
  </MSM>
</WLANProfile>
XML;
