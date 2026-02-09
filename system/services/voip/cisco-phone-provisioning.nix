{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types concatStringsSep mapAttrsToList;
  cfg = config.homelab.voip.cisco-provisioning;

  # Generate SEP<MAC>.cnf.xml for a phone
  mkPhoneConfig = name: phone: let
    mac = phone.mac;
    callerIdName =
      if phone.callerIdName != ""
      then phone.callerIdName
      else phone.displayName;
  in ''
    <device>
    <deviceProtocol>SIP</deviceProtocol>
    <sshUserId>cisco</sshUserId>
    <sshPassword>cisco</sshPassword>
    <devicePool>
    <dateTimeSetting>
    <dateTemplate>D-M-Ya</dateTemplate>
    <timeZone>${cfg.timeZone}</timeZone>
    <ntps>
    <ntp>
    <name>${cfg.ntpServer}</name>
    <ntpMode>Unicast</ntpMode>
    </ntp>
    </ntps>
    </dateTimeSetting>
    <callManagerGroup>
    <members>
    <member priority="0">
    <callManager>
    <ports>
    <ethernetPhonePort>2000</ethernetPhonePort>
    <sipPort>5060</sipPort>
    <securedSipPort>5061</securedSipPort>
    </ports>
    <processNodeName>${cfg.asteriskAddr}</processNodeName>
    </callManager>
    </member>
    </members>
    </callManagerGroup>
    </devicePool>
    <sipProfile>
    <sipProxies>
    <backupProxy></backupProxy>
    <backupProxyPort>5060</backupProxyPort>
    <emergencyProxy></emergencyProxy>
    <emergencyProxyPort>5060</emergencyProxyPort>
    <outboundProxy></outboundProxy>
    <outboundProxyPort>5060</outboundProxyPort>
    <registerWithProxy>true</registerWithProxy>
    </sipProxies>
    <sipCallFeatures>
    <cnfJoinEnabled>true</cnfJoinEnabled>
    <callForwardURI>x-serviceuri-cfwdall</callForwardURI>
    <callPickupURI>x-cisco-serviceuri-pickup</callPickupURI>
    <callPickupListURI>x-cisco-serviceuri-opickup</callPickupListURI>
    <callPickupGroupURI>x-cisco-serviceuri-gpickup</callPickupGroupURI>
    <meetMeServiceURI>x-cisco-serviceuri-meetme</meetMeServiceURI>
    <abbreviatedDialURI>x-cisco-serviceuri-abbrdial</abbreviatedDialURI>
    <rfc2543Hold>false</rfc2543Hold>
    <callHoldRingback>2</callHoldRingback>
    <localCfwdEnable>true</localCfwdEnable>
    <semiAttendedTransfer>true</semiAttendedTransfer>
    <anonymousCallBlock>2</anonymousCallBlock>
    <callerIdBlocking>2</callerIdBlocking>
    <dndControl>0</dndControl>
    <remoteCcEnable>true</remoteCcEnable>
    </sipCallFeatures>
    <sipStack>
    <sipInviteRetx>6</sipInviteRetx>
    <sipRetx>10</sipRetx>
    <timerInviteExpires>180</timerInviteExpires>
    <timerRegisterExpires>3600</timerRegisterExpires>
    <timerRegisterDelta>5</timerRegisterDelta>
    <timerKeepAliveExpires>120</timerKeepAliveExpires>
    <timerSubscribeExpires>120</timerSubscribeExpires>
    <timerSubscribeDelta>5</timerSubscribeDelta>
    <timerT1>500</timerT1>
    <timerT2>4000</timerT2>
    <maxRedirects>70</maxRedirects>
    <remotePartyID>true</remotePartyID>
    <userInfo>None</userInfo>
    </sipStack>
    <autoAnswerTimer>1</autoAnswerTimer>
    <autoAnswerAltBehavior>false</autoAnswerAltBehavior>
    <autoAnswerOverride>true</autoAnswerOverride>
    <transferOnhookEnabled>false</transferOnhookEnabled>
    <enableVad>false</enableVad>
    <preferredCodec>g711alaw</preferredCodec>
    <dtmfAvtPayload>101</dtmfAvtPayload>
    <dtmfDbLevel>3</dtmfDbLevel>
    <dtmfOutOfBand>avt</dtmfOutOfBand>
    <alwaysUsePrimeLine>false</alwaysUsePrimeLine>
    <alwaysUsePrimeLineVoiceMail>false</alwaysUsePrimeLineVoiceMail>
    <kpml>3</kpml>
    <natEnabled>false</natEnabled>
    <natAddress></natAddress>
    <phoneLabel>${phone.displayName}</phoneLabel>
    <stutterMsgWaiting>1</stutterMsgWaiting>
    <callStats>false</callStats>
    <silentPeriodBetweenCallWaitingBursts>10</silentPeriodBetweenCallWaitingBursts>
    <disableLocalSpeedDialConfig>false</disableLocalSpeedDialConfig>
    <startMediaPort>16384</startMediaPort>
    <stopMediaPort>32766</stopMediaPort>
    <sipLines>
    <line button="1">
    <featureID>9</featureID>
    <featureLabel>${phone.displayName}</featureLabel>
    <proxy>USECALLMANAGER</proxy>
    <port>5060</port>
    <name>${phone.extension}</name>
    <displayName>${phone.displayName}</displayName>
    <autoAnswer>
    <autoAnswerEnabled>2</autoAnswerEnabled>
    </autoAnswer>
    <callWaiting>3</callWaiting>
    <authName>${phone.extension}</authName>
    <authPassword>${phone.authPassword}</authPassword>
    <sharedLine>false</sharedLine>
    <messageWaitingLampPolicy>1</messageWaitingLampPolicy>
    <messagesNumber>*97</messagesNumber>
    <ringSettingIdle>4</ringSettingIdle>
    <ringSettingActive>5</ringSettingActive>
    <contact>${phone.extension}</contact>
    <forwardCallInfoDisplay>
    <callerName>true</callerName>
    <callerNumber>true</callerNumber>
    <redirectedNumber>false</redirectedNumber>
    <dialedNumber>true</dialedNumber>
    </forwardCallInfoDisplay>
    </line>
    </sipLines>
    <voipControlPort>5060</voipControlPort>
    <dscpForAudio>184</dscpForAudio>
    <ringSettingBusyStationPolicy>0</ringSettingBusyStationPolicy>
    <ringSettingIdleStationPolicy>0</ringSettingIdleStationPolicy>
    </sipProfile>
    <commonProfile>
    <phonePassword></phonePassword>
    <backgroundImageAccess>true</backgroundImageAccess>
    <callLogBlfEnabled>2</callLogBlfEnabled>
    </commonProfile>
    <loadInformation>${cfg.firmwareVersion}</loadInformation>
    <vendorConfig>
    <disableSpeaker>false</disableSpeaker>
    <disableSpeakerAndHeadset>false</disableSpeakerAndHeadset>
    <pcPort>0</pcPort>
    <settingsAccess>1</settingsAccess>
    <garp>1</garp>
    <voiceVlanAccess>0</voiceVlanAccess>
    <videoCapability>1</videoCapability>
    <autoSelectLineEnable>0</autoSelectLineEnable>
    <webAccess>0</webAccess>
    <spanToPCPort>1</spanToPCPort>
    <loggingDisplay>1</loggingDisplay>
    <loadServer></loadServer>
    <sshAccess>1</sshAccess>
    <sshPort>22</sshPort>
    </vendorConfig>
    <versionStamp>{location}</versionStamp>
    <userLocale>
    <name>English_United_States</name>
    <uid>1</uid>
    <langCode>en</langCode>
    <version>1.0.0.0-1</version>
    <winCharSet>utf-8</winCharSet>
    </userLocale>
    <networkLocale>United_States</networkLocale>
    <networkLocaleInfo>
    <name>United_States</name>
    <uid>64</uid>
    <version>1.0.0.0-1</version>
    </networkLocaleInfo>
    <deviceSecurityMode>1</deviceSecurityMode>
    <authenticationURL></authenticationURL>
    <directoryURL></directoryURL>
    <idleURL></idleURL>
    <informationURL></informationURL>
    <messagesURL></messagesURL>
    <proxyServerURL></proxyServerURL>
    <servicesURL></servicesURL>
    <transportLayer>
    <retransmissionCeiling>10</retransmissionCeiling>
    <retransmissionFloor>1</retransmissionFloor>
    <keepAliveTimer>25</keepAliveTimer>
    </transportLayer>
    <certHash></certHash>
    <encrConfig>false</encrConfig>
    <sipRegistrarServer>${cfg.asteriskAddr}</sipRegistrarServer>
    </device>
  '';

  # XMLDefault.cnf.xml - default config for unprovisioned phones
  xmlDefaultConfig = ''
    <Default>
    <callManagerGroup>
    <members>
    <member priority="0">
    <callManager>
    <ports>
    <ethernetPhonePort>2000</ethernetPhonePort>
    <sipPort>5060</sipPort>
    </ports>
    <processNodeName>${cfg.asteriskAddr}</processNodeName>
    </callManager>
    </member>
    </members>
    </callManagerGroup>
    <loadInformation model="CISCO IP PHONE 9971">${cfg.firmwareVersion}</loadInformation>
    </Default>
  '';

  # Basic dial plan template
  dialplanConfig = ''
    <DIALTEMPLATE>
    <TEMPLATE MATCH="0" Timeout="3" User="Phone" Rewrite="0"/>
    <TEMPLATE MATCH="1000" Timeout="3" User="Phone" Rewrite="1000"/>
    <TEMPLATE MATCH="1001" Timeout="3" User="Phone" Rewrite="1001"/>
    <TEMPLATE MATCH="1002" Timeout="3" User="Phone" Rewrite="1002"/>
    <TEMPLATE MATCH="1..." Timeout="3" User="Phone" Rewrite="1..."/>
    <TEMPLATE MATCH="*" Timeout="15" User="Phone"/>
    <TEMPLATE MATCH="0.........." Timeout="0" User="Phone"/>
    <TEMPLATE MATCH=".........." Timeout="3" User="Phone"/>
    <TEMPLATE MATCH="011!*" Timeout="15" User="Phone"/>
    <TEMPLATE MATCH="**2" Timeout="0" User="Phone"/>
    <TEMPLATE MATCH="*97" Timeout="0" User="Phone"/>
    </DIALTEMPLATE>
  '';

  # Ring list
  ringlistConfig = ''
    <CiscoIPPhoneRingList>
    <Ring>
    <DisplayName>Default</DisplayName>
    <FileName>Piano1.raw</FileName>
    </Ring>
    </CiscoIPPhoneRingList>
  '';

  # g4-tones.xml for United_States locale
  g4TonesConfig = ''
    <tones>
    <tone type="OutsideDial" timeout="0">
    <part frequency="350+440" level="-19" duration="0"/>
    </tone>
    <tone type="InsideDial" timeout="0">
    <part frequency="350+440" level="-19" duration="0"/>
    </tone>
    <tone type="Busy" timeout="0">
    <part frequency="480+620" level="-24" duration="500"/>
    <part frequency="0" level="0" duration="500"/>
    </tone>
    <tone type="Alerting" timeout="0">
    <part frequency="440+480" level="-19" duration="2000"/>
    <part frequency="0" level="0" duration="4000"/>
    </tone>
    <tone type="Reorder" timeout="0">
    <part frequency="480+620" level="-24" duration="250"/>
    <part frequency="0" level="0" duration="250"/>
    </tone>
    </tones>
  '';

  # English_United_States locale stub
  englishLocaleConfig = ''
    <localeInfo>
    <name>English_United_States</name>
    <uid>1</uid>
    <langCode>en</langCode>
    <version>1.0.0.0-1</version>
    <winCharSet>utf-8</winCharSet>
    </localeInfo>
  '';

  # Generate all phone config files as a derivation
  tftpFiles = pkgs.runCommand "cisco-tftp-configs" {} (
    ''
      mkdir -p $out/United_States

    ''
    + concatStringsSep "\n" (mapAttrsToList (name: phone: ''
        cat > $out/SEP${phone.mac}.cnf.xml << 'PHONEEOF'
        ${mkPhoneConfig name phone}
        PHONEEOF
      '')
      cfg.phones)
    + ''

      cat > $out/XMLDefault.cnf.xml << 'XMLEOF'
      ${xmlDefaultConfig}
      XMLEOF

      cat > $out/dialplan.xml << 'DIALEOF'
      ${dialplanConfig}
      DIALEOF

      cat > $out/ringlist.xml << 'RINGEOF'
      ${ringlistConfig}
      RINGEOF

      cat > $out/g4-tones.xml << 'TONESEOF'
      ${g4TonesConfig}
      TONESEOF

      cat > $out/United_States/g4-tones.xml << 'TONESEOF2'
      ${g4TonesConfig}
      TONESEOF2

      cat > $out/English_United_States.xml << 'LOCEOF'
      ${englishLocaleConfig}
      LOCEOF

      # Empty CTL and ITL files (phone checks for these, non-secure mode)
      touch $out/CTLFile.tlv
      touch $out/ITLFile.tlv
    ''
  );
in {
  options.homelab.voip.cisco-provisioning = {
    enable = mkEnableOption "Cisco IP phone TFTP provisioning";

    tftpRoot = mkOption {
      type = types.path;
      default = "/srv/tftp";
      description = "Root directory for TFTP server";
    };

    asteriskAddr = mkOption {
      type = types.str;
      description = "IP address of the Asterisk server (SIP registrar)";
      example = "192.168.1.202";
    };

    domain = mkOption {
      type = types.str;
      default = "home.dodwell.us";
      description = "SIP domain";
    };

    timeZone = mkOption {
      type = types.str;
      default = "AUS Eastern Standard/Daylight Time";
      description = "Phone display timezone";
    };

    ntpServer = mkOption {
      type = types.str;
      default = "pool.ntp.org";
      description = "NTP server for phone time sync";
    };

    firmwareVersion = mkOption {
      type = types.str;
      default = "SIP9971.9-2-2SR1-9";
      description = "Firmware load identifier (matches .loads filename without extension)";
    };

    phones = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          mac = mkOption {
            type = types.str;
            description = "Phone MAC address (uppercase, no separators)";
            example = "F47F35A342D1";
          };

          extension = mkOption {
            type = types.str;
            description = "SIP extension number";
            example = "1000";
          };

          displayName = mkOption {
            type = types.str;
            description = "Display name shown on phone screen";
          };

          authPassword = mkOption {
            type = types.str;
            description = "SIP authentication password";
          };

          callerIdName = mkOption {
            type = types.str;
            default = "";
            description = "Caller ID name (defaults to displayName if empty)";
          };
        };
      });
      default = {};
      description = "Phone configurations keyed by friendly name";
    };
  };

  config = mkIf cfg.enable {
    # TFTP server
    services.atftpd = {
      enable = true;
      root = cfg.tftpRoot;
    };

    # Firewall: allow TFTP
    networking.firewall.allowedUDPPorts = [69];

    # Create TFTP directory structure and symlink generated configs
    systemd.tmpfiles.rules = [
      "d ${cfg.tftpRoot} 0755 nobody nogroup -"
      "d ${cfg.tftpRoot}/United_States 0755 nobody nogroup -"
    ];

    # Deploy generated config files to TFTP root
    systemd.services.cisco-phone-configs = {
      description = "Deploy Cisco phone TFTP configuration files";
      wantedBy = ["multi-user.target"];
      before = ["atftpd.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Copy generated configs to TFTP root (don't clobber firmware files)
        ${pkgs.rsync}/bin/rsync -a --ignore-existing ${tftpFiles}/ ${cfg.tftpRoot}/
        # Always update phone configs and XML files (these are generated, should be current)
        cp -f ${tftpFiles}/SEP*.cnf.xml ${cfg.tftpRoot}/ 2>/dev/null || true
        cp -f ${tftpFiles}/XMLDefault.cnf.xml ${cfg.tftpRoot}/
        cp -f ${tftpFiles}/dialplan.xml ${cfg.tftpRoot}/
        cp -f ${tftpFiles}/ringlist.xml ${cfg.tftpRoot}/
        cp -f ${tftpFiles}/g4-tones.xml ${cfg.tftpRoot}/
        cp -f ${tftpFiles}/United_States/g4-tones.xml ${cfg.tftpRoot}/United_States/
        cp -f ${tftpFiles}/English_United_States.xml ${cfg.tftpRoot}/
        cp -f ${tftpFiles}/CTLFile.tlv ${cfg.tftpRoot}/
        cp -f ${tftpFiles}/ITLFile.tlv ${cfg.tftpRoot}/
        # Ensure permissions are correct for atftpd (runs as nobody)
        chown -R nobody:nogroup ${cfg.tftpRoot}
        chmod -R 755 ${cfg.tftpRoot}
      '';
    };
  };
}
