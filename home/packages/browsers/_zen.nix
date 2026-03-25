{
  inputs,
  pkgs,
  ...
}: {
  users.users.linuxmobile.packages = [
    (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta.override
      {
        extraPolicies = {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableTelemetry = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
        };
      })
  ];
}
