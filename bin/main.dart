/// Command line utility for converting multiple jpg and png images into webp
/// images, while maintaining the original directory structure.
///
/// Usage:
/// --src <path to directory with images>
/// --dst <path to directory to which files will be copied, if it doesn't exist
///       it will be created. The directory will have the same subdirectories
///       structure as --src.
/// [quality <0-100>] 0 -> max compression, 100 -> no compression
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';

const String argSourceDir = '--src';
const String argDestinationDir = '--dst';
const String argQuality = '-q';
const String infoPrefix     = 'INFO:    ';
const String successPrefix  = 'SUCCESS: ';
const String warningPrefix  = 'WARNING: ';
const String errorPrefix    = 'ERROR:   ';

void main(List<String> arguments) {
  readArguments(arguments).then((argsMap) {
    if (argsMap != null) {
      print('CONVERSION STARTED...');
      print('$infoPrefix Converting images from ${argsMap[argSourceDir]}$separator');
      convertImages(argsMap[argSourceDir], argsMap[argDestinationDir],
              quality: argsMap[argQuality])
          .then((finished) {

        print('$infoPrefix Converted images are in ${argsMap[argDestinationDir]}$separator');
        print('CONVERSION FINISHED!');
      });
    }
  });
}

Future<Map<String, String>> readArguments(List<String> arguments) async {
  if (arguments.length < 4) {
    // to few arguments
    printUsage();
  } else {
    var argsMap = <String, String>{};
    // read obligatory arguments
    argsMap[arguments[0]] = processPath(arguments[1]);
    argsMap[arguments[2]] = processPath(arguments[3]);
    // read optional arguments
    for (var argIdx = 4; argIdx < arguments.length - 1; argIdx += 2) {
      argsMap[arguments[argIdx]] = arguments[argIdx + 1];
    }

    if (await validateArguments(argsMap)) {
      return argsMap;
    }
  }

  return null;
}

/// Converts [path] to an absolute path if it is a relative path. The relative
/// path is considered to be from the current localization of user
String processPath(String path) {
  if (path.isEmpty || isAbsolute(path)) {
    return path;
  } else {
    return join(Directory.current.path, path);
  }
}

void printUsage() {
  print('##############################################');
  print(
      '# Usage: $argSourceDir <source dir> $argDestinationDir <destination dir> [$argQuality <0-100>]');
  print('##############################################');
}

Future<bool> validateArguments(Map<String, String> args) async {
  if (args[argSourceDir] == null) {
    print('$errorPrefix No source directory sepcified');
    return false;
  }
  if (!await Directory(args[argSourceDir]).exists()) {
    print('$errorPrefix Source directory doesn\'t exist');
    return false;
  }
  if (args[argDestinationDir] == null) {
    print('$errorPrefix No destination directory specified');
    return false;
  }
  if (args[argQuality] != null) {
    try {
      var quality = int.parse(args[argQuality]);
      if (quality < 0 || quality > 100) {
        print('$errorPrefix Incorrect quality. Quality must be an integer in range 0-100.');
        return false;
      }
    } catch (e) {
      print('$errorPrefix Quality must be an integer in range 0-100.');
      return false;
    }
  }

  return true;
}

/// Converts all images from [srcDir] to .webp to [dstDir], with compression
/// proportional to [quality], 0 -> max compression, 100 -> no compression.
Future<void> convertImages(String srcDir, String dstDir,
    {String quality}) async {
  var filePaths = await dirContents(Directory(srcDir));
  var names = getNames(filePaths);
  var extensions = getExtensions(filePaths);
  await Directory(dstDir).create(recursive: true);
  for (var i = 0; i < names.length; ++i) {
    await convertImage(srcDir, names[i], extensions[i], dstDir,
        quality: quality);
  }
}

/// List file names (with paths) in [dir]
Future<List<String>> dirContents(Directory dir) {
  var filePaths = <String>[];
  var completer = Completer<List<String>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => filePaths.add(file.path),
      onDone: () => completer.complete(filePaths));

  return completer.future;
}

/// Cuts out file names from paths in [paths], with no extensions
List<String> getNames(List<String> paths) {
  var names = <String>[];
  for (var path in paths) {
    names.add(basenameWithoutExtension(path));
  }

  return names;
}

/// Cuts out extensions from paths in [paths]
List<String> getExtensions(List<String> paths) {
  var extensions = <String>[];
  for (var path in paths) {
    extensions.add(extension(path));
  }
  return extensions;
}

/// Converts the specified file to .webp
///
Future<void> convertImage(
    String srcDir, String imgName, String extension, String dstDir,
    {String quality}) async {
  if (extension.isNotEmpty ||
      (!await goDeeper(srcDir, imgName, dstDir, quality: quality))) {
    var result = await Process.run('cwebp.exe', [
      '-q',
      '${quality ?? 100}',
      '$srcDir/$imgName$extension',
      '-o',
      '$dstDir/$imgName.webp'
    ]);

    var success = result.exitCode == 0;
    if (success) {
      print('$successPrefix Converted ${srcDir}$separator$imgName');
    } else {
      print('$warningPrefix Couldn\'t convert ${srcDir}$separator$imgName');
    }
  }
}

/// If the passed path ([srcDir]/[potentialDirName]) is a directory, then it
/// will convert files from this directory as well and put them in [dstDir]
/// in a newly created directory [dstDir]/[potentialDirName]. If the passed
/// path is not a directory, then it returns false.
Future<bool> goDeeper(String srcDir, String potentialDirName, String dstDir,
    {String quality}) async {
  var potDirPath = join(srcDir, potentialDirName);
  var potDir = Directory(potDirPath);
  if (await potDir.exists()) {
    print('$infoPrefix going into directory: $potentialDirName');
    await convertImages(
      potDirPath,
      join(dstDir, potentialDirName),
      quality: quality,
    );
    return true;
  }

  return false;
}
