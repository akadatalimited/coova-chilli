<?php
/**
 * Breath Technology Hotspot – Carrier Control XML generator
 *
 * Proprietary code – Akadata Limited
 *
 * Generates a Carrier Control XML for Windows mobile broadband provisioning.
 */

header('Content-Type: application/xml; charset=UTF-8');
header('Content-Disposition: attachment; filename="BreathCarrierControl.xml"');

// Example values
$carrierId = '12345';
$carrierName = 'Breath Technology';
$apnName = 'BreathInternet';
$apnString = 'internet.breath';
$wlanProfileName = 'BreathPasspointHotspot';

echo <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<CarrierControl xmlns="http://www.microsoft.com/networking/CarrierControl/v1">
  <CarrierConfig>
    <CarrierId>{$carrierId}</CarrierId>
    <Name>{$carrierName}</Name>
    <DataRoamingAllowed>true</DataRoamingAllowed>
    <AccessPointList>
      <AccessPoint>
        <Name>{$apnName}</Name>
        <AccessString>{$apnString}</AccessString>
        <Authentication>None</Authentication>
      </AccessPoint>
    </AccessPointList>
    <WLANProfiles>
      <WLANProfileReference>
        <Name>{$wlanProfileName}</Name>
      </WLANProfileReference>
    </WLANProfiles>
  </CarrierConfig>
</CarrierControl>
XML;
