{lib}: let
  inherit (lib) concatStringsSep mapAttrsToList isBool isInt isList isAttrs isString isFloat;
  inherit (builtins) toString isNull typeOf head length attrNames elem;

  blockOnlyNodes = [
    "window-rule"
    "layer-rule"
    "struts"
    "touchpad"
    "cursor"
    "environment"
    "hotkey-overlay"
    "keyboard"
    "xkb"
    "layout"
    "overview"
    "workspace-shadow"
    "input"
    "gestures"
    "focus-ring"
    "shadow"
    "tab-indicator"
    "binds"
  ];

  inlinePropertyNodes = [
    "match"
    "default-floating-position"
    "focus-follows-mouse"
    "position"
    "border"
    "length"
  ];

  multiValueNodes = [
    "geometry-corner-radius"
  ];

  repeatedPropertyNodes = [
    "preset-column-widths"
  ];

  formatValue = value:
    if isNull value
    then "null"
    else if isBool value
    then
      (
        if value
        then "true"
        else "false"
      )
    else if isInt value
    then toString value
    else if isFloat value
    then toString value
    else if isString value
    then ''"${value}"''
    else throw "Unsupported KDL value type: ${typeOf value}";

  formatProperties = props:
    concatStringsSep " " (mapAttrsToList (k: v: "${k}=${formatValue v}") props);

  formatPropertiesAsNodes = props: level:
    concatStringsSep "\n" (mapAttrsToList (
        k: v:
          if isBool v && v
          then "${indent level}${k}"
          else "${indent level}${k} ${formatValue v}"
      )
      props);

  formatArguments = args:
    concatStringsSep " " (map formatValue args);

  indent = level: concatStringsSep "" (lib.genList (_: "  ") level);

  isStringList = val: isList val && (val == [] || (length val > 0 && isString (head val)));

  isValueBlock = val:
    isAttrs val
    && !val ? children
    && (length (attrNames val)) == 1
    && !isAttrs (builtins.head (builtins.attrValues val))
    && !isList (builtins.head (builtins.attrValues val));

  isOutputNode = name:
    name
    == "eDP-1"
    || name == "HDMI-A-1"
    || lib.hasPrefix "DP-" name
    || lib.hasPrefix "HDMI-" name
    || lib.hasPrefix "eDP-" name;

  flattenNested = value:
    if isAttrs value
    then let
      keys = attrNames value;
      hasOnlyOneKey = length keys == 1;
      key = head keys;
      val = value.${key};
    in
      if hasOnlyOneKey && isAttrs val && !isList val
      then lib.mapAttrs' (k: v: lib.nameValuePair "${key}-${k}" v) (flattenNested val)
      else lib.mapAttrs (_: flattenNested) value
    else value;

  formatNode = name: value: level: let
    ind = indent level;
    isBlockOnly = elem name blockOnlyNodes;
    isInlineProperty = elem name inlinePropertyNodes;
    isRepeatedProperty = elem name repeatedPropertyNodes;
    isMultiValue = elem name multiValueNodes;
    isOutput = isOutputNode name;
  in
    if isStringList value
    then "${ind}${name} ${formatArguments value}"
    else if isList value
    then
      if isRepeatedProperty
      then "${ind}${name} {\n${concatStringsSep "\n" (map (
          item:
            if isAttrs item
            then formatPropertiesAsNodes item (level + 1)
            else throw "Repeated property node items must be attrsets"
        )
        value)}\n${ind}}"
      else if value == []
      then ""
      else concatStringsSep "\n" (map (item: formatNode name item level) value)
    else if isAttrs value
    then let
      isEmpty = value == {};

      flatValue = flattenNested value;

      valueBlocks = lib.filterAttrs (k: v: isValueBlock v) flatValue;
      hasEnableDisable = flatValue ? enable && isBool flatValue.enable;

      props =
        lib.filterAttrs (
          k: v:
            k
            != "children"
            && k != "enable"
            && !isAttrs v
            && !isList v
        )
        flatValue;

      children =
        lib.filterAttrs (
          k: v:
            k
            != "children"
            && k != "enable"
            && !isValueBlock v
            && (isAttrs v || isList v)
        )
        flatValue;

      explicitChildren =
        if flatValue ? children
        then flatValue.children
        else {};
      allChildren =
        children
        // (
          if isAttrs explicitChildren
          then explicitChildren
          else {}
        );

      onlyEnableProperty = hasEnableDisable && props == {} && allChildren == {} && valueBlocks == {};

      propsStr =
        if isMultiValue && props != {}
        then let
          values = mapAttrsToList (_: v: formatValue v) props;
        in " ${concatStringsSep " " values}"
        else if isOutput && props != {}
        then " ${formatProperties props}"
        else if (!isBlockOnly && props != {}) || (isInlineProperty && props != {})
        then " ${formatProperties props}"
        else "";

      valueBlocksStr =
        if valueBlocks != {}
        then
          concatStringsSep "\n" (mapAttrsToList (
              k: v: let
                key = head (attrNames v);
                val = v.${key};
              in "${indent (level + 1)}${k} { ${key} ${formatValue val} }"
            )
            valueBlocks)
        else "";

      propsAsNodesStr =
        if isBlockOnly && props != {}
        then formatPropertiesAsNodes props (level + 1)
        else "";

      hasChildren = allChildren != {} || valueBlocksStr != "" || propsAsNodesStr != "" || onlyEnableProperty;
      childrenStr =
        if onlyEnableProperty
        then
          if flatValue.enable
          then " { on; }"
          else " { off; }"
        else if hasChildren
        then let
          childrenContent = formatDocument allChildren (level + 1);
          parts = lib.filter (s: s != "") [propsAsNodesStr valueBlocksStr childrenContent];
          allContent = concatStringsSep "\n" parts;
        in " {\n${allContent}\n${ind}}"
        else if isEmpty
        then ""
        else "";
    in
      if isEmpty && !hasChildren
      then "${ind}{ ${name}; }"
      else "${ind}${name}${propsStr}${childrenStr}"
    else if isBool value && value
    then "${ind}${name}"
    else "${ind}${name} ${formatValue value}";

  formatDocument = doc: level:
    if isList doc
    then
      concatStringsSep "\n" (lib.filter (s: s != "") (map (
          item:
            if isAttrs item && item ? name
            then formatNode item.name (removeAttrs item ["name"]) level
            else if isAttrs item
            then formatDocument item level
            else throw "Invalid KDL document item: ${typeOf item}"
        )
        doc))
    else if isAttrs doc
    then
      concatStringsSep "\n" (lib.filter (s: s != "") (mapAttrsToList (
          name: value:
            formatNode name value level
        )
        doc))
    else throw "KDL document must be a list or attribute set, got: ${typeOf doc}";

  toKDL = config: formatDocument config 0;
in {
  inherit toKDL;
}
