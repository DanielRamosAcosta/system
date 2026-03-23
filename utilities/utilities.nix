{lib, ...}: {
  interpolateCurve = points:
    let
      inherit (builtins) length elemAt genList head;
      sorted = lib.sort (a: b: a.temp < b.temp) points;
      n = length sorted;
      minTemp = (head sorted).temp;
      maxTemp = (elemAt sorted (n - 1)).temp;
      range = maxTemp - minTemp;

      tempAt = i:
        if i == 0 then minTemp
        else if i == 15 then maxTemp
        else minTemp + (i * range) / 15;

      findSegment = temp: idx:
        if idx >= n - 1 then n - 2
        else if (elemAt sorted (idx + 1)).temp >= temp then idx
        else findSegment temp (idx + 1);

      interpolateSpeed = temp:
        let
          idx = findSegment temp 0;
          a = elemAt sorted idx;
          b = elemAt sorted (idx + 1);
          dt = b.temp - a.temp;
          ds = b.speedPercentage - a.speedPercentage;
        in
          if dt == 0 then a.speedPercentage
          else a.speedPercentage + ((temp - a.temp) * ds) / dt;

      makePoint = i:
        let temp = tempAt i;
        in { inherit temp; speedPercentage = interpolateSpeed temp; };
    in
      genList makePoint 16;

  toBase64 = text: let
    inherit (lib) sublist mod stringToCharacters concatMapStrings;
    inherit (lib.strings) charToInt;
    inherit (builtins) substring foldl' genList elemAt length concatStringsSep stringLength;
    lookup = stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    sliceN = size: list: n: sublist (n * size) size list;
    pows = [(64 * 64 * 64) (64 * 64) 64 1];
    intSextets = i: map (j: mod (i / j) 64) pows;
    compose = f: g: x: f (g x);
    intToChar = elemAt lookup;
    convertTripletInt = sliceInt: concatMapStrings intToChar (intSextets sliceInt);
    sliceToInt = foldl' (acc: val: acc * 256 + val) 0;
    convertTriplet = compose convertTripletInt sliceToInt;
    join = concatStringsSep "";
    convertLastSlice = slice: let
      len = length slice;
    in
      if len == 1
      then (substring 0 2 (convertTripletInt ((sliceToInt slice) * 256 * 256))) + "=="
      else if len == 2
      then (substring 0 3 (convertTripletInt ((sliceToInt slice) * 256))) + "="
      else "";
    len = stringLength text;
    nFullSlices = len / 3;
    bytes = map charToInt (stringToCharacters text);
    tripletAt = sliceN 3 bytes;
    head = genList (compose convertTriplet tripletAt) nFullSlices;
    tail = convertLastSlice (tripletAt nFullSlices);
  in
    join (head ++ [tail]);
}
