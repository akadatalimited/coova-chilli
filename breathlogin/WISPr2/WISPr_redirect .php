header('Content-Type: text/xml; charset=UTF-8');
echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>';
?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <Redirect>
    <AccessProcedure>1.0</AccessProcedure>
    <AccessLocation>Hotel Contoso Guest Network</AccessLocation>
    <LocationName>Hotel Contoso</LocationName>
    <LoginURL>https://captiveportal.com/login</LoginURL>
    <MessageType>100</MessageType>
    <ResponseCode>0</ResponseCode>
  </Redirect>
</WISPAccessGatewayParam>

<?php
