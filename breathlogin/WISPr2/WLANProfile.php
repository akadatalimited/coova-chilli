header('Content-Type: text/xml; charset=UTF-8');
echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>';
?><WLANProfile xmlns="http://www.microsoft.com/networking/CarrierControl/WLAN/v1">
  <name>Contoso Wi-Fi</name>
  ...
  <HotspotProfile xmlns="http://www.microsoft.com/networking/WLAN/HotspotProfile/v1">
    <ExtAuth>
      <ExtensionId>YourAppIdGoesHere</ExtensionId>
    </ExtAuth>
    <TrustedDomains>
      <TrustedDomain>www.mycaptiveportal.com</TrustedDomain>
    </TrustedDomains>
    <UserAgent>contoso</UserAgent>
  </HotspotProfile>
  ...
</WLANProfile>
<?php