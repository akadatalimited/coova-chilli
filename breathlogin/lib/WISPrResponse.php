<?php
/**
 * WISPrResponse Class
 * Breath Technology Hotspot
 *
 * Proprietary code – Akadata Limited
 */

namespace BreathTechnology;

class WISPrResponse
{
    protected array $config = [];

    public function __construct(array $config = [])
    {
        $this->config = $config;
    }

    public function generateRedirect(): string
    {
        return $this->xmlComment($this->buildRedirectXML());
    }

    public function generateAuthReply(
        int $responseCode,
        string $replyMessage = '',
        string $logoffURL = '',
        string $statusURL = '',
        int $maxSessionTime = 0,
        int $gracePeriod = 0,
        string $redirectionURL = ''
    ): string {
        return $this->xmlComment(
            $this->buildAuthReplyXML(
                $responseCode,
                $replyMessage,
                $logoffURL,
                $statusURL,
                $maxSessionTime,
                $gracePeriod,
                $redirectionURL
            )
        );
    }

    public function generateEAPAuthReply(
        int $responseCode,
        string $eapMsg,
        string $loginURL
    ): string {
        return $this->xmlComment(
            $this->buildEAPAuthReplyXML(
                $responseCode,
                $eapMsg,
                $loginURL
            )
        );
    }

    public function generateLogoffReply(): string
    {
        return $this->xmlComment($this->buildLogoffReplyXML());
    }

    public function generateSessionReply(int $sessionTime = 0): string
    {
        return $this->xmlComment($this->buildSessionReplyXML($sessionTime));
    }

    public function generateAbortReply(): string
    {
        return $this->xmlComment($this->buildAbortReplyXML());
    }

    // -----------------------
    // Internal builders below
    // -----------------------

    protected function buildRedirectXML(): string
    {
        $v = $this->config;
        return <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <Redirect>
    <MessageType>100</MessageType>
    <ResponseCode>0</ResponseCode>
    <VersionHigh>{$this->escape($v['VersionHigh'] ?? '2.0')}</VersionHigh>
    <VersionLow>{$this->escape($v['VersionLow'] ?? '1.0')}</VersionLow>
    <AccessProcedure>{$this->escape($v['AccessProcedure'] ?? '1.0')}</AccessProcedure>
    <AccessLocation>{$this->escape($v['AccessLocation'] ?? 'Unknown')}</AccessLocation>
    <LocationName>{$this->escape($v['LocationName'] ?? 'Breath Technology')}</LocationName>
    <LoginURL>{$this->escape($v['LoginURL'] ?? 'https://example.com/login')}</LoginURL>
    <AbortLoginURL>{$this->escape($v['AbortLoginURL'] ?? '')}</AbortLoginURL>
  </Redirect>
</WISPAccessGatewayParam>
XML;
    }

    protected function buildAuthReplyXML(
        int $responseCode,
        string $replyMessage,
        string $logoffURL,
        string $statusURL,
        int $maxSessionTime,
        int $gracePeriod,
        string $redirectionURL
    ): string {
        return <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <AuthenticationReply>
    <MessageType>120</MessageType>
    <ResponseCode>{$this->escape($responseCode)}</ResponseCode>
    <ReplyMessage>{$this->escape($replyMessage)}</ReplyMessage>
    <LogoffURL>{$this->escape($logoffURL)}</LogoffURL>
    <StatusURL>{$this->escape($statusURL)}</StatusURL>
    <MaxSessionTime>{$this->escape($maxSessionTime)}</MaxSessionTime>
    <GracePeriod>{$this->escape($gracePeriod)}</GracePeriod>
    <RedirectionURL>{$this->escape($redirectionURL)}</RedirectionURL>
  </AuthenticationReply>
</WISPAccessGatewayParam>
XML;
    }

    protected function buildEAPAuthReplyXML(
        int $responseCode,
        string $eapMsg,
        string $loginURL
    ): string {
        return <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <EAPAuthenticationReply>
    <MessageType>121</MessageType>
    <ResponseCode>{$this->escape($responseCode)}</ResponseCode>
    <EAPMsg>{$this->escape($eapMsg)}</EAPMsg>
    <LoginURL>{$this->escape($loginURL)}</LoginURL>
  </EAPAuthenticationReply>
</WISPAccessGatewayParam>
XML;
    }

    protected function buildLogoffReplyXML(): string
    {
        return <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <LogoffReply>
    <MessageType>130</MessageType>
    <ResponseCode>0</ResponseCode>
  </LogoffReply>
</WISPAccessGatewayParam>
XML;
    }

    protected function buildSessionReplyXML(int $sessionTime): string
    {
        return <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <SessionReply>
    <MessageType>140</MessageType>
    <ResponseCode>0</ResponseCode>
    <SessionTime>{$this->escape($sessionTime)}</SessionTime>
  </SessionReply>
</WISPAccessGatewayParam>
XML;
    }

    protected function buildAbortReplyXML(): string
    {
        return <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <AbortReply>
    <MessageType>110</MessageType>
    <ResponseCode>0</ResponseCode>
  </AbortReply>
</WISPAccessGatewayParam>
XML;
    }

    protected function xmlComment(string $xml): string
    {
        return "<!--\n" . $xml . "\n-->";
    }

    protected function escape($value): string
    {
        return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
    }
}


public function generateAuthPollReply(
    int $responseCode,
    string $replyMessage = '',
    int $delay = 0,
    string $logoffURL = ''
): string {
    return $this->xmlComment(<<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <AuthenticationPollReply>
    <MessageType>125</MessageType>
    <ResponseCode>{$this->escape($responseCode)}</ResponseCode>
    <ReplyMessage>{$this->escape($replyMessage)}</ReplyMessage>
    <Delay>{$this->escape($delay)}</Delay>
    <LogoffURL>{$this->escape($logoffURL)}</LogoffURL>
  </AuthenticationPollReply>
</WISPAccessGatewayParam>
XML
    );
}


public function generateProxy(
    int $responseCode,
    string $nextURL = '',
    int $delay = 0
): string {
    return $this->xmlComment(<<<XML
<?xml version="1.0" encoding="UTF-8"?>
<WISPAccessGatewayParam xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.acmewisp.com/WISPAccessGatewayParam.xsd">
  <Proxy>
    <MessageType>115</MessageType>
    <ResponseCode>{$this->escape($responseCode)}</ResponseCode>
    <NextURL>{$this->escape($nextURL)}</NextURL>
    <Delay>{$this->escape($delay)}</Delay>
  </Proxy>
</WISPAccessGatewayParam>
XML
    );
}
